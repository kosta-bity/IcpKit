//
//  CodeGenerationContext.swift
//
//
//  Created by Konstantinos Gaitanis on 26.07.24.
//

import Foundation

class CodeGenerationContext {
    private (set) var namedTypes: [CandidNamedType] = []
    private (set) var service: CodeGeneratorCandidService?
    private (set) var candidValueSimplifiedType: CandidType?
    
    init(from interface: CandidInterfaceDefinition) throws {
        let swiftSanitizedInterface = replacingReservedKeywords(interface)
        for namedType in swiftSanitizedInterface.namedTypes {
            addNamedType(namedType)
        }
        if let service = swiftSanitizedInterface.service {
            let finalServiceName = service.name ?? "Service"
            try setService(finalServiceName, service)
        }
    }
    
    init(from value: CandidValue) throws {
        let simplifiedType = simplifyType(value.candidType, isNamedType: false)
        candidValueSimplifiedType = simplifiedType
    }
    
    private static let swiftReservedKeywords = ["Data", "Int8",  "UInt8", "Int16",  "UInt16", "Int32",  "UInt32", "Int64",  "UInt64", "Int",  "UInt", "Bool", "String", "nil", "Optional", "Array", "Sequence", "Collection"]
    private func replacingReservedKeywords(_ interface: CandidInterfaceDefinition) -> CandidInterfaceDefinition {
        var sanitized = interface
        for namedType in interface.namedTypes {
            if Self.swiftReservedKeywords.contains(namedType.name) {
                sanitized = sanitized.replacing(namedType.name, with: "C_\(namedType.name)")
            }
        }
        
        return sanitized
    }
    
    private func addNamedType(_ namedType: CandidNamedType) {
        let simplifiedType = simplifyType(namedType.type, isNamedType: true)
        if namedTypes.contains(namedType.name) {
            var index = 0
            var extendedName = "\(namedType.name)_\(index)"
            while namedTypes.contains(extendedName) {
                index += 1
                extendedName = "\(namedType.name)_\(index)"
            }
            let namedType = CandidNamedType(name: extendedName, type: simplifiedType, originalDefinition: namedType.originalDefinition)
            namedTypes.append(namedType)
        } else {
            namedTypes.append(.init(name: namedType.name, type: simplifiedType, originalDefinition: namedType.originalDefinition))
        }
    }
    
    private func setService(_ name: String, _ service: CandidInterfaceDefinition.ServiceDefinition) throws {
        precondition(self.service == nil)
        let signature = try getConcreteServiceSignature(service.signature)
        self.service = CodeGeneratorCandidService(
            name: name,
            methods: try signature.methods.map{ .init(name: $0.name, signature: try simplifyServiceMethod($0.functionSignature)) },
            originalDefinition: service.originalDefinition
        )
    }
    
    private func getConcreteServiceSignature(_ signatureType: CandidInterfaceDefinition.ServiceDefinition.SignatureType) throws -> CandidServiceSignature {
        switch signatureType {
        case .concrete(let serviceSignature):
            return serviceSignature
        case .reference(let name):
            guard let referencedType = namedTypes[name],
                  case .service(let referencedSignature) = referencedType  else {
                throw CandidCodeGeneratorError.invalidServiceReference
            }
            return referencedSignature
        }
    }
    
    private func simplifyServiceMethod(_ functionSignatureType: CandidServiceSignature.Method.FunctionSignatureType) throws -> CandidFunctionSignature {
        switch functionSignatureType {
        case .concrete(let functionSignature):
            return simplifyFunctionSignature(functionSignature)
        case .reference(let name):
            guard let referencedType = namedTypes[name],
                  case .function(let functionSignature) = referencedType else {
                throw CandidCodeGeneratorError.invalidFunctionReference
            }
            return functionSignature
        }
    }
    
