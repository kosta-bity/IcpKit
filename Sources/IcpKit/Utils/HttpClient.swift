//
//  HttpClient.swift
//
//  Created by Konstantinos Gaitanis on 23.02.23.
//

import Foundation

public protocol HttpClient: AnyObject {
    func fetch(_ request: HttpRequest) async throws -> HttpResponse
}

public struct HttpRequest {
    public let method: String
    public let url: URL
    public let body: Data?
    public let headers: [String: String]
    public let timeout: TimeInterval
}

public struct HttpResponse {
    public let data: Data?
    public let statusCode: Int
}
