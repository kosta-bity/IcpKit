//
//  ICPTokenMetadata.swift
//  
//
//  Created by Konstantinos Gaitanis on 26.08.24.
//

import Foundation
import BigInt

public struct ICPTokenMetadata {
    public let name: String
    public let symbol: String
    public let decimals: Int
    public let totalSupply: BigUInt
    public let logo: URL?
    public let fee: BigUInt?
}

// DIP20
//--'fee' : bigint,
//--'decimals' : number,
//'owner' : Principal,
//--'logo' : string,
//--'name' : string,
//--'totalSupply' : bigint,
//--'symbol' : string,

// DRC20
//--symbol: string;
//--decimals: number;
//--fee: bigint;
//--name: string;
//--logo?: string;
//--totalSupply: bigint;

// EXT
//--name: string;
//--decimals: number;
//--symbol: string;
//--fee?: number;
