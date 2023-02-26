//
//  Extensions.swift
//  DeviceCardCompositionalLayout
//
//  Created by Rafsan Ahmad on 22/2/23.
//

extension Array {
    mutating func rearrange(from: Int, to: Int) {
        insert(remove(at: from), at: to)
    }
}
