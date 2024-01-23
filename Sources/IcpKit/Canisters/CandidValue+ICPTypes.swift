//
//  CandidValue+ICPTypes.swift
//  Runner
//
//  Created by Konstantinos Gaitanis on 16.05.23.
//

import Foundation

extension CandidValue {
    var ICPAmount: UInt64? { recordValue?["e8s"]?.natural64Value }
    var ICPTimestamp: UInt64? {
        guard let nanos = recordValue?["timestamp_nanos"]?.natural64Value else { return nil }
        return nanos
    }
    
    static func ICPAmount(_ amount: UInt64) -> CandidValue {
        .record(["e8s": .natural64(amount)])
    }
    
    static func ICPTimestamp(_ timestamp: UInt64) -> CandidValue {
        return .record([
            "timestamp_nanos": .natural64(timestamp)
        ])
    }
    
    static func ICPTimestampNow() -> CandidValue {
        return ICPTimestamp(UInt64(Date.now.timeIntervalSince1970) * 1_000_000_000)
    }
}

enum ICPCandidDecodingError: Error {
    case invalidBlockStructure
    case invalidTransactionStructure
    case invalidOperationStructure
}

extension ICPBlock {
    static func from(_ candidValue: CandidValue) throws -> ICPBlock {
        guard let blockRecord = candidValue.recordValue,
              let parentHash = blockRecord["parent_hash"]?.optionValue?.value?.blobValue,
              let transactionValue = blockRecord["transaction"],
              let timestamp = blockRecord["timestamp"]?.ICPTimestamp else {
            throw ICPCandidDecodingError.invalidBlockStructure
        }
        let transaction = try ICPBlock.Transaction.from(transactionValue)
        return ICPBlock(
            parentHash: parentHash,
            timestamp: timestamp,
            transaction: transaction
        )
    }
}

extension ICPBlock.Transaction {
    static func from(_ candidValue: CandidValue) throws -> ICPBlock.Transaction {
        guard let transactionRecord = candidValue.recordValue,
              let operationValue = transactionRecord["operation"],
              let memo = transactionRecord["memo"]?.natural64Value,
              let created = transactionRecord["created_at_time"]?.ICPTimestamp else {
            throw ICPCandidDecodingError.invalidTransactionStructure
        }
        let operation = try ICPBlock.Transaction.Operation.from(operationValue)
        return ICPBlock.Transaction(memo: memo, createdNanos: created, operation: operation)
    }
}

extension ICPBlock.Transaction.Operation {
    static func from(_ candidValue: CandidValue) throws -> ICPBlock.Transaction.Operation {
        var candidValue = candidValue
        if let unwrappedOptional = candidValue.optionValue?.value {
            candidValue = unwrappedOptional
        }
        guard let operation = candidValue.variantValue else {
            throw ICPCandidDecodingError.invalidOperationStructure
        }
        switch operation.hashedKey {
        case CandidDictionary.hash("Mint"):
            guard let transfer = operation.value.recordValue,
                  let to = transfer["to"]?.blobValue,
                  let amount = transfer["amount"]?.ICPAmount else {
                throw ICPCandidDecodingError.invalidOperationStructure
            }
            return .mint(to: to, amount: amount)
            
        case CandidDictionary.hash("Burn"):
            guard let transfer = operation.value.recordValue,
                  let from = transfer["from"]?.blobValue,
                  let amount = transfer["amount"]?.ICPAmount else {
                throw ICPCandidDecodingError.invalidOperationStructure
            }
            return .burn(from: from, amount: amount)
            
        case CandidDictionary.hash("Transfer"):
            guard let transfer = operation.value.recordValue,
                  let from = transfer["from"]?.blobValue,
                  let to = transfer["to"]?.blobValue,
                  let amount = transfer["amount"]?.ICPAmount,
                  let fee = transfer["fee"]?.ICPAmount else {
                throw ICPCandidDecodingError.invalidOperationStructure
            }
            return .transfer(from: from, to: to, amount: amount, fee: fee)
            
        default:
            throw ICPCandidDecodingError.invalidOperationStructure
        }
    }
}
