//
// This file was generated using IcpKit CandidCodeGenerator
// For more information visit https://github.com/kosta-bity/IcpKit
//

import Foundation
import IcpKit
import BigInt

enum TestImports {
	/// type A = vec bool;
	typealias A = [Bool]
	
	/// import service TestImports2.did;
	/// type B = opt A;
	typealias B = A?
	
	
	/// type S = service {
	///     foo: (in1: int8) -> (bool) query;
	/// };
	class S: ICPService {
		/// foo: (in1: int8) -> (bool) query;
		func foo(in1: Int8, sender: ICPSigningPrincipal? = nil) async throws -> Bool {
			let caller = ICPQuery<Int8, Bool>(canister, "foo")
			let response = try await caller.callMethod(in1, client, sender: sender)
			return response
		}
	
	}
	

}
