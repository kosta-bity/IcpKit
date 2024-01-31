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
The [Swift Package Manager](https://swift.org/package-manager/) is a tool for automating the distribution of Swift code
and is integrated into the `swift` compiler. It is in early development, but HdWalletKit does support its use on
supported platforms.

Once you have your Swift package set up, adding IcpKit as a dependency is as easy as adding it to
the `dependencies` value of your `Package.swift`.

```swift
dependencies: [
    .package(url: "https://github.com/kosta-bity/IcpKit.git", .upToNextMajor(from: "0.1.0"))
]
```

## What does it do?
IcpKit will take care of all the encoding and serialisation required to communicate with ICP allowing to developers to focus on
the real functionality of their app and bootstrapping their development cycle.

The [ICPRequestClient](Sources/IcpKit/ICPRequest/ICPRequestClient.swift) class is the main interaction point allowing to create
and process requests to any canister.

The [Ledger Canister](Sources/IcpKit/Canisters/ICPLedgerCanister.swift) is provided as a sample implementation which also allows for easy creation of ICP Wallet apps.

## Main Functionalities
- Handles serialisation and encoding 
- Candid implementation and serialisation/desirialisation for Swift
- CBOR serialisation
- Cryptographic methods applicable to ICP
- Basic ICP Models for transactions, accounts, self-authenticating principals etc.
- Ledger and Archive Canister implementation

## Examples

### How can I interact with a canister?
There are several ways to perform a request. Depending if it is a simple query or if the request actually changes the state
of the blockchain.

#### Define the method you wish to call :
```swift
let method = ICPMethod(
    canister: ICPSystemCanisters.ledger,
    methodName: "account_balance",
    args: .record([
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
let reponse = try await client.query(.uncertified, method, effectiveCanister: ICPSystemCanisters.ledger)
```

#### Make a call request and then poll for the response
```swift
let requestId = try await client.call(method, effectiveCanister: ICPSystemCanisters.ledger)
let reponse = try await client.pollRequestStatus(requestId: requestId, effectiveCanister: ICPSystemCanisters.ledger)
```
equivalently we can also do 
```swift
let reponse = try await client.callAndPoll(requestId: requestId, effectiveCanister: ICPSystemCanisters.ledger)
```
or even
```swift
let reponse = try await client.query(.certified, method, effectiveCanister: ICPSystemCanisters.ledger)
```
All these have the exact same result.

### How can I create an ICP Principal?
#### Starting from a seed
We recommend using the [HdWalletKit.Swift](https://github.com/horizontalsystems/HdWalletKit.Swift) from HorizontalSystems in
order to derive the public/private Key Pair from the seed.
The ICP derivation path is `m/44'/223'/0'/0/0`

#### Starting from a public/private Key Pair
1. Create a `ICPPrincipal` instance using `ICPCryptography.selfAuthenticatingPrincipal(uncompressedPublicKey:)`.
2. If you need to sign requests (eg. to send transactions) you also need to create a `ICPSigningPrincipal`.
3. The main account of this principal can be created using `ICPAccount.mainAccount(of:)`.
