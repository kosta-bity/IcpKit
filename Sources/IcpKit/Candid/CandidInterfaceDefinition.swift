//
//  CandidInterfaceDefinition.swift
//
//
//  Created by Konstantinos Gaitanis on 27.06.24.
//

import Foundation

public struct CandidInterfaceDefinition {
    public struct ServiceDefinition {
        public let name: String?
        public let initialisationArguments: [CandidFunctionSignature.Parameter]?
        public let signature: CandidServiceSignature
    }
    
    public let namedTypes: [String: CandidType]
    public let service: ServiceDefinition?
    
    public func isResolved() -> Bool {
        namedTypes.values.allSatisfy { $0.isResolved(namedTypes) } &&
        service?.signature.isResolved(namedTypes) ?? true
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
