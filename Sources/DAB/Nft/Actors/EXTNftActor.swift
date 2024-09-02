//
//  EXTNftActor.swift
//
//
//  Created by Konstantinos Gaitanis on 28.08.24.
//

import Foundation
import IcpKit
import BigInt

class EXTNftActor: ICPNftActor {
    let standard: ICPNftStandard = .ext
    private let service: EXT.Service
    
    required init(_ canister: ICPPrincipal, _ client: ICPRequestClient) {
        service = EXT.Service(canister, client: client)
    }
    
    func allNfts() async throws -> [ICPNftDetails] {
        let tokens = try await service.getTokens()
        return try tokens.map { RawNft(index: $0._0, listing: nil, metadata: try $0._1.get()) }.compactMap(icpNftDetails)
    }
    
    func nftDetails(_ tokenIndex: ICPNftDetails.Index) async throws -> ICPNftDetails {
        guard let tokenIndex = UInt32(exactly: try tokenIndex.number()) else {
            throw ICPNftActorError.invalidIndex
        }
        let tokenId = buildTokenId(tokenIndex)
        let metadata = try await service.metadata(tokenId).get()
        guard let details = icpNftDetails(RawNft(index: tokenIndex, listing: nil, metadata: metadata)) else {
            throw ICPNftActorError.invalidMetaData
        }
        return details
    }
    
    func userTokens(_ principal: ICPPrincipal) async throws -> [ICPNftDetails] {
        let tokens = try await service.tokens_ext(ICPAccount.mainAccount(of: principal).address).get()
        return tokens.compactMap(icpNftDetails)
    }
    
    func transfer(from: ICPSigningPrincipal, to principal: ICPPrincipal, _ tokenIndex: ICPNftDetails.Index) async throws {
        fatalError()
    }
}

private extension EXTNftActor {
    func icpNftDetails(_ nft: RawNft) -> ICPNftDetails? {
        let tokenId = buildTokenId(nft.index)
        guard let imageUrl = buildImageUrl(tokenId) else {
            return nil
        }
        return ICPNftDetails(
            standard: .ext,
            index: .number(BigUInt(nft.index)),
            name: "#\(nft.index)",
            url: imageUrl,
            metadata: decodeMetadata(nft.metadata),
            operator: nil,
            canister: service.canister
        )
    }
    
    private func buildImageUrl(_ tokenId: String) -> URL? {
//        ({
//            [NFT_CANISTERS.WRAPPED_PUNKS]: `https://${NFT_CANISTERS.IC_PUNKS}.raw.icp0.io/Token/${index}`,
//            [NFT_CANISTERS.WRAPPED_DRIP]: `https://${NFT_CANISTERS.IC_DRIP}.raw.icp0.io?tokenId=${index}`,
//        }[canisterId] ||
        return URL(string: "https://\(service.canister).raw.icp0.io/?type=thumbnail&tokenid=\(tokenId)")
    }
    
    private func buildTokenId(_ tokenIndex: EXT.TokenIndex) -> String {
        let prefix = Data([0x0A, 0x74, 0x69, 0x64])
        let bytes = prefix + service.canister.bytes + tokenIndex.bigEndianBytes
        return ICPPrincipal(bytes).string
    }
    
    private func decodeMetadata(_ metadata: Data?) -> Any? {
        guard let metadata = metadata else { return nil }
        guard let string = String(data: metadata, encoding: .utf8) else { return metadata }
        guard let decoded = try? JSONDecoder().decode(EXTMetadata.self, from: metadata) else { return string }
        return decoded
    }
}

private typealias RawNft = (index: EXT.TokenIndex, listing: EXT.Listing?, metadata: Data?)
extension EXT.CommonError: Error {}
private extension EXT.Result_1 {
    func `get`() throws -> [RawNft] {
        switch self {
        case .ok(let array): 
            return array.map { $0.tuple }
        case .err(let commonError):
            throw commonError
        }
    }
}

private extension EXT.Result_4 {
    func `get`() throws -> Data? {
        switch self {
        case .ok(let metadata): return try metadata.get()
        case .err(let commonError): throw commonError
        }
    }
}

private extension EXT.Metadata {
    func `get`() throws -> Data? {
        switch self {
        case .fungible(let decimals, let metadata, let name, let symbol):
            throw ICPNftActorError.invalidMetaData
        case .nonfungible(let metadata):
            return metadata
        }
    }
}

private struct EXTMetadata: Decodable {
    let url: URL?
    let thumb: URL?
    let attributes: [Attribute]
    
    struct Attribute: Decodable {
        let trait_type: String
        let value: String
    }
}
