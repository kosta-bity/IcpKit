//
//  SimpleHttpClient.swift
//  Runner
//
//  Created by Konstantinos Gaitanis on 23.02.23.
//

import Foundation
import RealHTTP

class SimpleHttpClient: HttpClient {
    var headers: HttpHeaders {
        get { client.headers }
        set { client.headers = newValue }
    }
    
    var queryParams: [URLQueryItem] {
        get { client.queryParams }
        set { client.queryParams = newValue }
    }
    
    var baseURL: URL? { client.baseURL }
    
    private let client: HTTPClient
    
    init(baseUrl: URL? = nil) {
        client = HTTPClient(baseURL: baseUrl)
    }
    
    func fetch(_ request: HttpRequest) async throws -> HttpResponse {
        return try await request.fetch(client)
    }
}

