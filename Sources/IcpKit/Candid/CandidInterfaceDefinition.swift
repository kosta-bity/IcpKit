//
//  CandidInterfaceDefinition.swift
//
//
//  Created by Konstantinos Gaitanis on 27.06.24.
//

import Foundation

public struct CandidInterfaceDefinition: Equatable {
    public struct ServiceDefinition: Equatable {
        public enum SignatureType: Equatable {
            case concrete(CandidServiceSignature)
            case reference(String)
        }
        
        public let name: String?
        public let initialisationArguments: [CandidFunctionSignature.Parameter]?
        public let signature: SignatureType
        
        init(name: String?, initialisationArguments: [CandidFunctionSignature.Parameter]?, signature: CandidServiceSignature) {
            self.name = name
            self.initialisationArguments = initialisationArguments
            self.signature = .concrete(signature)
        }
        
        init(name: String?, initialisationArguments: [CandidFunctionSignature.Parameter]?, signatureReference: String) {
            self.name = name
            self.initialisationArguments = initialisationArguments
            self.signature = .reference(signatureReference)
        }
        
        init(name: String?, initialisationArguments: [CandidFunctionSignature.Parameter]?, signature: SignatureType) {
            self.name = name
            self.initialisationArguments = initialisationArguments
            self.signature = signature
        }
    }
    
    public let namedTypes: [String: CandidType]
    public let service: ServiceDefinition?
    
    public func isResolved() -> Bool {
        namedTypes.values.allSatisfy { $0.isResolved(namedTypes) } &&
        service?.isResolved(namedTypes) ?? true
    }
}

private extension CandidType {
    func isResolved(_ storage: [String: CandidType]) -> Bool {
        switch self {
        case .primitive: return true
        case .container(_, let containedType): return containedType.isResolved(storage)
        case .keyedContainer(_, let containedTypes): return containedTypes.allSatisfy { $0.type.isResolved(storage) }
        case .function(let signature): return signature.isResolved(storage)
        case .service(let signature): return signature.isResolved(storage)
        case .named(let name): return storage.keys.contains(name)
        }
    }
}

private extension CandidFunctionSignature {
    func isResolved(_ storage: [String: CandidType]) -> Bool {
        arguments.allSatisfy { $0.type.isResolved(storage) } &&
        results.allSatisfy { $0.type.isResolved(storage) }
    }
}

private extension CandidServiceSignature {
    func isResolved(_ storage: [String: CandidType]) -> Bool {
        methods.allSatisfy { $0.functionSignature.isResolved(storage) }
    }
}

private extension CandidInterfaceDefinition.ServiceDefinition {
    func isResolved(_ storage: [String: CandidType]) -> Bool {
        (initialisationArguments ?? []).allSatisfy { $0.type.isResolved(storage) } &&
        signature.isResolved(storage)
    }
}

private extension CandidInterfaceDefinition.ServiceDefinition.SignatureType {
    func isResolved(_ storage: [String: CandidType]) -> Bool {
        switch self {
        case .concrete(let candidServiceSignature): return candidServiceSignature.isResolved(storage)
        case .reference(let name):
            guard let stored = storage[name],
                  case .service = stored else {
                return false
            }
            return true
        }
    }
}