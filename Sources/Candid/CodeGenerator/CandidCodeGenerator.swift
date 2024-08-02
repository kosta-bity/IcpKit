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
}

public class CandidCodeGenerator {
    public init() {}
    
    public func generateSwiftCode(for interface: CandidInterfaceDefinition, nameSpace: String) throws -> String {
        let context = try CodeGenerationContext(from: interface)
        let header = buildHeader()
        let types = context.namedTypes.map { buildType($0, context.namedTypes)}
        
        let output = IndentedString()
        output.addBlock(header, newLine: true)
        output.addLine("enum \(nameSpace) {")
        output.increaseIndent()
        output.addBlock(buildTypesBlock(types), newLine: true)
        if let service = context.service {
            output.addBlock(buildServiceBlock(service), newLine: true)
        }
        output.decreaseIndent()
        output.addLine("}")
        return output.output
    }
    
    public func generateSwiftCode(for value: CandidValue, valueName: String) throws -> String {
        let context = try CodeGenerationContext(from: value)
        //let header = buildHeader()
        let types = context.namedTypes.map { buildType($0, context.namedTypes)}
        
        let output = IndentedString()
        //output.addBlock(header, newLine: true)
        output.addBlock(buildTypesBlock(types))
        output.addBlock(buildValueBlock(value, valueName, context.candidValueSimplifiedType!))
        return output.output
    }
    
    private func buildValueBlock(_ value: CandidValue, _ valueName: String, _ simplifiedType: CandidType) -> IndentedString {
        let block = IndentedString.inline("let \(valueName): \(simplifiedType.swiftType()) = ")
        block.append(value.swiftValue)
        return block
    }
    
    private func buildServiceBlock(_ service: CodeGeneratorCandidService) -> IndentedString {
        let block = IndentedString()
        block.addSwiftDocumentation(service.originalDefinition)
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
        let args = (method.signature.arguments.map { $0.swiftStringForFunctionArgument(&unnamedArgCount) } + [
            "sender: ICPSigningPrincipal? = nil",
        ]).joined(separator: ", ")
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
            clientCall = "try await client.query(method, effectiveCanister: canister, sender: sender)"
        } else {
            clientCall = "try await client.callAndPoll(method, effectiveCanister: canister, sender: sender)"
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
        typeAliases.sorted().forEach { block.addBlock($0.output, newLine: true) }
        if !typeAliases.isEmpty && !namedTypes.isEmpty { block.addLine() }
        namedTypes.sorted().forEach { block.addBlock($0.output, newLine: true) }
        return block
    }
    
    private func buildHeader() -> IndentedString {
        IndentedString(
            "//",
            "// This file was generated using CandidCodeGenerator",
            "// created: \(Date.now)",
            "//",
            "// You can modify this file if needed",
            "//",
            "",
            "import Foundation",
            "import IcpKit",
            "import Candid",
            "import BigInt"
        )
    }
        
    private func buildType(_ namedType: CandidNamedType, _ namedTypes: [CandidNamedType]) -> GeneratedCode {
        switch namedType.type.codeGenerationType {
        case .typealias(let candidType): return buildTypeAlias(namedType.name, candidType, namedType.originalDefinition)
        case .struct(let candidKeyedTypes): return buildStruct(namedType.name, candidKeyedTypes, namedType.originalDefinition)
        case .variant(let candidKeyedTypes): return buildVariant(namedType.name, candidKeyedTypes, namedType.originalDefinition, namedTypes)
        }
    }
    
    private func buildTypeAlias(_ name: String, _ type: CandidType, _ originalDefinition: String?) -> GeneratedCode {
        let output = IndentedString()
        output.addSwiftDocumentation(originalDefinition)
        output.addLine("typealias \(name) = \(type.swiftType())")
        return GeneratedCode(
            name: name,
            output: output,
            type: .typeAlias
        )
    }
    
    private func buildStruct(_ name: String, _ keyedTypes: CandidKeyedTypes, _ originalDefinition: String?) -> GeneratedCode {
        let block = IndentedString()
        block.addSwiftDocumentation(originalDefinition)
        block.addLine("struct \(name): Codable {")
        block.increaseIndent()
        for keyedType in keyedTypes {
            block.addLine("let \(keyedType.swiftString())")
        }
        if keyedTypes.hasUnnamedParameters {
            block.addLine()
            let initialiserArgs = keyedTypes.map { "\($0.key.swiftInitDefString): \($0.type.swiftType())" }.joined(separator: ", ")
            block.addLine("init(\(initialiserArgs)) {")
            block.increaseIndent()
            for arg in keyedTypes {
                block.addLine("self.\(arg.key.swiftString) = \(arg.key.swiftString)")
            }
            block.decreaseIndent()
            block.addLine("}")
            block.addLine()
            block.addBlock(buildCodingKeys(keyedTypes))
        }
        block.decreaseIndent()
        block.addLine("}")
        return GeneratedCode(name: name, output: block, type: .namedType)
    }
    
    private func buildVariant(_ name: String, _ keyedTypes: CandidKeyedTypes, _ originalDefinition: String?, _ allNamedTypes: [CandidNamedType]) -> GeneratedCode {
        let block = IndentedString()
        block.addSwiftDocumentation(originalDefinition)
        let indirect = keyedTypes.isIndirectEnum(name, allNamedTypes) ? "indirect " : ""
        block.addLine("\(indirect)enum \(name): Codable {")
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
        case .function(let signature):
            precondition(signature.arguments.count <= 1, "function arguments should have been simplified by now")
            precondition(signature.results.count <= 1, "function results should have been simplified by now")
            guard let argument = signature.arguments.first else {
                guard let result = signature.results.first else {
                    return "ICPFunctionNoArgsNoResult"
                }
                return "ICPFunctionNoArgs<\(result.type.swiftType())>"
            }
            guard let result = signature.results.first else {
                return "ICPFunctionNoResult<\(argument.type.swiftType())>"
            }
            return "ICPFunction<\(argument.type.swiftType()), \(result.type.swiftType())>"
            
        case .service: return "CandidServiceSignature"
        case .principal: return "CandidPrincipal"
        case .named(let name): return name
        }
    }
}

