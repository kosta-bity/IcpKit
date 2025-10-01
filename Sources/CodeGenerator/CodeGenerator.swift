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
struct CodeGenerator: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "A utility for generating Swift code from Candid Interface Definition files (.did).",
        subcommands: [GenerateType.self, GenerateValue.self],
        defaultSubcommand: GenerateType.self
    )
    
    struct Options: ParsableArguments {
        @Option(name: .shortAndLong, help: "The Swift name to use for declaring the parsed types and service")
        var name: String
        
        @Argument(help: "The .did file to parse")
        var fileName: String
    }
    
    mutating func run() async throws {
        print("nothing to do")
    }
}


extension CodeGenerator {
    struct GenerateType: AsyncParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "type",
            abstract: "Generate Swift Types"
        )
        
        @OptionGroup var options: Options
        
        mutating func run() async throws {
            let fileProvider = FileCandidInterfaceDefinitionProvider(workingPath: FileManager.default.currentDirectoryPath, mainFile: options.fileName)
            let parsed = try await CandidParser().parseInterfaceDescription(fileProvider)
            let generated = try CandidCodeGenerator().generateSwiftCode(for: parsed, nameSpace: options.name)
            try CodeGenerator.writeToSwiftFile(options.fileName, generated)
        }
    }
    
    struct GenerateValue: ParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "value",
            abstract: "Generate Swift Types"
        )
        
        @OptionGroup var options: Options
        
        mutating func run() throws {
            let path = URL(filePath: FileManager.default.currentDirectoryPath).appending(path: options.fileName)
            let fileContents = try String(contentsOf: path)
            let parsed = try CandidParser().parseValue(fileContents)
            let generated = try CandidCodeGenerator().generateSwiftCode(for: parsed, valueName: options.name)
            try CodeGenerator.writeToSwiftFile(options.fileName, generated)
        }
    }
    
    private static func writeToSwiftFile(_ name: String, _ contents: String) throws {
        let outputFileUrl = URL(filePath: FileManager.default.currentDirectoryPath).appending(path: "\(name).swift")
        try contents.write(to: outputFileUrl, atomically: true, encoding: .utf8)
        print("Generated \(outputFileUrl.absoluteString)")
    }
}
