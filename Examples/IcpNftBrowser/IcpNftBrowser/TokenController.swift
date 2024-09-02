//
//  TokenController.swift
//  IcpNftBrowser
//
//  Created by Konstantinos Gaitanis on 02.09.24.
//

import Foundation
import DAB

class TokenController: ObservableObject {
    @Published private (set) var tokens: [ICPToken] = []
}
