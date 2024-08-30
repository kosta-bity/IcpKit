//
//  ICRC7NftActor.swift
//
//
//  Created by Konstantinos Gaitanis on 26.08.24.
//

import Foundation
import IcpKit
import BigInt

class ICRC7NftActor: ICPNftActor {
    let standard: ICPNftStandard = .icrc7
    private let service: ICRC7.Service
    
    required init(_ canister: ICPPrincipal) {
        service = ICRC7.Service(canister)
    }
    
    func allNfts() async throws -> [ICPNftDetails] {
        let tokenIds = try await service.icrc7_tokens(prev: nil, take: nil)
        let tokenMetadata = try await service.icrc7_token_metadata(token_ids: tokenIds)
        return try zip(tokenIds, tokenMetadata).map(icpNftDetails)
    }
    
    func nftDetails(_ tokenIndex: ICPNftDetails.Index) async throws -> ICPNftDetails {
        let index = try tokenIndex.number()
        guard let metaData = try await service.icrc7_token_metadata(token_ids: [index]).first else {
            throw ICPNftActorError.nftNotFound
        }
        return try icpNftDetails((index, metaData))
    }
    
    func userTokens(_ principal: ICPPrincipal) async throws -> [ICPNftDetails] {
        let tokens = try await service.icrc7_tokens_of(
            account: ICRC7.Account(owner: principal, subaccount: nil),
            prev: nil,
            take: nil
        )
        let tokenMetadata = try await service.icrc7_token_metadata(token_ids: tokens)
        return try zip(tokens, tokenMetadata).map(icpNftDetails)
    }
    
    func transfer(from: ICPSigningPrincipal, to principal: ICPPrincipal, _ tokenIndex: ICPNftDetails.Index) async throws {
        fatalError()
    }
}

private extension ICRC7NftActor {
    typealias TokenMetadata = [CandidTuple2<String, ICRC7.Value>]
    func icpNftDetails(_ arg: (index: BigUInt, metadata: TokenMetadata?)) throws -> ICPNftDetails {
        guard case .Text(let image) = arg.metadata?["image"],
              let imageUrl = URL(string: image) else {
            throw ICPNftActorError.invalidMetaData
        }
        return ICPNftDetails(
            standard: .icrc7,
            index: .number(arg.index),
            name: "#\(arg.index)",
            url: imageUrl,
            metadata: nil,
            operator: nil,
            canister: service.canister
        )
    }
}

extension ICRC7NftActor.TokenMetadata {
    subscript (_ key: String) -> ICRC7.Value? {
        first { $0._0 == key }?._1
    }
}
