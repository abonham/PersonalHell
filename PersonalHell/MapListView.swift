//
//  ContentView.swift
//  MyDoom
//
//  Created by Aaron Bonham on 17/3/2023.
//

import SwiftUI

extension BinaryInteger {
    func toHexString() -> String {
        return "0x" + .init(self, radix: 16).uppercased()
    }
    
    func toByteString() -> String {
        ByteCountFormatter().string(fromByteCount: Int64(self))
    }
    
    func toString() -> String {
        .init(self, radix: 10)
    }
}

struct ContentView: View {
    let wad = try! WADReader.default()
    
    var body: some View {
            List {
                        HStack {
                            Text("Index").frame(minWidth: 20)
                            Text("Name").frame(minWidth: 120, alignment: .leading)
                            Text("Offset").frame(minWidth: 80, alignment: .leading)
                            Text("Size").frame(minWidth: 80, alignment: .leading)
                        }.font(.headline)
                    ForEach(wad.directory) { lump in
                        HStack {
                            Text(lump.index.toString()).frame(minWidth: 20)
                            Text(lump.name).frame(minWidth: 120, alignment: .leading)
                            Text(lump.offset.toHexString()).frame(minWidth: 80, alignment: .leading).monospaced()
                            Text(lump.size.toByteString()).frame(minWidth: 80, alignment: .leading).monospaced()

                        }
                    }
            }
            .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
