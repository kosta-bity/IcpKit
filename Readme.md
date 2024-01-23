# IcpKit
A comprehensive iOS package for writing mobile applications that interact with the Internet Computer Protocol (ICP), written in Swift.
IcpKit aims at facilitating the interaction between iOS apps and the ICP blockchain.

## What does it do?
IcpKit will take care of all the encoding and serialisation required to communicate with ICP allowing to developers to focus on
the real functionality of their app and bootstrapping their development cycle.

The [ICPRequestClient](Sources/IcpKit/ICPRequest/ICPRequestClient.swift) class is the main interaction point allowing to create
and process requests to any canister.

The [Ledger Canister](Sources/IcpKit/Canisters/ICPLedgerCanister.swift) is provided as a sample implementation which also allows for easy creation of ICP Wallet apps.

## Main Functionalities
- Handles serialisation and encoding 
- Candid implementation for Swift
- Cryptographic methods applicable to ICP
- Basic ICP Models for transactions, accounts, self-authenticating principals etc.

## How to create an ICP Principal
### Starting from a seed
We recommend using the [HdWalletKit.Swift](https://github.com/horizontalsystems/HdWalletKit.Swift) from HorizontalSystems in
order to derive the public/private Key Pair from the seed.
The ICP derivation path is `_m/44'/223'/0'/0/0_`

### Starting from a public/private Key Pair
1. Create a `ICPPrincipal` instance using `ICPPrincipal(publicKey)`.
2. If you need to sign requests (eg. to send transactions) you also need to create a `ICPSigningPrincipal`.
3. The main account of this principal can be created using `ICPAccount.mainAccount(of: principal)`.

## License
**MIT License**
see [LICENSE](LICENSE)