    private func simplifyType(_ type: CandidType, isNamedType: Bool = false) -> CandidType {
        switch type {
        case .option(let optionalType): return .option(simplifyType(optionalType))
        case .vector(let containedType): return .vector(simplifyType(containedType))
        case .record(let keyedTypes):
            let simplified = CandidType.record(simplifyRecordKeyedTypes(keyedTypes))
            return addOrSimplify(simplified, isNamedType: isNamedType)
            
        case .variant(let keyedTypes):
            let simplified = CandidType.variant(simplifyVariantKeyedTypes(keyedTypes))
            return addOrSimplify(simplified, isNamedType: isNamedType)
            
        case .function(let signature):
            return .function(simplifyFunctionSignature(signature))
            
        case .service(let signature):
            return .service(simplifyServiceSignature(signature))
            
        default: return type
        }
    }
    
    private func addOrSimplify(_ type: CandidType, isNamedType: Bool) -> CandidType {
        if isNamedType {
            if let existing = hasName(for: type) {
                return .named(existing)
            }
            return type
            
        } else {
            let addedName = addUnnamedType(type)
            return .named(addedName)
        }
    }
    
    private func simplifyRecordKeyedTypes(_ keyedTypes: CandidKeyedTypes) -> CandidKeyedTypes {
        CandidKeyedTypes(keyedTypes.map { CandidKeyedItemType($0.key, simplifyType($0.type)) })
    }
    
    private func simplifyVariantKeyedTypes(_ keyedTypes: CandidKeyedTypes) -> CandidKeyedTypes {
        CandidKeyedTypes(keyedTypes.map {
            if case .record(let associatedValues) = $0.type {
                // variant records represent the names of associated values. keep the record but simplify each associated value
                return CandidKeyedItemType($0.key, .record(simplifyRecordKeyedTypes(associatedValues)))
            } else {
                return CandidKeyedItemType($0.key, simplifyType($0.type))
            }
        })
    }
    
    private func simplifyFunctionSignature(_ signature: CandidFunctionSignature) -> CandidFunctionSignature {
        let simplifiedArguments = simplifyFunctionParameters(signature.arguments)
        let simplifiedResults = simplifyFunctionParameters(signature.results)
        return CandidFunctionSignature(simplifiedArguments, simplifiedResults, signature.annotations)
    }
    
    private func simplifyFunctionParameters(_ parameters: [CandidFunctionSignature.Parameter]) -> [CandidFunctionSignature.Parameter] {
        guard parameters.count > 1 else {
            return parameters.map { CandidFunctionSignature.Parameter(index: $0.index, name: $0.name ,type:  simplifyType($0.type)) }
        }
        var unnamedIndex = 0
        let recordResults = CandidType.record(
            parameters.map {
                if let name = $0.name {
                    return CandidKeyedItemType(name, $0.type)
                } else {
                    let item = CandidKeyedItemType(hashedKey: unnamedIndex, type: $0.type)
                    unnamedIndex += 1
                    return item
                }
            }
        )
        let simplifiedRecord = simplifyType(recordResults)
        return [.init(index: 0, name: nil, type: simplifiedRecord)]
    }
    
    private func simplifyServiceSignature(_ signature: CandidServiceSignature) -> CandidServiceSignature {
        return CandidServiceSignature(signature.methods.map {
            if case .concrete(let functionSignature) = $0.functionSignature {
                return .init(name: $0.name, functionSignature: simplifyFunctionSignature(functionSignature))
            } else {
                return $0
            }
            
        })
    }
    
    private func addUnnamedType(_ type: CandidType) -> String {
        if let existing = hasName(for: type) {
            return existing
            
        } else {
            let newName = proposedName()
            namedTypes.append(.init(name: newName, type: type))
            return newName
        }
    }
    
    private func hasName(for type: CandidType) -> String? {
        guard let existing = namedTypes.first(where: { $0.type == type }) else {
            return nil
        }
        return existing.name
    }
    
