//
//  UrlSessionHttpClient.swift
//  
//
//  Created by Konstantinos Gaitanis on 02.09.24.
//

import Foundation

final class UrlSessionHttpClient: HttpClient {
    private let session: URLSession = URLSession(
        configuration: .ephemeral,
        delegate: nil,
        delegateQueue: OperationQueue()
    )
    
    func fetch(_ request: HttpRequest) async throws -> HttpResponse {
        let urlRequest = request.urlRequest
        let (data, response) = try await session.data(for: urlRequest)
        guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
            throw URLError(.badServerResponse)
        }
        return HttpResponse(data: data, statusCode: statusCode)
    }
}

private extension HttpRequest {
    var urlRequest: URLRequest {
        var urlRequest = URLRequest(url: url)
        urlRequest.httpBody = body
        urlRequest.httpMethod = method
        for (headerField, value) in headers {
            urlRequest.setValue(value, forHTTPHeaderField: headerField)
        }
        urlRequest.timeoutInterval = timeout
        return urlRequest
    }
}
