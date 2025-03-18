//
//  algorithm.swift
//  TI-1
//
//  Created by Pavel Playerz0redd on 18.02.25.
//

import Foundation

func convertStringToBools(str : String) -> [Bool] {
    var result : [Bool] = []
    for ch in str {
        result.append(ch == "1" ? true : false)
    }
    return result
}

func convertBoolsToString(data : [Bool]) -> String {
    var result : String = ""
    var counter = 0
    for bool in data {
        result.append(bool ? "1" : "0")
        counter += 1
        if counter % 8 == 0 {
            result.append(" ")
        }
    }
    return result
}

func createFullKey(key: inout [Bool], dataSize: Int) {
    var left = 0
    var right = 35
    if key.count > dataSize {
        key.removeSubrange(dataSize..<key.count)
    } else {
        while key.count < dataSize {
            key.append(key[left] ^ key[right])
            left += 1
            right += 1
        }
    }
}

func encrypt(key : [Bool], data : [Bool]) -> [Bool] {
    var result : [Bool] = []
    result.reserveCapacity(data.count * 8)
    for i in 0..<key.count {
        result.append(key[i] ^ data[i])
    }
    return result
}

func algorithm(data : [Bool], key : inout [Bool]) -> [Bool] {
    //let data : [Bool] = convertStringToBools(str: dataStr)
    key.reserveCapacity(data.count * 8)
    createFullKey(key: &key, dataSize: data.count)
    return encrypt(key: key, data: data)
}


extension Bool {
    static func ^(left : Bool, right : Bool) -> Bool {
        return left != right
    }
}



