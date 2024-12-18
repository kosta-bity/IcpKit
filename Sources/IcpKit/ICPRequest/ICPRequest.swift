//
//  ICPRequest.swift
//
//  Created by Konstantinos Gaitanis on 21.04.23.
//

import Foundation
import BigInt
import PotentCBOR
import Candid

private let canisterBaseUrl: URL = "https://icp-api.io/api/v2/canister"

public struct ICPMethod {
    public let canister: ICPPrincipal
    public let methodName: String
    public let args: [CandidValue]?
    
    public init(canister: ICPPrincipal, methodName: String, args: [CandidValue]) {
        self.canister = canister
        self.methodName = methodName
        self.args = args
    }
    
    public init(canister: ICPPrincipal, methodName: String, arg: CandidValue? = nil) {
        self.canister = canister
        self.methodName = methodName
        self.args = arg.map { [$0] }
    }
}

public enum ICPRequestType {
    case call(ICPMethod)
    case query(ICPMethod)
    case readState(paths: [ICPStateTreePath])    
}

/// https://internetcomputer.org/docs/current/references/ic-interface-spec#http-interface
public struct ICPRequest {
    public let requestId: Data
    public let httpRequest: HttpRequest
    
    public init(_ request: ICPRequestType, canister: ICPPrincipal, sender: ICPSigningPrincipal? = nil) async throws {
        let content = try ICPRequestBuilder.buildContent(request, sender: sender?.principal)
        requestId = try content.calculateRequestId()
        let envelope = try await ICPRequestBuilder.buildEnvelope(content, sender: sender)
        let rawBody = try ICPCryptography.CBOR.serialise(envelope)
        httpRequest = HttpRequest(
            method: "POST",
            url: Self.buildUrl(request, canister),
            body: rawBody,
            headers: ["Content-Type": "application/cbor"],
            timeout: 120
        )
    }
    
    private static func buildUrl(_ request: ICPRequestType, _ canister: ICPPrincipal) -> URL {
        var url = canisterBaseUrl
        url.append(path: canister.string)
        url.append(path: ICPRequestTypeEncodable.from(request).rawValue)
        return url
    }
}
