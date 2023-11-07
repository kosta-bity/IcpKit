//
//  HTTPClient+APICallConvertible.swift
//  Runner
//
//  Created by Konstantinos Gaitanis on 28.09.22.
//

import Foundation

protocol ApiMethod {
    associatedtype Request
    associatedtype Success
    associatedtype Failure: Error
    typealias Result = Swift.Result<Success, Failure>
}

protocol HttpApiMethod {
    associatedtype Method: ApiMethod
    static func httpRequest(_ request: Method.Request) -> HttpRequest
    static func decode(_ response: HttpResponse, with request: Method.Request) throws -> Method.Result
}

// MARK: Fetch
enum HttpApiMethodError: String, Error {
    case requestTimeout
}

extension HttpApiMethod {
    static func fetch(_ request: Method.Request, _ client: HttpClient) async throws -> Method.Result {
        let httpRequest = httpRequest(request)
        let httpResponse = try await client.fetch(httpRequest)
        if let error = httpResponse.error {
            if error.category == .timeout {
                throw HttpApiMethodError.requestTimeout
            }
        }
        let decoded = try decode(httpResponse, with: request)
        return decoded
    }
}