private extension IndentedString {
    func addSwiftDocumentation(_ originalString: String?) {
        guard let string = originalString else { return }
        for line in string.split(separator: "\n") {
            addLine("/// \(line)")
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
            return sanitize(string)
        } else {
            return "_\(hash)"
        }
    }
    /// used for init definition eg. MyType{ init(_ _0: Int, a: String) }
    var swiftInitDefString: String {
        if hasString {
            return swiftString
        } else {
            return "_ \(swiftString)"
        }
    }
    /// used for value init eg. MyType(0, a: "string")
    var swiftInitString: String {
        if hasString {
            return "\(swiftString): "
        } else {
            return ""
        }
    }
    
    private func sanitize(_ string: String) -> String {
        if Self.swiftReservedKeywords.contains(string) {
            return "`\(string)`"
        }
        return string
    }
    
    private static let swiftReservedKeywords = ["extension", "private", "public", "internal", "operator", "var", "let", "func", "default", "if", "while"]
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

private extension CandidKeyedTypes {
    func isIndirectEnum(_ name: String, _ namedTypes: [CandidNamedType]) -> Bool {
        contains { $0.type.references(name, namedTypes) }
    }
}

private extension CandidType {
    func references(_ name: String, _ namedTypes: [CandidNamedType]) -> Bool {
        switch self {
        case .option(let containedType): return containedType.references(name, namedTypes)
        case .named(let referencedName): 
            if referencedName == name { return true }
            return namedTypes[referencedName]?.references(name, namedTypes) ?? false
            
        default: return false
        }
    }
}

private extension CandidValue {
    var swiftValue: IndentedString {
        switch self {
        case .null, .reserved, .empty: return IndentedString.inline("nil")
        case .bool(let bool): return IndentedString.inline("\(bool)")
        case .natural(let bigUInt): return IndentedString.inline("\(bigUInt)")
        case .integer(let bigInt): return IndentedString.inline("\(bigInt)")
        case .natural8(let uInt8): return IndentedString.inline("\(uInt8)")
        case .natural16(let uInt16): return IndentedString.inline("\(uInt16)")
        case .natural32(let uInt32): return IndentedString.inline("\(uInt32)")
        case .natural64(let uInt64): return IndentedString.inline("\(uInt64)")
        case .integer8(let int8): return IndentedString.inline("\(int8)")
        case .integer16(let int16): return IndentedString.inline("\(int16)")
        case .integer32(let int32): return IndentedString.inline("\(int32)")
        case .integer64(let int64): return IndentedString.inline("\(int64)")
        case .float32(let float): return IndentedString.inline("\(float)")
        case .float64(let double): return IndentedString.inline("\(double)")
        case .text(let string): return IndentedString.inline("\"\(string)\"")
        case .blob(let data): return IndentedString.inline("Data.fromHex(\"\(data.hex)\")!")
            
        case .option(let option):
            if let value = option.value { return value.swiftValue }
            else { return IndentedString.inline("nil") }
            
        case .vector(let vector):
            if vector.values.isEmpty { return IndentedString.inline("[]") }
            let block = IndentedString()
            block.addLine("[")
            block.increaseIndent()
            for value in vector.values {
                block.append(value.swiftValue)
                block.append(",\n")
            }
            block.decreaseIndent()
            block.addLine("]")
            return block
            
        case .record(let record):
            if record.candidSortedItems.isEmpty { return IndentedString.inline(".init()") }
            
            let block = IndentedString(".init(")
            block.increaseIndent()
            let initValues = record.candidSortedItems.map { "\($0.key.swiftInitString)\($0.value.swiftValue.output)" }.joined(separator: ",\n")
            block.append(initValues)
            block.decreaseIndent()
            block.addLine()
            block.append(")")
            return block
            
        case .variant(let variant):
            switch variant.value {
            case .record(let record):
                // named and/or multiple associated values
                let associatedValues = record.candidSortedItems.map { "\($0.key.swiftInitString)\($0.value.swiftValue.output)" }.joined(separator: ", ")
                
                return IndentedString.inline(".\(variant.key.swiftString)(\(associatedValues))")
            case .null:
                return IndentedString.inline(".\(variant.key.swiftString)")
            default:
                // single unnamed associated value
                return IndentedString.inline(".\(variant.key.swiftString)(\(variant.value.swiftValue.output))")
            }
            
        case .principal(let candidPrincipal):
            guard let principal = candidPrincipal else { return IndentedString.inline("nil") }
            return IndentedString.inline(principal.swiftValueInit)
        
        case .function(let candidFunction):
            guard let method = candidFunction.method else {
                return IndentedString.inline("nil")
            }
            return IndentedString.inline(".init(\(method.principal.swiftValueInit), \"\(method.name)\", \(candidFunction.signature.annotations.query))")
            
        case .service(let candidService):
            fatalError()
        }
    }
}

private extension CandidPrincipal {
    var swiftValueInit: String { "try! CandidPrincipal(\"\(string)\")" }
}
