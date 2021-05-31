//
//  Function.swift
//  TestTMDB
//
//  Created by user on 24/03/21.
//

import Foundation

func address<T: AnyObject>(_ o: T) -> Int {
    return unsafeBitCast(o, to: Int.self)
}


func addressString<T: AnyObject>(_ o: T) -> String {
    return String(format: "%p", address(o))
}
