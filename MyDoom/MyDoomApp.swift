//
//  MyDoomApp.swift
//  MyDoom
//
//  Created by Aaron Bonham on 17/3/2023.
//

import SwiftUI

struct State {
    let selectedMap: String? = nil
}

@main
struct MyDoomApp: App {
    
    static let wad = try! WADBundle()
    
    static let e1m1: [LumpInfo] = Self.wad["E1M1"]!
    
    static let map = Map(with: Self.e1m1, from: Self.wad.wad)
    var body: some Scene {
        WindowGroup {
            MapVertexView(map: Self.map)
        }
    }
}
