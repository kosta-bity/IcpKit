//
//  ICPTransactionProviderProtocol.swift
//  IcpKit
//
//  Created by Konstantinos Gaitanis on 26.09.2024.
//

import Foundation
import IcpKit

protocol ICPTransactionProviderProtocol {
    func transactions(of user: ICPAccount) async throws -> [ICPTokenTransaction]
}
