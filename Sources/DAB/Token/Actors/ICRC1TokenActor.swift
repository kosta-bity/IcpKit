//
//  File.swift
//  
//
//  Created by Konstantinos Gaitanis on 02.09.24.
//

import Foundation
import IcpKit
import BigInt

class ICRC1TokenActor: ICPTokenActor {
    let standard: ICPTokenStandard = .icrc1
    private let service: ICRC1.Service
    
    required init(_ canister: IcpKit.ICPPrincipal, _ client: IcpKit.ICPRequestClient) {
        self.service = ICRC1.Service(canister, client: client)
    }
    
    func balance(_ principal: ICPPrincipal) async throws -> BigUInt {
        let balance = try await service.icrc1_balance_of(.init(
            owner: principal,
            subaccount: nil
        ))
        return balance
    }
    
    func fee() async throws -> BigUInt {
        try await service.icrc1_fee()
    }
    
    func transfer(_ args: ICPTokenTransferArgs) async throws -> ICPTokenTransferResponse {
        let response = try await service.icrc1_transfer(
            .init(
                to: .init(owner: args.to.principal, subaccount: args.to.subAccountId),
                fee: args.fee,
                memo: args.memo.map { Data($0.utf8) },
                from_subaccount: args.from.subAccountId,
                created_at_time: args.createdAtTime?.nanoSecondsSince1970,
                amount: args.amount
        ),
            sender: args.sender
        ).get()
        return .height(response)
    }
    
    func approve(_ args: ICPTokenApproveArgs) async throws -> ICPTokenApproveResult {
        // TODO: approve might be supported through 'icrc1_supported_standards()'
        // see https://github.com/dfinity/ICRC-1/blob/main/standards/ICRC-1/README.md#extensions-
        return .error
    }
}

private extension ICRC1.UnnamedType0 {
    func get() throws -> BigUInt {
        switch self {
        case .Ok(let bigUInt): return bigUInt
        case .Err(let error): throw error
        }
    }
}

extension ICRC1.TransferError: Error {}
