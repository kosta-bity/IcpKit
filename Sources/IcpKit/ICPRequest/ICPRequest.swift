//
//  ICPRequest.swift
//  IcpKit
//
//  Created by Konstantinos Gaitanis on 21.04.23.
//

import Foundation
import BigInt
import PotentCBOR

private let canisterBaseUrl: URL = "https://icp-api.io/api/v2/canister"

public struct ICPMethod {
    public let canister: ICPPrincipal
    public let methodName: String
    public let args: CandidValue?
}

public enum ICPRequestType {
    case call(ICPMethod)
    case query(ICPMethod)
    case readState(paths: [ICPStateTreePath])    
}

/// https://internetcomputer.org/docs/current/references/ic-interface-spec#http-interface
public struct ICPRequest {
    public let requestId: Data
    let httpRequest: HttpRequest
    
    public init(_ request: ICPRequestType, canister: ICPPrincipal, sender: ICPSigningPrincipal? = nil) async throws {
        let content = ICPRequestBuilder.buildContent(request, sender: sender?.principal)
        requestId = try content.calculateRequestId()
        let envelope = try await ICPRequestBuilder.buildEnvelope(content, sender: sender)
        let rawBody = try ICPCryptography.CBOR.serialise(envelope)
        
        httpRequest = HttpRequest {
            $0.method = .post
            $0.url = Self.buildUrl(request, canister)
            $0.body = .data(rawBody, contentType: "application/cbor")
        }
    }
    
    private static func buildUrl(_ request: ICPRequestType, _ canister: ICPPrincipal) -> URL {
        var url = canisterBaseUrl
        url.append(path: canister.string)
        url.append(path: ICPRequestTypeEncodable.from(request).rawValue)
        return url
    }
}
