//
//  DABTests.swift
//  
//
//  Created by Konstantinos Gaitanis on 22.08.24.
//

import XCTest
import Candid
@testable import IcpKit
import BigInt
@testable import DAB

final class DABTests: XCTestCase {
    let nftService = DABNftService()
    let tokenService = DABTokenService()
    
    func testAllCollections() async throws {
        let allCollections = try await nftService.allCollections()
        for collection in allCollections {
            if collection.canister.string == "io7gn-vyaaa-aaaak-qcbiq-cai" {
                print(collection)
            }
        }
    }
    
    func testAccountHolding() async throws {
        let nfts = try await nftService.holdings(devWallet1.principal)
        for nft in nfts {
            let details = try await nftService.actor(for: nft)!.nftDetails(nft.index)
            print(details)
        }
    }
    
    func testAllNfts() async throws {
        let allCollections = try await nftService.allCollections()
        var count: [ICPNftStandard: Int] = Dictionary(uniqueKeysWithValues: Array(ICPNftStandard.allCases).map { ($0, 0) })
        for collection in allCollections {
            count[collection.standard] = count[collection.standard]! + 1
        }
        print(count)
        
        
//        let standard = ICPNftStandard.icrc7
//        let collection = allCollections.first(where: { $0.canister.string == "auw3m-7yaaa-aaaal-qjf6q-cai" })!
//        let actor = nftService.actor(for: collection)!
//        let nfts = try await actor.allNfts()
        
        let standard2 = ICPNftStandard.ext
        let extCollections = allCollections.filter { $0.standard == standard2 }
        for extCollection in extCollections {
            let actor2 = nftService.actor(for: extCollection)!
            let nfts2 = try await actor2.allNfts()
        }
    }
    
    func testAllTokens() async throws {
        let allTokens = try await tokenService.allTokens()
        var count: [ICPTokenStandard: Int] = Dictionary(uniqueKeysWithValues: Array(ICPTokenStandard.allCases).map { ($0, 0) })
        for token in allTokens {
            count[token.standard] = count[token.standard]! + 1
        }
        print(count)
        print(allTokens.filter { $0.standard == .dip20 }.map { ($0.name, $0.canister) })
        
//        let icrc1Tokens = allTokens.filter { $0.standard == .icrc1 }
//        await withTaskGroup(of: Void.self) { group in
//            for token in icrc1Tokens {
//                let actor = tokenService.actor(for: token)!
//                group.addTask {
//                    do {
//                        try await actor.approve(.init(spender: devWallet1, amount: 0, memo: nil))
//
//                    } catch (let error) {
//                        if error is ICRC1TokenError {
//                            print("\(token.name): Approve not supported")
//                        } else if let error = error as? ICRC2.ApproveError {
//                            if case .BadFee(let expected_fee) = error {
//                                let fee = try! await actor.fee()
//                                print("\(token.name): BadFee used \(fee) but expecting \(expected_fee)")
//                            } else if case .InsufficientFunds = error {
//                                print("\(token.name): OK")
//                            } else {
//                                print("\(token.name): ApproveError: \(error)")
//                            }
//                        } else {
//                            print("\(token.name): unknown error: \(error)")
//                        }
//                    }
//                }
//            }
//            await group.waitForAll()
//        }
    }
    
    func testTokenBalance() async throws {
        let tokenHolding = try await tokenService.balance(of: devWallet2Account)
        for holding in tokenHolding {
            print("\(holding.token.name): \(holding.decimalBalance)")
        }
    }
    
    func testDip20Tokens() async throws {
        let tokens = try await tokenService.allTokens()
        let dip20Tokens = tokens.filter({ $0.standard == .dip20 })
        for dip20Token in dip20Tokens {
            let actor = tokenService.actor(for: dip20Token)!
            do {
                let balance = try await actor.balance(of: devWallet1Account)
                let metadata = try await actor.metaData()
                print(balance)
                print(metadata)
                print(dip20Token.canister)
            } catch (let error) {
                print(dip20Token.name)
                print(error)
            }
        }
    }
    
    func testTransfer() async throws {
        var tokenHolding1 = try await tokenService.balance(of: devWallet1Account)
        var tokenHolding2 = try await tokenService.balance(of: devWallet2Account)
        
        print("Balance Before:")
        print(devWallet1Name, tokenHolding1)
        print(devWallet2Name, tokenHolding2)
        
        for holding in tokenHolding1 {
            if holding.token.standard == .icrc1 { continue }
            let actor = tokenService.actor(for: holding.token)!
            let amount = BigUInt(10).power(Int(holding.token.decimals))
            let fee = try await actor.fee()
            let transferArgs = ICPTokenTransferArgs(
                sender: devWallet1,
                from: .mainAccount(of: devWallet1.principal),
                to: .mainAccount(of: devWallet2.principal),
                amount: amount,
                fee: fee,
                memo: "Test",
                createdAtTime: .now
            )
            print("Transferring \(holding.token.decimal(amount)) \(holding.token.name) from \(devWallet1Name) to \(devWallet2Name) (fee: \(holding.token.decimal(fee)))")
            //let receipt = try await actor.transfer(transferArgs)
            //print("SUCCESS! \(receipt)")
        }
        
        tokenHolding1 = try await tokenService.balance(of: devWallet1Account)
        tokenHolding2 = try await tokenService.balance(of: devWallet2Account)
        
        print("Balance After:")
        print(devWallet1Name, tokenHolding1)
        print(devWallet2Name, tokenHolding2)
    }
    
    func testTransactions() async throws {
        let tokenHolding = try await tokenService.balance(of: devWallet1Account)
        for token in tokenHolding.map({$0.token}) {
            print("\(token.name): \(token.canister)")
            let actor = tokenService.actor(for: token)!
            let transactions = try await actor.transactions(of: devWallet1Account)
            print(transactions.count)
            print(transactions)
        }
    }
}


let devWallet1Name = "Development Wallet 1"
let devWallet2Name = "Development Wallet 2"
//let devWallet1 = try! SimplePrincipal(privateKey: PrivateKeys.devWallet1, uncompressedPublicKey: PublicKeys.devWallet1)
//let devWallet2 = try! SimplePrincipal(privateKey: PrivateKeys.devWallet2, uncompressedPublicKey: PublicKeys.devWallet2)
let devWallet1 = try! SimplePrincipal(privateKey: Data(), uncompressedPublicKey: PublicKeys.devWallet1)
let devWallet2 = try! SimplePrincipal(privateKey: Data(), uncompressedPublicKey: PublicKeys.devWallet2)
let devWallet1Account = ICPAccount.mainAccount(of: devWallet1.principal)
let devWallet2Account = ICPAccount.mainAccount(of: devWallet2.principal)
