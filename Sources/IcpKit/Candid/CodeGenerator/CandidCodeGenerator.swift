//
//  CandidCodeGenerator.swift
//  
//
//  Created by Konstantinos Gaitanis on 25.07.24.
//

import Foundation

public enum CandidCodeGeneratorError: Error {
    case invalidServiceReference
    case invalidFunctionReference
    case noServiceName
}

public class CandidCodeGenerator {
    public init() {}
    
    public func generateSwiftCode(for interface: CandidInterfaceDefinition, serviceName: String? = nil) throws -> String {
        let context = try CodeGenerationContext(from: interface, serviceName: serviceName)
        let header = buildHeader()
        let types = context.namedTypes.map(buildType)
        
        let output = IndentedString()
        output.addBlock(header, newLine: true)
        output.addBlock(buildTypesBlock(types), newLine: true)
        if let service = context.service {
            output.addBlock(buildServiceBlock(service), newLine: true)
        }
        return output.output
    }
    
    private func buildServiceBlock(_ service: CodeGeneratorCandidService) -> IndentedString {
        let block = IndentedString()
        block.addLine("class \(service.name) {")
        block.increaseIndent()
        block.addLine("let canister: ICPPrincipal")
        block.addLine("let client: ICPRequestClient")
        block.addLine()
        block.addLine("init(canister: ICPPrincipal, client: ICPRequestClient) {")
        block.increaseIndent()
        block.addLine("self.canister = canister")
        block.addLine("self.client = client")
        block.decreaseIndent()
        block.addLine("}")
        block.addLine()
        for method in service.methods {
            block.addBlock(buildServiceMethod(method), newLine: true)
        }
        block.decreaseIndent()
        block.addLine("}")
        return block
    }
    
    private func buildServiceMethod(_ method: CodeGeneratorCandidService.Method) -> IndentedString {
        let block = IndentedString()
        var unnamedArgCount = 0
        let args = method.signature.arguments.map { $0.swiftStringForFunctionArgument(&unnamedArgCount) }.joined(separator: ", ")
        let results: String
        switch method.signature.results.count {
        case 0: results = ""
        case 1: results = " -> \(method.signature.results.first!.type.swiftType())"
        default: results = " -> (\(method.signature.results.map { $0.swiftStringForFunctionMultipleResult() }.joined(separator: ", ")))"
        }
        block.addLine("func \(method.name)(\(args)) async throws\(results) {")
        block.increaseIndent()
        if method.signature.arguments.isEmpty {
            block.addLine("let method = ICPMethod(canister: canister,  methodName: \"\(method.name)\")")
        } else {
            block.addLine("let method = ICPMethod(")
            block.increaseIndent()
            block.addLine("canister: canister,")
            block.addLine("methodName: \"\(method.name)\",")
            if method.signature.arguments.count == 1 {
                let arg = method.signature.arguments.first!
                block.addLine("args: try CandidEncoder().encode(\(arg.name ?? "arg\(arg.index)"))")
            } else {
                block.addLine("args: .record([")
                block.increaseIndent()
                for arg in method.signature.arguments {
                    block.addLine("\(arg.index): try CandidEncoder().encode(\(arg.name ?? "arg\(arg.index)")),")
                }
                block.decreaseIndent()
                block.addLine("])")
            }
            block.decreaseIndent()
            block.addLine(")")
        }
        let clientCall: String
        if method.signature.annotations.query {
            clientCall = "try await client.query(method, effectiveCanister: canister)"
        } else {
            clientCall = "try await client.callAndPoll(method, effectiveCanister: canister)"
        }
        if results.isEmpty {
            block.addLine("_ = \(clientCall)")
        } else {
            block.addLine("let response = \(clientCall)")
            block.addLine("return try CandidDecoder().decode(response)")
        }
        block.decreaseIndent()
        block.addLine("}")
        return block
    }
    
    private func buildTypesBlock(_ types: [GeneratedCode]) -> IndentedString {
        let typeAliases = types.filter { $0.type == .typeAlias }
        let namedTypes = types.filter { $0.type == .namedType }
        
        let block = IndentedString()
        typeAliases.sorted().forEach { block.addBlock($0.output) }
        if !typeAliases.isEmpty { block.addLine() }
        namedTypes.sorted().forEach { block.addBlock($0.output, newLine: true) }
        return block
    }
    
    private func buildHeader() -> IndentedString {
        IndentedString(
            "import IcpKit",
            "import BigInt"
        )
    }
        
    private func buildType(_ name: String, _ candidType: CandidType) -> GeneratedCode {
        switch candidType.codeGenerationType {
        case .typealias(let candidType): return buildTypeAlias(name, candidType)
        case .struct(let candidKeyedTypes): return buildStruct(name, candidKeyedTypes)
        case .variant(let candidKeyedTypes): return buildVariant(name, candidKeyedTypes)
        }
    }
    
    private func buildTypeAlias(_ name: String, _ type: CandidType) -> GeneratedCode {
        GeneratedCode(
            name: name,
            output: IndentedString("typealias \(name) = \(type.swiftType())"),
            type: .typeAlias
        )
    }
    
