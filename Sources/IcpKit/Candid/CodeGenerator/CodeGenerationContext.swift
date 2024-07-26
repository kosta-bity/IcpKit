//
//  CodeGenerationContext.swift
//
//
//  Created by Konstantinos Gaitanis on 26.07.24.
//

import Foundation

class CodeGenerationContext {
    private (set) var namedTypes: [String: CandidType] = [:]
    private (set) var service: CodeGeneratorCandidService?
    
    init(from interface: CandidInterfaceDefinition, serviceName: String?) throws {
        for (name, type) in interface.namedTypes {
            addNamedType(name, type)
        }
        if let service = interface.service {
            guard let finalServiceName = service.name ?? serviceName else {
                throw CandidCodeGeneratorError.noServiceName
            }
            try setService(finalServiceName, service)
        }
    }
    
    private func addNamedType(_ name: String, _ type: CandidType) {
        let simplifiedType = simplifyType(type, isNamedType: true)
        if namedTypes.keys.contains(name) {
            var index = 0
            var extendedName = "\(name)_\(index)"
            while namedTypes.keys.contains(extendedName) {
                index += 1
                extendedName = "\(name)_\(index)"
            }
            namedTypes[extendedName] = simplifiedType
        } else {
            namedTypes[name] = simplifiedType
        }
    }
    
    private func setService(_ name: String, _ service: CandidInterfaceDefinition.ServiceDefinition) throws {
        precondition(self.service == nil)
        let signature = try getConcreteServiceSignature(service.signature)
        self.service = CodeGeneratorCandidService(
            name: name,
            methods: try signature.methods.map{ .init(name: $0.name, signature: try simplifyServiceMethod($0.functionSignature)) }
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
        let simplifiedArguments = signature.arguments.map { CandidFunctionSignature.Parameter(index: $0.index, name: $0.name ,type:  simplifyType($0.type)) }
        let simplifiedResults: [CandidFunctionSignature.Parameter]
        if signature.results.count > 1 {
            var unnamedIndex = 0
            let recordResults = CandidType.record(
                signature.results.map {
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
            simplifiedResults = [.init(index: 0, name: nil, type: simplifiedRecord)]
        } else {
            simplifiedResults = signature.results.map { CandidFunctionSignature.Parameter(index: $0.index, name: $0.name ,type:  simplifyType($0.type)) }
        }
        return CandidFunctionSignature(simplifiedArguments, simplifiedResults, signature.annotations)
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
            namedTypes[newName] = type
            return newName
        }
    }
    
    private func hasName(for type: CandidType) -> String? {
        guard let existing = namedTypes.first(where: { $0.value == type }) else {
            return nil
        }
        return existing.key
    }
    
    private var unnamedItemCount = 0
    private func proposedName() -> String {
        var proposedName = "UnnamedType\(unnamedItemCount)"
        unnamedItemCount += 1
        while namedTypes.keys.contains(proposedName) {
            proposedName = "UnnamedType\(unnamedItemCount)"
            unnamedItemCount += 1
        }
        return proposedName
    }
}

struct CodeGeneratorCandidService {
    let name: String
    let methods: [Method]
    
    struct Method {
        let name: String
        let signature: CandidFunctionSignature
    }
}
