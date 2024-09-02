//
// This file was generated using IcpKit CandidCodeGenerator
// For more information visit https://github.com/kosta-bity/IcpKit
//

import Foundation
import IcpKit
import BigInt

enum ICRC1 {
	/// // https://github.com/dfinity/ICRC-1/blob/main/standards/ICRC-1/README.md
	/// type Subaccount = blob;
	typealias Subaccount = Data
	
	
	/// type Account = record { owner : principal; subaccount : opt Subaccount; };
	struct Account: Codable {
		let owner: ICPPrincipal
		let subaccount: Subaccount?
	}
	
	/// type TransferArgs = record {
	///     from_subaccount : opt Subaccount;
	///     to : Account;
	///     amount : nat;
	///     fee : opt nat;
	///     memo : opt blob;
	///     created_at_time : opt nat64;
	/// };
	struct TransferArgs: Codable {
		let to: Account
		let fee: BigUInt?
		let memo: Data?
		let from_subaccount: Subaccount?
		let created_at_time: UInt64?
		let amount: BigUInt
	}
	
	/// type TransferError = variant {
	///     BadFee : record { expected_fee : nat };
	///     BadBurn : record { min_burn_amount : nat };
	///     InsufficientFunds : record { balance : nat };
	///     TooOld;
	///     CreatedInFuture : record { ledger_time: nat64 };
	///     Duplicate : record { duplicate_of : nat };
	///     TemporarilyUnavailable;
	///     GenericError : record { error_code : nat; message : text };
	/// };
	enum TransferError: Codable {
		case GenericError(message: String, error_code: BigUInt)
		case TemporarilyUnavailable
		case BadBurn(min_burn_amount: BigUInt)
		case Duplicate(duplicate_of: BigUInt)
		case BadFee(expected_fee: BigUInt)
		case CreatedInFuture(ledger_time: UInt64)
		case TooOld
		case InsufficientFunds(balance: BigUInt)
	
		enum CodingKeys: String, CandidCodingKey {
			case GenericError
			case TemporarilyUnavailable
			case BadBurn
			case Duplicate
			case BadFee
			case CreatedInFuture
			case TooOld
			case InsufficientFunds
		}
		enum GenericErrorCodingKeys: String, CandidCodingKey {
			case message
			case error_code
		}
		enum BadBurnCodingKeys: String, CandidCodingKey {
			case min_burn_amount
		}
		enum DuplicateCodingKeys: String, CandidCodingKey {
			case duplicate_of
		}
		enum BadFeeCodingKeys: String, CandidCodingKey {
			case expected_fee
		}
		enum CreatedInFutureCodingKeys: String, CandidCodingKey {
			case ledger_time
		}
		enum InsufficientFundsCodingKeys: String, CandidCodingKey {
			case balance
		}
	}
	
	enum UnnamedType0: Codable {
		case Ok(BigUInt)
		case Err(TransferError)
	
		enum CodingKeys: String, CandidCodingKey {
			case Ok
			case Err
		}
	}
	
	struct UnnamedType1: Codable {
		let url: String
		let name: String
	}
	
	/// type Value = variant {
	///     Nat : nat;
	///     Int : int;
	///     Text : text;
	///     Blob : blob;
	/// };
	enum Value: Codable {
		case Int(BigInt)
		case Nat(BigUInt)
		case Blob(Data)
		case Text(String)
	
		enum CodingKeys: String, CandidCodingKey {
			case Int
			case Nat
			case Blob
			case Text
		}
	}
	

	/// service: {
	///     icrc1_name : () -> (text) query;
	///     icrc1_symbol : () -> (text) query;
	///     icrc1_decimals : () -> (nat8) query;
	///     icrc1_fee : () -> (nat) query;
	///     icrc1_metadata : () -> (vec record { text; Value }) query;
	///     icrc1_total_supply : () -> (nat) query;
	///     icrc1_minting_account : () -> (opt Account) query;
	///     icrc1_balance_of : (Account) -> (nat) query;
	///     icrc1_transfer : (TransferArgs) -> (variant { Ok: nat; Err: TransferError; });
	///     icrc1_supported_standards : () -> (vec record { name : text; url : text }) query;
	/// };
	class Service: ICPService {
		/// icrc1_name : () -> (text) query;
		func icrc1_name(sender: ICPSigningPrincipal? = nil) async throws -> String {
			let caller = ICPQueryNoArgs<String>(canister, "icrc1_name")
			let response = try await caller.callMethod(client, sender: sender)
			return response
		}
	
		/// icrc1_symbol : () -> (text) query;
		func icrc1_symbol(sender: ICPSigningPrincipal? = nil) async throws -> String {
			let caller = ICPQueryNoArgs<String>(canister, "icrc1_symbol")
			let response = try await caller.callMethod(client, sender: sender)
			return response
		}
	
		/// icrc1_decimals : () -> (nat8) query;
		func icrc1_decimals(sender: ICPSigningPrincipal? = nil) async throws -> UInt8 {
			let caller = ICPQueryNoArgs<UInt8>(canister, "icrc1_decimals")
			let response = try await caller.callMethod(client, sender: sender)
			return response
		}
	
		/// icrc1_fee : () -> (nat) query;
		func icrc1_fee(sender: ICPSigningPrincipal? = nil) async throws -> BigUInt {
			let caller = ICPQueryNoArgs<BigUInt>(canister, "icrc1_fee")
			let response = try await caller.callMethod(client, sender: sender)
			return response
		}
	
		/// icrc1_metadata : () -> (vec record { text; Value }) query;
		func icrc1_metadata(sender: ICPSigningPrincipal? = nil) async throws -> [CandidTuple2<String, Value>] {
			let caller = ICPQueryNoArgs<[CandidTuple2<String, Value>]>(canister, "icrc1_metadata")
			let response = try await caller.callMethod(client, sender: sender)
			return response
		}
	
		/// icrc1_total_supply : () -> (nat) query;
		func icrc1_total_supply(sender: ICPSigningPrincipal? = nil) async throws -> BigUInt {
			let caller = ICPQueryNoArgs<BigUInt>(canister, "icrc1_total_supply")
			let response = try await caller.callMethod(client, sender: sender)
			return response
		}
	
		/// icrc1_minting_account : () -> (opt Account) query;
		func icrc1_minting_account(sender: ICPSigningPrincipal? = nil) async throws -> Account? {
			let caller = ICPQueryNoArgs<Account?>(canister, "icrc1_minting_account")
			let response = try await caller.callMethod(client, sender: sender)
			return response
		}
	
		/// icrc1_balance_of : (Account) -> (nat) query;
		func icrc1_balance_of(_ arg0: Account, sender: ICPSigningPrincipal? = nil) async throws -> BigUInt {
			let caller = ICPQuery<Account, BigUInt>(canister, "icrc1_balance_of")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
		/// icrc1_transfer : (TransferArgs) -> (variant { Ok: nat; Err: TransferError; });
		func icrc1_transfer(_ arg0: TransferArgs, sender: ICPSigningPrincipal? = nil) async throws -> UnnamedType0 {
			let caller = ICPCall<TransferArgs, UnnamedType0>(canister, "icrc1_transfer")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
		/// icrc1_supported_standards : () -> (vec record { name : text; url : text }) query;
		func icrc1_supported_standards(sender: ICPSigningPrincipal? = nil) async throws -> [UnnamedType1] {
			let caller = ICPQueryNoArgs<[UnnamedType1]>(canister, "icrc1_supported_standards")
			let response = try await caller.callMethod(client, sender: sender)
			return response
		}
	
	}

}
