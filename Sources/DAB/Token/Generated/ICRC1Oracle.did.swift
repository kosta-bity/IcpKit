//
// This file was generated using IcpKit CandidCodeGenerator
// For more information visit https://github.com/kosta-bity/IcpKit
//

import Foundation
import IcpKit
import BigInt

enum ICRC1Oracle {
	/// type Category = variant {
	///     Sns;
	///     Known;
	///     Spam;
	///     ChainFusionTestnet;
	///     ChainFusion;
	///     Community;
	///     Native;
	/// };
	enum Category: Codable {
		case Sns
		case Spam
		case Native
		case Known
		case ChainFusionTestnet
		case ChainFusion
		case Community
	
		enum CodingKeys: String, CandidCodingKey {
			case Sns
			case Spam
			case Native
			case Known
			case ChainFusionTestnet
			case ChainFusion
			case Community
		}
	}
	
	/// type Conf = record {
	///     controllers : opt vec principal;
	///     im_canister : opt principal;
	/// };
	struct Conf: Codable {
		let controllers: [ICPPrincipal]?
		let im_canister: ICPPrincipal?
	}
	
	/// type ICRC1 = record {
	///     logo : opt text;
	///     name : text;
	///     ledger : text;
	///     category : Category;
	///     index : opt text;
	///     symbol : text;
	///     decimals : nat8;
	///     fee : nat;
	/// };
	struct ICRC1: Codable {
		let fee: BigUInt
		let decimals: UInt8
		let logo: String?
		let name: String
		let ledger: String
		let category: Category
		let index: String?
		let symbol: String
	}
	
	/// type ICRC1Request = record {
	///     logo : opt text;
	///     name : text;
	///     ledger : text;
	///     index : opt text;
	///     symbol : text;
	///     decimals : nat8;
	///     fee : nat;
	/// };
	struct ICRC1Request: Codable {
		let fee: BigUInt
		let decimals: UInt8
		let logo: String?
		let name: String
		let ledger: String
		let index: String?
		let symbol: String
	}
	

	/// service : (opt Conf) -> {
	///     get_all_icrc1_canisters : () -> (vec ICRC1) query;
	///     replace_icrc1_canisters : (vec ICRC1) -> ();
	///     store_new_icrc1_canisters : (vec ICRC1) -> ();
	///     store_icrc1_canister : (ICRC1Request) -> ();
	///     sync_controllers: () -> (vec text);
	/// }
	class Service: ICPService {
		/// get_all_icrc1_canisters : () -> (vec ICRC1) query;
		func get_all_icrc1_canisters(sender: ICPSigningPrincipal? = nil) async throws -> [ICRC1] {
			let caller = ICPQueryNoArgs<[ICRC1]>(canister, "get_all_icrc1_canisters")
			let response = try await caller.callMethod(client, sender: sender)
			return response
		}
	
		/// replace_icrc1_canisters : (vec ICRC1) -> ();
		func replace_icrc1_canisters(_ arg0: [ICRC1], sender: ICPSigningPrincipal? = nil) async throws {
			let caller = ICPCallNoResult<[ICRC1]>(canister, "replace_icrc1_canisters")
			let _ = try await caller.callMethod(arg0, client, sender: sender)
		}
	
		/// store_new_icrc1_canisters : (vec ICRC1) -> ();
		func store_new_icrc1_canisters(_ arg0: [ICRC1], sender: ICPSigningPrincipal? = nil) async throws {
			let caller = ICPCallNoResult<[ICRC1]>(canister, "store_new_icrc1_canisters")
			let _ = try await caller.callMethod(arg0, client, sender: sender)
		}
	
		/// store_icrc1_canister : (ICRC1Request) -> ();
		func store_icrc1_canister(_ arg0: ICRC1Request, sender: ICPSigningPrincipal? = nil) async throws {
			let caller = ICPCallNoResult<ICRC1Request>(canister, "store_icrc1_canister")
			let _ = try await caller.callMethod(arg0, client, sender: sender)
		}
	
		/// sync_controllers: () -> (vec text);
		func sync_controllers(sender: ICPSigningPrincipal? = nil) async throws -> [String] {
			let caller = ICPCallNoArgs<[String]>(canister, "sync_controllers")
			let response = try await caller.callMethod(client, sender: sender)
			return response
		}
	
	}

}
