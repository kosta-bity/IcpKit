# IcpKit
A comprehensive iOS package for writing mobile applications that interact with the Internet Computer Protocol (ICP), written in Swift.
IcpKit aims at facilitating the interaction between iOS apps and the ICP blockchain.

For more information about ICP Development, we recommend starting from https://internetcomputer.org/docs/current/references/

## Contributors
This Package has been built by [Bity SA](https://bity.com) with the help of the [DFinity Foundation Developer Grant Program](https://dfinity.org/grants).

## License
**MIT License** is applicable for all Swift Code (see [LICENSE](LICENSE)).

The BLS12381 Rust Library is licensed by Levi Feldman (see [LICENSE](Sources/bls12381/LICENSE)).

## Installation
### Swift Package Manager
Adding IcpKit as a dependency is as easy as adding it to the `dependencies` value of your `Package.swift`.

```swift
...
dependencies: [
    .package(url: "https://github.com/kosta-bity/IcpKit.git", .upToNextMajor(from: "0.2.0"))
]
...
```

The `IcpKit` package defines two libraries `Candid` and `IcpKit`. `Candid` implements the Candid specification and `IcpKit` implements the communication with canisters. To use in your code `import Candid` and/or `import IcpKit`.

### CodeGenerator Command Line Tool

To use the `CodeGenerator`, you must first clone the project  `git clone https://github.com/kosta-bity/IcpKit` and then you can either use Swift to compile and run or build the executable yourself.
#### Build the executable

from the `IcpKit` root folder :

`./compile_code_generator.sh`

You will find the executable inside the folder `.build/release/CodeGenerator`

#### Use Swift to execute

Alternatively you can use swift to run it from the `IcpKit` root folder :

`swift run CodeGenerator`

## What does it do?

IcpKit will take care of all the encoding and serialisation required to communicate with ICP allowing to developers to focus on
the real functionality of their app and bootstrapping their development cycle.

The [ICPRequestClient](Sources/IcpKit/ICPRequest/ICPRequestClient.swift) class is the main interaction point allowing to create
and process requests to any canister.

The [Ledger Canister](Sources/IcpKit/Canisters/ICPLedgerCanister.swift) is provided as a sample implementation which also allows for easy creation of ICP Wallet apps.

## Main Functionalities
- Parsing .did files and generating Swift code from the definitions
- Command Line tool for generating the code
- CandidEncoder and CandidDecoder for converting any Encodable/Decodable to a CandidValue
- Candid Serialisation and encoding 
- Candid implementation and serialisation/deserialisation for Swift
- CBOR serialisation
- Cryptographic methods applicable to ICP
- Basic ICP Models for transactions, accounts, self-authenticating principals etc.
- Ledger and Archive Canister implementation

## Candid Interface Definition files (.did)
A canister is defined by all the types and methods used to interact with it. Most canisters publish their definition in the `.did` format defined [here](https://github.com/dfinity/candid/blob/master/spec/Candid.md#candid-specification). 

IcpKit can parse these files and generate Swift code that can be included in your iOS/Mac Project to interact with the canister. This effectively abstracts away all technical details regarding the communication.

### A short example
Here is a simple interface:

```candid
type MyVector = vec opt bool;

service: { 
    foo: (input: MyVector; sorted: bool) -> (record { name: text; count: int8 }) query
};

```

Using the command `CodeGenerator -n SimpleExample MyDid.did` we get the `SimpleExample.swift` file with these contents:

```swift
enum SimpleExample {
	typealias MyVector = [Bool?]
    
	struct UnnamedType0: Codable {
		let name: String
		let count: Int8
	}  
	class Service: ICPService {
		func foo(input: MyVector, sorted: Bool) async throws -> UnnamedType0 {
			let caller = ICPQuery<CandidTuple2<MyVector, Bool>, Bool>(canister, "foo")
			let response = try await caller.callMethod(.init(input, sorted), client, sender: sender)
			return response
		}
	}
}
```

We can then add this file to our project and use it anywhere in our code as follows:

```swift
let client = ICPRequestClient()
let myService = SimpleExample.Service("aaaaa-aa", client)
let myVector: SimpleExample.MyVector = [true, false, nil]
let record = try await myService.foo(input: myVector, sorted: false)
print(record.name)
print(record.count)
```

The code generated is completely type safe and avoids common mistakes such as wrong number types etc...

### Swift/Candid Encoding Rules

| Candid | Swift | Notes |
| ----------- | ----------- | --------- |
| `bool` | `Bool` | |
| `text` | `String` | utf8 encoding |
| `int` | `BigInt` | |
| `nat` | `BigUInt` | |
| `int<n>` | `Int<n>` | `n = 8, 16, 32, 64` |
| `nat<n>` | `UInt<n>` | `n = 8, 16, 32, 64` |
| `blob` | `Data` | |
| `opt <candid_type>` | `<swift_type>?` | Because of limitations in the Swift compiler, the contained type can only be fully encoded when a value is present. When no value is present, we can only encode up to one level of optionality for simple types. Optional Structs with nil value are encoded as empty. <br />`CandidEncoder().encode(Bool?.none) // .option(.bool) (correct)`<br />`CandidEncoder().encode(Bool??.none) // .option(.option(.empty)) (wrong, only first level of optionality is correct)`<br />`CandidEncoder().encode(MyStruct?.none) // .option(.empty) (wrong, nil Structs can not be determined)` |
| `vec <candid_type>` | `[<swift_type>]` |  |
| `record` | `struct <name>: Codable { ... }` | Every record is encoded/decoded to a Swift Codable `struct`. Each record item corresponds to a struct member value with the same name. If the candid item is keyed only by number then the name is `_<number>`.<br />`struct MyStruct: Codable { let a: Bool; let b: String? }` is encoded to `record { a: bool; b: opt text; }` and `record { bool; text; }` decodes to `struct MyStruct2: Codable { let _0: Bool; let _1: String }` |
| `variant` | `enum <name>: Codable { ... }` | Every variant is encoded/decoded to a Swift Codable `enum`. Each variant case corresponds to an enum case with the same name. Associated values are attached to each case using their names when available.<br />`variant { winter, summer }` encodes to `enum Season: Codable { case winter, summer }`<br />`variant { status: int; error: bool; }` encodes to `enum Status { case status(Int); case error(Bool) }` |
| `function` | `CandidFunctionProtocol` | Automatic encoding of Swift functions to a Candid Value is not supported because we can not deduce the function signature from the Swift Types without a value. This is due to Swift's Type system limitations. Decoding is allowed however. |
| `service` | `CandidServiceProtocol` | Encoding is not supported for the same reasons as for functions. |
| `principal` | `CandidPrincipal` |  |
| `null` | `nil` |  |
| `empty` | `nil` |  |
| `reserved` | `nil` |  |

## Examples

### How can I manually write code to interact with a canister?
There are several ways to perform a request. Depending if it is a simple query or if the request actually changes the state of the blockchain.

#### Define the method you wish to call :
```swift
let method = ICPMethod(
    canister: ICPSystemCanisters.ledger,
    methodName: "account_balance",
    arg: .record([
        "account": .blob(account.accountId)
    ])
)
```
#### Make the a simple query request:
```swift
let response = try await client.query(method, effectiveCanister: ICPSystemCanisters.ledger)
```
equivalently we can also do
```swift
let response = try await client.query(.uncertified, method, effectiveCanister: ICPSystemCanisters.ledger)
```

#### Make a call request and then poll for the response
```swift
let requestId = try await client.call(method, effectiveCanister: ICPSystemCanisters.ledger)
let response = try await client.pollRequestStatus(requestId: requestId, effectiveCanister: ICPSystemCanisters.ledger)
```
equivalently we can also do 
```swift
let response = try await client.callAndPoll(requestId: requestId, effectiveCanister: ICPSystemCanisters.ledger)
```
or even
```swift
let response = try await client.query(.certified, method, effectiveCanister: ICPSystemCanisters.ledger)
```
All these have the exact same result.

### How can I create an ICP Principal?
#### Starting from a seed
We recommend using the [HdWalletKit.Swift](https://github.com/horizontalsystems/HdWalletKit.Swift) from HorizontalSystems in order to derive the public/private Key Pair from the seed. The ICP derivation path is `m/44'/223'/0'/0/0`

#### Starting from a public/private Key Pair
1. Create a `ICPPrincipal` instance using `ICPCryptography.selfAuthenticatingPrincipal(uncompressedPublicKey:)`.
2. If you need to sign requests (eg. to send transactions) you also need to create a `ICPSigningPrincipal`.
3. The main account of this principal can be created using `ICPAccount.mainAccount(of:)`.
