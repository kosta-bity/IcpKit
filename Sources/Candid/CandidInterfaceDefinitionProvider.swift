//
//  CandidInterfaceDefinitionProvider.swift
//  
//
//  Created by Konstantinos Gaitanis on 30.07.24.
//

import Foundation

public protocol CandidInterfaceDefinitionProvider {
    func readMain() async throws -> String
    func read(contentsOf file: String) async throws -> String
}

public class FileCandidInterfaceDefinitionProvider: CandidInterfaceDefinitionProvider {
    enum Error: Swift.Error {
        case fileNotFound
    }
    
    let mainFile: URL
    let workingPath: String
    
    public init(workingPath: String, mainFile: String) {
        self.workingPath = workingPath
        self.mainFile = URL(filePath: workingPath).appending(path: mainFile)
    }
    
    public func readMain() async throws -> String {
        let contents = try String(contentsOf: mainFile)
        return contents
    }
    
    public func read(contentsOf file: String) async throws -> String {
        throw Error.fileNotFound
    }
}
