//
//  File.swift
//  
//
//  Created by Konstantinos Gaitanis on 24.07.24.
//

import Foundation

public extension CandidType {
    /// https://internetcomputer.org/docs/current/references/candid-ref
    func isSuperType(of other: CandidType) -> Bool {
        return other.isSubType(of: self)
    }
    
    func isSubType(of other: CandidType) -> Bool {
        if self == other {
            return true
        } else if case .option(let otherOptionalType) = other,
                  self == otherOptionalType {
            // t is a subtype of opt t (unless t itself is null, opt … or reserved).
            return self != .null && self != .reserved && self.primitiveType != .option
        } else if self == .option(.empty) || self == .option(.null) {
            return true
        }
        switch self {
        case .null: return other.primitiveType == .option
        case .natural: return other.primitiveType == .integer
        case .bool, .integer, .natural8, .natural16, .natural32, .natural64, .integer8, .integer16, .integer32, .integer64, .float32, .float64, .text, .reserved, .principal:
            return false
        case .empty: return true
        case .option(let selfOptionalType):
            guard case .option(let otherOptionalType) = other else {
                return false
            }
            return selfOptionalType.isSubType(of: otherOptionalType)
            
        case .vector(let selfContainedType):
            guard case .vector(let otherContainedType) = other else {
                return false
            }
            return selfContainedType.isSubType(of: otherContainedType)
            
        case .record(let selfContainedTypes):
            guard case .record(let otherContainedTypes) = other else {
                return false
            }
            return otherContainedTypes.isRecordSuperType(of: selfContainedTypes)

        case .variant(let selfContainedTypes):
            guard case .variant(let otherContainedTypes) = other else {
                return false
            }
            return selfContainedTypes.isVariantSubType(of: otherContainedTypes)
            
        case .function(let selfSignature):
            guard case .function(let otherSignature) = other else {
                return false
            }
            return selfSignature.isSubType(of: otherSignature)
            
        case .service(let selfSignature):
            guard case .service(let otherSignature) = other else {
                return false
            }
            return selfSignature.isSubType(of: otherSignature)
            
        case .named:
            return false
        }
    }
}

private extension CandidServiceSignature {
    /// The subtypes of a service type are those service types that
    /// - possibly have additional methods,
    /// - and where the type of an existing method is changed to a subtype.
    func isSubType(of other: CandidServiceSignature) -> Bool {
        return methods.allSatisfy { $0.isSubType(of: other.methods) } &&
               other.methods.allSatisfy { otherMethod in methods.contains { $0.name == otherMethod.name } }
    }
}

private extension CandidServiceSignature.Method {
    func isSubType(of other: [CandidServiceSignature.Method]) -> Bool {
        guard let otherMethod = other.first(where: { $0.name == name }) else {
            return true
        }
        guard case .concrete(let selfSignature) = functionSignature,
              case .concrete(let otherSignature) = otherMethod.functionSignature else {
            return false
        }
        return selfSignature.isSubType(of: otherSignature)
    }
}

private extension CandidFunctionSignature {
    /// A subType is a function where
    /// - The result type list may be extended.
    /// - Existing result types may be changed to a subtype.
    ///
    /// - The parameter type list may be shortened.
    /// - The parameter type list may be extended with optional arguments (type opt …).
    /// - Existing parameter types may be changed to to a **supertype** ! In other words, the function type is **contravariant** in the argument type.
    func isSubType(of other: CandidFunctionSignature) -> Bool {
        return arguments.allSatisfy { $0.isArgumentsSubType(of: other.arguments) } &&
               results.isResultsSubType(of: other.results) &&
               annotations == other.annotations
    }
}

private extension Sequence where Element == CandidFunctionSignature.Parameter {
    func isResultsSubType(of other: any Sequence<CandidFunctionSignature.Parameter>) -> Bool {
        return allSatisfy { $0.isResultSubType(of: other) } &&
               other.allSatisfy { otherItem in contains { $0.index == otherItem.index }}
    }
}

private extension CandidFunctionSignature.Parameter {
    func isResultSubType(of other: any Sequence<CandidFunctionSignature.Parameter>) -> Bool {
        guard let otherItem = other.first(where: { index == $0.index }) else {
            return true
        }
        return type.isSubType(of: otherItem.type)
    }
    
    func isArgumentsSubType(of other: any Sequence<CandidFunctionSignature.Parameter>) -> Bool {
        guard let otherItem = other.first(where: { index == $0.index }) else {
            return type.primitiveType == .option
        }
        return type.isSuperType(of: otherItem.type)
    }
}

private extension CandidKeyedTypes {
    /// Subtypes of a record are record types that
    /// - have additional fields (of any type),
    /// - where some field’s types are changed to subtypes,
    /// - or where optional fields are removed.
    func isRecordSuperType(of other: CandidKeyedTypes) -> Bool {
        allSatisfy { $0.isRecordSuperType(other) }
    }
    
    /// Supertypes of a variant types are variants with additional tags,
    /// and maybe the type of some tags changed to a supertype.
    func isVariantSubType(of other: CandidKeyedTypes) -> Bool {
        allSatisfy { $0.isVariantSubType(other) }
    }
}

private extension CandidKeyedType {
    func isRecordSuperType(_ other: CandidKeyedTypes) -> Bool {
        guard let otherItem = other[key] else {
            //  optional fields can be removed
            return type.primitiveType == .option
        }
        return type.isSuperType(of: otherItem.type)
    }
    
    func isVariantSubType(_ other: CandidKeyedTypes) -> Bool {
        guard let otherItem = other[key] else {
            return false
        }
        return type.isSubType(of: otherItem.type)
    }
}
