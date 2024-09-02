//
//  HttpClient.swift
//
//  Created by Konstantinos Gaitanis on 23.02.23.
//

import Foundation

protocol HttpClient: AnyObject {
    func fetch(_ request: HttpRequest) async throws -> HttpResponse
}



struct HttpRequest {
    let method: String
    let url: URL
    let body: Data?
    let headers: [String: String]
    let timeout: TimeInterval
}

struct HttpResponse {
    let data: Data?
    let statusCode: Int
}
