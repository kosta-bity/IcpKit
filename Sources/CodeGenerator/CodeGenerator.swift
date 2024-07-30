//
//  CodeGenerator.swift
//
//
//  Created by Konstantinos Gaitanis on 30.07.24.
//

import Foundation
import ArgumentParser
import Candid

@main
struct CodeGenerator: ParsableCommand {
    @Option(name: .shortAndLong, help: "The Swift namespace to use for declaring the parsed types and service")
    var nameSpace: String
    
    @Argument(help: "The .did file to parse")
    var fileName: String
    
    
    mutating func run() throws {
        let semaphore = DispatchSemaphore(value: 0)
        let fileName = self.fileName
        let nameSpace = self.nameSpace
        Task {
            do {
                try await Self.generateCode(fileName, nameSpace)
            } catch (let error) {
                print("Failed! \(error)")
            }
            semaphore.signal()
        }
        semaphore.wait()
    }
    
    static func generateCode(_ filename: String, _ namespace: String) async throws {
        let fileProvider = FileCandidInterfaceDefinitionProvider(workingPath: FileManager.default.currentDirectoryPath, mainFile: filename)
        let parsed = try await CandidParser().parseInterfaceDescription(fileProvider)
        let generated = try CandidCodeGenerator().generateSwiftCode(for: parsed, nameSpace: namespace)
        
        let outputFileUrl = URL(filePath: FileManager.default.currentDirectoryPath).appending(path: "\(namespace).swift")
        try generated.write(to: outputFileUrl, atomically: true, encoding: .utf8)
        print("Generated \(outputFileUrl.absoluteString)")
    }
}
