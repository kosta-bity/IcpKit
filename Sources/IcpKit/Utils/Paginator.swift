//
//  Paginator.swift
//  Runner
//
//  Created by Konstantinos Gaitanis on 10.05.23.
//

import Foundation

class Paginator<Provider> where Provider: PaginatorPageProvider {
    private let provider: Provider
    private var nextPage: NextPage<Provider.Page> = .first
    
    private var stack = Stack<Provider.Object>()
//    private let logger = BTLogger(module: "Paginator")
    
    init(provider: Provider) {
        self.provider = provider
    }
    
    func stream() -> AsyncThrowingStream<Provider.Object, Error> {
//        logger.info("Begin paginator")
        return AsyncThrowingStream { try await self.fetchNext() }   // we keep strong reference to self by design
                                                        // consumer must simply keep a reference to the stream to keep this alive
    }
    
    private func fetchNext() async throws -> Provider.Object? {
        while stack.isEmpty {
//            logger.debug("No objects in stack")
            guard let objects = try await fetchNextPage() else {
                return nil
            }
            objects.forEach { stack.push($0) }
        }
//        logger.debug("Popping object from stack")
        return stack.pop()
    }
  
    private func fetchNextPage() async throws -> [Provider.Object]? {
        guard let nextPageToFetch = nextPage.page else {
//            logger.info("Fetched last page. Stopping")
            return nil
        }
//        logger.info("Fetching \(nextPageToFetch)")
        
        let (objects, nextPage) = try await provider.fetch(nextPageToFetch)
        if let nextPage = nextPage {
            self.nextPage = .page(nextPage)
        } else {
            self.nextPage = .none
        }
        return objects
    }
}

protocol PaginatorPage: CustomStringConvertible, Equatable {
    static func first() -> Self
}

enum NextPage<Page: PaginatorPage>: CustomStringConvertible, Equatable {
    case first
    case page(Page)
    case none
    
    var page: Page? {
        switch self {
        case .first: return Page.first()
        case .page(let page): return page
        case .none: return nil
        }
    }
    
    var description: String {
        switch self {
        case .first: return "first page"
        case .page(let page): return "page \(page.description)"
        case .none: return "no page"
        }
    }
}

protocol PaginatorPageProvider {
    associatedtype Object
    associatedtype Page: PaginatorPage
    
    func fetch(_ page: Page) async throws -> ([Object], nextPage: Page?)
}
