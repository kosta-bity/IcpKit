//
//  OrigynNftActor.swift
//
//
//  Created by Konstantinos Gaitanis on 28.08.24.
//

import Foundation
import IcpKit
import BigInt

class OrigynNftActor: ICPNftActor {
    let standard: ICPNftStandard = .origynNft
    private let service: OrigynNFT.Service
    
    required init(_ canister: ICPPrincipal) {
        service = OrigynNFT.Service(canister)
    }
    
    func allNfts() async throws -> [ICPNftDetails] {
        let collectionInfo = try await service.collection_nft_origyn(nil).get()
        guard let nftIds = collectionInfo.token_ids else { return [] }
        let nftInfos = try await service.nft_batch_origyn(nftIds).map { try $0.get() }
        return try zip(nftIds, nftInfos).map { try nftDetails($0.0, $0.1) }
    }
    
    func nftDetails(_ tokenIndex: ICPNftDetails.Index) async throws -> ICPNftDetails {
        let index = try tokenIndex.string()
        let nftInfo = try await service.nft_origyn(index).get()
        return try nftDetails(index, nftInfo)
    }
    
    func userTokens(_ principal: ICPPrincipal) async throws -> [ICPNftDetails] {
        let nftIds = try await service.balance_of_nft_origyn(.principal(principal)).get().nfts
        let nftInfos = try await service.nft_batch_origyn(nftIds).map { try $0.get() }
        return try zip(nftIds, nftInfos).map { try nftDetails($0.0, $0.1) }
    }
    
    func transfer(from: IcpKit.ICPSigningPrincipal, to principal: ICPPrincipal, _ tokenIndex: ICPNftDetails.Index) async throws {
        fatalError()
    }
}

private extension OrigynNftActor {
    func nftDetails(_ index: String, _ info: OrigynNFT.NFTInfoStable) throws -> ICPNftDetails {
        let metadata = info.metadata
        guard case .Class(let properties) = metadata,
              case .Text(let id) = properties["id"],
              //case .Text(let primaryAsset) = properties["primary_asset"],
              case .Text(let previewAsset) = properties["preview_asset"] else {
            throw ICPNftActorError.invalidMetaData
        }
        let decodedMetada = OrigynNftMetadata(properties)
        guard let previewUrl = decodedMetada.libraries[previewAsset]?.url(service.canister) else {
            throw ICPNftActorError.invalidMetaData
        }
        return ICPNftDetails(
            standard: .origynNft,
            index: .string(index),
            name: id,
            url: previewUrl,
            metadata: decodedMetada,
            operator: nil,
            canister: service.canister
        )
    }
}

struct OrigynNftMetadata {
    let libraries: [OrigynNftLibrary]
    let customProperties: [[OrigynNftProperty]]
    
    fileprivate init(_ properties: [OrigynNFT.PropertyShared]) {
        if case .Array(let cLibraries) = properties["library"] {
            libraries = cLibraries.compactMap(OrigynNftLibrary.init).sorted()
        } else {
            libraries = []
        }
        if case .Array(let apps) = properties["__apps"] {
            self.customProperties = apps.flatMap { app in
                guard case .Class(let appProperties) = app,
                      case .Class(let data) = appProperties["data"] else { return [] }
                return data.compactMap(OrigynNftProperty.init)
            }
        } else {
            customProperties = []
        }
    }
}

struct OrigynNftProperty {
    let name: String
    let value: String
}

struct OrigynNftLibrary {
    let id: String
    let title: String
    let locationType: String
    let location: String
    let contentType: String
    let contentHash: String
    let size: BigUInt
    let sort: BigUInt
    
    enum LocationType {
        case canister
        case collection
        case unknown
    }
    
    var knownLocationType: LocationType {
        switch locationType {
        case "canister": return .canister
        case "collection": return .collection
        default: return .unknown
        }
    }
    