    private var unnamedItemCount = 0
    private func proposedName() -> String {
        var proposedName = "UnnamedType\(unnamedItemCount)"
        unnamedItemCount += 1
        while namedTypes.contains(proposedName) {
            proposedName = "UnnamedType\(unnamedItemCount)"
            unnamedItemCount += 1
        }
        return proposedName
    }
}

struct CodeGeneratorCandidService {
    let name: String
    let methods: [Method]
    let originalDefinition: String?
    
    struct Method {
        let name: String
        let signature: CandidFunctionSignature
    }
}

private extension CandidInterfaceDefinition {
    func replacing(_ name: String, with newName: String) -> CandidInterfaceDefinition {
        guard let namedType = namedTypes.first(where: { $0.name == name }) else { return self }
        let replaced = namedTypes.replacing(name, with: .init(name: newName, type: namedType.type, originalDefinition: namedType.originalDefinition))
        let replacedReferences = replaced.map { CandidNamedType(name: $0.name, type: $0.type.replacing(name, with: newName), originalDefinition: $0.originalDefinition)}
        
        let replacedService = service?.replacing(name, with: newName)
        
        return CandidInterfaceDefinition(replacedReferences, service: replacedService)
    }
}

private extension CandidType {
    func replacing(_ name: String, with newName: String) -> CandidType {
        switch self {
        case .vector(let containedType):
            return .vector(containedType.replacing(name, with: newName))
        case .option(let containedType):
            return .option(containedType.replacing(name, with: newName))
        case .record(let keyedTypes):
            return .record(keyedTypes.replacing(name, with: newName))
        case .variant(let keyedTypes):
            return .variant(keyedTypes.replacing(name, with: newName))
        case .function(let signature):
            return .function(signature.replacing(name, with: newName))
        case .service(let signature):
            return .service(signature.replacing(name, with: newName))
        case .named(let selfName):
            guard selfName == name else { return self }
            return .named(newName)
        default: return self
        }
    }
}

private extension CandidKeyedTypes {
    func replacing(_ name: String, with newName: String) -> CandidKeyedTypes {
        return CandidKeyedTypes(items.map { CandidKeyedItemType($0.key, $0.type.replacing(name, with: newName))})
    }
}

private extension CandidFunctionSignature {
    func replacing(_ name: String, with newName: String) -> CandidFunctionSignature {
        return CandidFunctionSignature(
            arguments.map { $0.replacing(name, with: newName) },
            results.map { $0.replacing(name, with: newName) },
            annotations
        )
    }
}

private extension CandidFunctionSignature.Parameter {
    func replacing(_ name: String, with newName: String) -> CandidFunctionSignature.Parameter {
        guard self.name == name else { return self }
        return .init(index: index, name: newName, type: type)
    }
}

private extension CandidServiceSignature {
    func replacing(_ name: String, with newName: String) -> CandidServiceSignature {
        return .init(methods.map { $0.replacing(name, with: newName) })
    }
}

private extension CandidServiceSignature.Method {
    func replacing(_ name: String, with newName: String) -> CandidServiceSignature.Method {
        switch functionSignature {
        case .reference(let referencedName):
            guard referencedName == name else { return self }
            return .init(name: self.name, signatureType: .reference(newName))
        case .concrete(let signature):
            return .init(name: self.name, functionSignature: signature.replacing(name, with: newName))
        }
    }
}

private extension CandidInterfaceDefinition.ServiceDefinition {
    func replacing(_ name: String, with newName: String) -> CandidInterfaceDefinition.ServiceDefinition {
        switch signature {
        case .reference(let referencedName):
            guard referencedName == name else { return self }
            return .init(name: self.name, initialisationArguments: initialisationArguments, signatureReference: newName, originalDefinition: originalDefinition)
        case .concrete(let signature):
            return .init(name: self.name, initialisationArguments: initialisationArguments, signature: signature.replacing(name, with: newName), originalDefinition: originalDefinition)
        }
    }
}
