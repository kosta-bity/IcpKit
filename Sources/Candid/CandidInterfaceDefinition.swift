//
//  CandidInterfaceDefinition.swift
//
//
//  Created by Konstantinos Gaitanis on 27.06.24.
//

import Foundation

public struct CandidInterfaceDefinition: Equatable {
    public init(namedTypes: [String : CandidType], service: ServiceDefinition? = nil) {
        self.namedTypes = namedTypes.map { .init(name: $0.key, type: $0.value) }.sorted()
        self.service = service
    }
    
    init(_ namedTypes: [CandidNamedType], service: ServiceDefinition? = nil) {
        self.namedTypes = namedTypes.sorted()
        self.service = service
    }
    
    public struct ServiceDefinition: Equatable {
        public enum SignatureType: Equatable {
            case concrete(CandidServiceSignature)
            case reference(String)
        }
        
        public let originalDefinition: String?
        public let name: String?
        public let initialisationArguments: [CandidFunctionSignature.Parameter]?
        public let signature: SignatureType
        
        public init(name: String?, initialisationArguments: [CandidFunctionSignature.Parameter]? = nil, signature: CandidServiceSignature, originalDefinition: String? = nil) {
            self.name = name
            self.initialisationArguments = initialisationArguments
            self.signature = .concrete(signature)
            self.originalDefinition = originalDefinition
        }
        
        public init(name: String?, initialisationArguments: [CandidFunctionSignature.Parameter]? = nil, signatureReference: String, originalDefinition: String? = nil) {
            self.name = name
            self.initialisationArguments = initialisationArguments
            self.signature = .reference(signatureReference)
            self.originalDefinition = originalDefinition
        }
        
        public init(name: String?, initialisationArguments: [CandidFunctionSignature.Parameter]? = nil, signature: SignatureType, originalDefinition: String? = nil) {
            self.name = name
            self.initialisationArguments = initialisationArguments
            self.signature = signature
            self.originalDefinition = originalDefinition
        }
        
        public static func ==(lhs: ServiceDefinition, rhs: ServiceDefinition) -> Bool {
            return lhs.name == rhs.name && lhs.initialisationArguments == rhs.initialisationArguments && lhs.signature == rhs.signature
        }
    }
    
    public let namedTypes: [CandidNamedType]
    public let service: ServiceDefinition?
    
    public func isResolved() -> Bool {
        namedTypes.allSatisfy { $0.type.isResolved(namedTypes) } &&
        service?.isResolved(namedTypes) ?? true
    }
    
    internal func removeService() -> CandidInterfaceDefinition {
        return CandidInterfaceDefinition(namedTypes)
    }
}

public struct CandidNamedType: Equatable, Comparable {
    public static func < (lhs: CandidNamedType, rhs: CandidNamedType) -> Bool {
        return lhs.name < rhs.name
    }
    
    public static func == (lhs: CandidNamedType, rhs: CandidNamedType) -> Bool {
        return lhs.name == rhs.name && lhs.type == rhs.type
    }
    
    let name: String
    let type: CandidType
    let originalDefinition: String?
    
    init(name: String, type: CandidType, originalDefinition: String? = nil) {
        self.name = name
        self.type = type
        self.originalDefinition = originalDefinition
    }
}

extension Array where Element == CandidNamedType {
    subscript (_ name: String) -> CandidType? {
        get { first { $0.name == name }?.type }
    }
    
    func contains(_ name: String) -> Bool { contains { $0.name == name} }
    
    func replacing(_ name: String, with item: CandidNamedType) -> [CandidNamedType] {
        guard let index = firstIndex(where: {$0.name == name}) else {
            return self
        }
        var copy = self
        copy[index] = item
        return copy
    }
}

private extension CandidType {
    func isResolved(_ storage: [CandidNamedType]) -> Bool {
        switch self {
        case .vector(let containedType), .option(let containedType): return containedType.isResolved(storage)
        case .record(let items), .variant(let items): return items.allSatisfy { $0.type.isResolved(storage) }
        case .function(let signature): return signature.isResolved(storage)
        case .service(let signature): return signature.isResolved(storage)
        case .named(let name): return storage.contains { $0.name == name }
        default: return true
        }
    }
}

private extension CandidFunctionSignature {
    func isResolved(_ storage: [CandidNamedType]) -> Bool {
        arguments.allSatisfy { $0.type.isResolved(storage) } &&
        results.allSatisfy { $0.type.isResolved(storage) }
    }
}

private extension CandidServiceSignature {
    func isResolved(_ storage: [CandidNamedType]) -> Bool {
        methods.allSatisfy { $0.isResolved(storage) }
    }
}

private extension CandidServiceSignature.Method {
    func isResolved(_ storage: [CandidNamedType]) -> Bool {
        switch functionSignature {
        case .concrete(let signature): return signature.isResolved(storage)
        case .reference(let name):
            guard let stored = storage[name], case .function = stored else {
            return false
            }
            return true
        }
    }
}

private extension CandidInterfaceDefinition.ServiceDefinition {
    func isResolved(_ storage: [CandidNamedType]) -> Bool {
        (initialisationArguments ?? []).allSatisfy { $0.type.isResolved(storage) } &&
        signature.isResolved(storage)
    }
}

private extension CandidInterfaceDefinition.ServiceDefinition.SignatureType {
    func isResolved(_ storage: [CandidNamedType]) -> Bool {
        switch self {
        case .concrete(let candidServiceSignature): return candidServiceSignature.isResolved(storage)
        case .reference(let name):
            guard let stored = storage[name], case .service = stored else {
                return false
            }
            return true
        }
    }
}
