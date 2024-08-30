//
//  PrincipalInput.swift
//  IcpNftBrowser
//
//  Created by Konstantinos Gaitanis on 30.08.24.
//

import SwiftUI
import IcpKit

struct PrincipalInput: View {
    @Binding var principalString: String
    @State private var isValid: Bool = true
    
    var body: some View {
        HStack {
            TextField(text: $principalString) { Text("Your ICP principal") }
                .onChange(of: principalString) {
                    isValid = principalString.isEmpty || ((try? ICPPrincipal(principalString)) != nil)
                    print(isValid)
                }
                .textFieldStyle(.roundedBorder)
                .textInputAutocapitalization(.never)
                .textCase(.lowercase)
                .autocorrectionDisabled()
                .border(isValid ? .gray : .red, width: 0.5)
        }
    }
}

#Preview {
    PrincipalInput(principalString: .constant("42cjv-glyli-7erx2-uovp2-vcevd-f7lqz-2qtix-eijra-5r2hk-ysmgb-rqe"))
}
