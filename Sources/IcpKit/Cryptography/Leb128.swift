//
//  Leb128.swift
//  Runner
//
//  Created by Konstantinos Gaitanis on 26.04.23.
//

import Foundation
import BigInt

public extension ICPCryptography {
    // MARK: Encoding
    public enum Leb128 {
        public static func encodeUnsigned(_ literal: IntegerLiteralType) -> Data {
            return encodeUnsigned(BigUInt(literal))
        }
        
        public static func encodeUnsigned(_ int: UInt) -> Data {
            return encodeUnsigned(BigUInt(int))
        }
        
        public static func encodeUnsigned(_ bigInt: BigUInt) -> Data {
            var value = bigInt
            var bytes = Data()
            
            repeat {
                var byte = UInt8(value & 0x7F)
                value = value >> 7
                if value != 0 {
                    byte |= 0x80
                }
                bytes.append(byte)
            } while value != 0
            
            return bytes
        }
        
        public static func encodeSigned(_ bigInt: BigInt) -> Data {
            // TODO: Make this work with BigInts
            // the BigInt shift operator >> does not produce the same results as the int shift operator...
            // eg.    Int(-129) >> 7 = -2
            //     BigInt(-129) >> 7 = -1   // should be -2
            // shift operator on BigInt is not applied on the 2's complement for negative numbers, instead it is applied on their absolute value.
            assert(bigInt.magnitude < Int.max, "Can not leb128 encode bigInts > Int.max! shift operator not working")
            guard !bigInt.isZero else { return encodeSigned(Int(0)) }
            let integerValue = Int(truncatingIfNeeded: bigInt)
            return encodeSigned(integerValue)
        }
        
        public static func encodeSigned(_ integer: Int) -> Data {
            var value = integer
            var more = true
            var bytes = Data()
            
            while more {
                var byte = UInt8(value & 0x7F)
                value = value >> 7
                if (value == 0 && (byte >> 6) == 0) || (value == -1 && (byte >> 6) == 1) {
                    more = false
                } else {
                    byte |= 0x80
                }
                
                bytes.append(byte)
            }
            return bytes
        }
    }
}

// MARK: Decoding
public extension ICPCryptography.Leb128 {
    internal static func decodeUnsigned<T: BinaryInteger>(_ stream: ByteInputStream) throws -> T {
        //        result = 0;
        //        shift = 0;
        //        while (true) {
        //            byte = next byte in input;
        //            result |= (low-order 7 bits of byte) << shift;
        //            if (high-order bit of byte == 0)
        //                break;
        //            shift += 7;
        //        }
        var result: T = .zero
        var shift = 0
        var uint8: UInt8
        repeat {
            uint8 = try stream.readNextByte()
            result = result | (T((0x7F & uint8)) << shift)
            shift += 7
        } while uint8 & 0x80 != 0
        return result
    }
    
    internal static func decodeSigned<T: BinaryInteger>(_ stream: ByteInputStream) throws -> T {
        //        result = 0;
        //        shift = 0;
        //
        //        /* the size in bits of the result variable, e.g., 64 if result's type is int64_t */
        //        size = number of bits in signed integer;
        //
        //        do {
        //            byte = next byte in input;
        //            result |= (low-order 7 bits of byte << shift);
        //            shift += 7;
        //        } while (high-order bit of byte != 0);
        //
        //        /* sign bit of byte is second high-order bit (0x40) */
        //        if ((shift <size) && (sign bit of byte is set))
        //            /* sign extend */
        //            result |= (~0 << shift);
        var result: T = .zero
        var shift = 0
        var uint8: UInt8
        repeat {
            uint8 = try stream.readNextByte()
            result = result | (T((0x7F & uint8)) << shift)
            shift += 7
        } while uint8 & 0x80 != 0
        
        if uint8 & 0x40 != 0 {
            result = result | (~T.zero << shift)
        }
        
        return result
    }
    
    public static func decodeUnsigned<T: BinaryInteger>(_ data: Data) throws -> T {
        let stream = ByteInputStream(data)
        return try decodeUnsigned(stream)
    }
    
    public static func decodeSigned<T: BinaryInteger>(_ data: Data) throws -> T {
        let stream = ByteInputStream(data)
        return try decodeSigned(stream)
    }
}
