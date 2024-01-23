//
//  ICPSystemCanisters.swift
//  Runner
//
//  Created by Konstantinos Gaitanis on 25.04.23.
//

import Foundation

public enum ICPSystemCanisters {
    public static let root        = try! ICPPrincipal("r7inp-6aaaa-aaaaa-aaabq-cai")
    public static let management  = try! ICPPrincipal("aaaaa-aa")
    public static let ledger      = try! ICPPrincipal("ryjl3-tyaaa-aaaaa-aaaba-cai")
    public static let governance  = try! ICPPrincipal("rrkah-fqaaa-aaaaa-aaaaq-cai")
    public static let cycles_mint = try! ICPPrincipal("rkp4c-7iaaa-aaaaa-aaaca-cai")
    public static let ii          = try! ICPPrincipal("rdmx6-jaaaa-aaaaa-aaadq-cai")
}