    private func buildStruct(_ name: String, _ keyedTypes: CandidKeyedTypes) -> GeneratedCode {
        let block = IndentedString()
        block.addLine("struct \(name): GeneratedCandidType {")
        block.increaseIndent()
        for keyedType in keyedTypes {
            block.addLine("let \(keyedType.swiftString())")
        }
        if keyedTypes.hasUnnamedParameters {
            block.addLine()
            block.addBlock(buildCodingKeys(keyedTypes))
        }
        block.decreaseIndent()
        block.addLine("}")
        return GeneratedCode(name: name, output: block, type: .namedType)
    }
    
    private func buildVariant(_ name: String, _ keyedTypes: CandidKeyedTypes) -> GeneratedCode {
        let block = IndentedString()
        block.addLine("enum \(name): GeneratedCandidType {")
        block.increaseIndent()
        for keyedType in keyedTypes {
            block.addLine(buildVariantCase(keyedType))
        }
        block.addLine()
        block.addBlock(buildCodingKeys(keyedTypes))
        block.decreaseIndent()
        block.addLine("}")
        return GeneratedCode(name: name, output: block, type: .namedType)
    }
    
    private func buildVariantCase(_ keyedType: CandidKeyedItemType) -> String {
        switch keyedType.type {
        case .null, .empty, .reserved, .option(.null), .option(.empty):
            // no associated values `case noValue`
            return "case \(keyedType.key.swiftString)"
            
        case .record(let recordKeyedTypes):
            // multiple associated values `case multipleValues(String, name: Int)`
            let associatedValues = recordKeyedTypes.map {
                if let valueName = $0.key.string {
                    return "\(valueName): \($0.type.swiftType())"
                }
                return $0.type.swiftType()
            }.joined(separator: ", ")
            return "case \(keyedType.key.swiftString)(\(associatedValues))"
            
        default:
            // single unnamed associatedValue `case singleValue(T)`
            return "case \(keyedType.key.swiftString)(\(keyedType.type.swiftType()))"
        }
    }
    
    private func buildCodingKeys(_ keyedTypes: CandidKeyedTypes) -> IndentedString {
        let block = IndentedString()
        block.addLine("enum CodingKeys: Int, CodingKey {")
        block.increaseIndent()
        for keyedType in keyedTypes {
            block.addLine("case \(keyedType.key.swiftString) = \(keyedType.key.hash)")
        }
        block.decreaseIndent()
        block.addLine("}")
        return block
    }
}



private struct GeneratedCode: Comparable {
    let name: String
    let output: IndentedString
    let type: GeneratedCodeType
    
    static func < (lhs: GeneratedCode, rhs: GeneratedCode) -> Bool { lhs.name < rhs.name }
    static func == (lhs: GeneratedCode, rhs: GeneratedCode) -> Bool { lhs.name == rhs.name }
}

private enum GeneratedCodeType {
    case typeAlias
    case namedType
}

private enum CodeGenerationCandidType {
    case `typealias`(CandidType)
    case `struct`(CandidKeyedTypes)
    case variant(CandidKeyedTypes)
}

private extension CandidType {
    var codeGenerationType: CodeGenerationCandidType {
        switch self {
        case .variant(let keyedTypes): return .variant(keyedTypes)
        case .record(let keyedTypes): return .struct(keyedTypes)
        default: return .typealias(self)
        }
    }
    
    func swiftType() -> String {
        switch self {
        case .null, .reserved, .empty: 
            return "" // ???
        case .bool: return "Bool"
        case .natural: return "BigUInt"
        case .integer: return "BigInt"
        case .natural8: return "UInt8"
        case .natural16: return "UInt16"
        case .natural32: return "UInt32"
        case .natural64: return "UInt64"
        case .integer8: return "Int8"
        case .integer16: return "Int16"
        case .integer32: return "Int32"
        case .integer64: return "Int64"
        case .float32: return "Float"
        case .float64: return "Double"
        case .text: return "String"
        case .blob: return "Data"
        case .option(let candidType): return "\(candidType.swiftType())?"
        case .vector(let candidType):
            return "[\(candidType.swiftType())]"
        case .record:
            fatalError("all records should be named by now")
        case .variant:
            fatalError("all variants should be named by now")
        case .function: return "CandidFunctionSignature"
        case .service: return "CandidServiceSignature"
        case .principal: return "CandidPrincipal"
        case .named(let name): return name
        }
    }
}

private extension CandidKeyedTypes {
    var hasUnnamedParameters: Bool { contains { $0.key.isUnnamed }}
}

private extension CandidKeyedItemType {
    func swiftString() -> String { "\(key.swiftString): \(type.swiftType())" }
}

private extension CandidContainerKey {
    var isUnnamed: Bool { string == nil }
    var swiftString: String {
        if let string = string {
            return string
        } else {
            return String("_\(hash)")
        }
    }
}

private extension CandidFunctionSignature.Parameter {
    func swiftStringForFunctionArgument(_ unnamedIndex: inout Int) -> String {
        if let name = name {
            return "\(name): \(type.swiftType())"
        }
        let string = "_ arg\(unnamedIndex): \(type.swiftType())"
        unnamedIndex += 1
        return string
    }
    
    func swiftStringForFunctionMultipleResult() -> String {
        if let name = name {
            return "\(name): \(type.swiftType())"
        }
        return type.swiftType()
    }
}

