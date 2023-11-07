//
//  HttpClient.swift
//  Runner
//
//  Created by Konstantinos Gaitanis on 23.02.23.
//

import Foundation
import RealHTTP

typealias HttpHeaders = HTTPHeaders
typealias HttpBody = HTTPBody
typealias HttpRequest = HTTPRequest
typealias HttpResponse = HTTPResponse
typealias HttpStatusCode = HTTPStatusCode

protocol HttpClient: AnyObject {
    /// Headers which are automatically attached to each request.
    var headers: HttpHeaders { get set }
    /// A list of query params values which will be appended to each request.
    var queryParams: [URLQueryItem] { get set }
    var baseURL: URL? { get }
    
    func fetch(_ request: HttpRequest) async throws -> HttpResponse
}

