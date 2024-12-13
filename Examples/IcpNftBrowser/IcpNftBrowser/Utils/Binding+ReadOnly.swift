//
//  Binding+ReadOnly.swift
//  IcpNftBrowser
//
//  Created by Konstantinos Gaitanis on 30.08.24.
//

import Foundation
import SwiftUI

extension Binding {
    static func readOnly(_ get: @escaping () -> Value) -> Binding<Value> {
        Binding<Value>(get: get, set: { _ in })
    }
}