    func url(_ canister: ICPPrincipal) -> URL? {
        switch knownLocationType {
        case .canister, .collection: return URL(string: "https://\(canister.string).raw.icp0.io/\(location)")
        case .unknown: return nil
        }
    }
}

private extension OrigynNftProperty {
    init?(_ property: OrigynNFT.PropertyShared) {
        name = property.name
        guard let stringValue = property.value.string else { return nil }
        value = stringValue
    }
}

private extension OrigynNFT.CandyShared {
    var string: String? {
        switch self {
        case .Text(let stringValue): return stringValue
        case .Nat(let bigUint): return String(bigUint)
        case .Int(let bigInt): return String(bigInt)
        case .Map(_): return nil
        case .Set(let set): return "[\(set.compactMap { $0.string }.joined(separator: ", "))]"
        case .Nat16(let number): return String(number)
        case .Nat32(let number): return String(number)
        case .Nat64(let number): return String(number)
        case .Blob(let data), .Bytes(let data): return data.hex
        case .Bool(let bool): return String(bool)
        case .Int8(let number): return String(number)
        case .Ints(let numbers): return "[\(numbers.map { String($0) }.joined(separator: ", "))]"
        case .Nat8(let number): return String(number)
        case .Nats(let numbers): return "[\(numbers.map { String($0) }.joined(separator: ", "))]"
        case .Int16(let number): return String(number)
        case .Int32(let number): return String(number)
        case .Int64(let number): return String(number)
        case .Option(_): return nil
        case .Floats(let numbers): return "[\(numbers.map { String($0) }.joined(separator: ", "))]"
        case .Float(let number): return String(number)
        case .Principal(let principal): return principal.string
        case .Array(let array): return "[\(array.compactMap { $0.string }.joined(separator: ", "))]"
        case .Class(let properties):
            return "[\(properties.compactMap(OrigynNftProperty.init).map { "\($0.name): \($0.value)"}.joined(separator: ", "))]"
        }
    }
}

extension OrigynNftLibrary: Comparable {
    static func < (lhs: OrigynNftLibrary, rhs: OrigynNftLibrary) -> Bool {
        return lhs.sort < rhs.sort
    }
}

private extension OrigynNftLibrary {
    init?(_ cData: OrigynNFT.C_Data) {
        guard case .Class(let properties) = cData,
              case .Text(let id) = properties["library_id"],
              case .Text(let title) = properties["title"],
              case .Text(let locationType) = properties["location_type"],
              case .Text(let location) = properties["location"],
              case .Text(let contentType) = properties["content_type"],
              case .Text(let contentHash) = properties["content_hash"],
              case .Nat(let size) = properties["size"],
              case .Nat(let sort) = properties["sort"],
              case .Text("public") = properties["read"] else {
            return nil
        }
        self.id = id
        self.title = title
        self.locationType = locationType
        self.location = location
        self.contentType = contentType
        self.contentHash = contentHash
        self.size = size
        self.sort = sort
    }
}

private extension [OrigynNftLibrary] {
    subscript (_ id: String) -> OrigynNftLibrary? {
        first { $0.id == id }
    }
}

private extension [OrigynNFT.PropertyShared] {
    subscript (_ name: String) -> OrigynNFT.CandyShared? {
        first { $0.name == name }?.value
    }
}
private extension OrigynNFT.BalanceResult {
    func get() throws -> OrigynNFT.BalanceResponse {
        switch self {
        case .ok(let response): return response
        case .err(let error): throw error
        }
    }
}

private extension OrigynNFT.NFTInfoResult {
    func get() throws -> OrigynNFT.NFTInfoStable {
        switch self {
        case .ok(let response): return response
        case .err(let error): throw error
        }
    }
}

private extension OrigynNFT.CollectionResult {
    func get() throws -> OrigynNFT.CollectionInfo {
        switch self {
        case .ok(let response): return response
        case .err(let error): throw error
        }
    }
}

extension OrigynNFT.OrigynError: Error {}
