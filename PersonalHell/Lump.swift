//
//  Lump.swift
//  MyDoom
//
//  Created by Aaron Bonham on 18/3/2023.
//

import Foundation

struct Lump<T> {
    let info: LumpInfo
    let objects: [T]
    
    static func from(info: LumpInfo, wad: Data) -> Lump<T> {
        let offset = info.offset
        let end = offset + info.size
        let section = wad[offset..<end]
        return Lump(info: info, objects: section.withUnsafeBytes { $0.assumingMemoryBound(to: T.self)}.map { $0 })
    }
}
