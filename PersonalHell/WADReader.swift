//
//  WADReader.swift
//  MyDoom
//
//  Created by Aaron Bonham on 17/3/2023.
//

import Foundation

enum WADError: Error {
    case noFile
    case badHeader
    case badString
}

enum HeaderIndex: Int {
    case id = 0
    case lumps = 4
    case infoTable = 8
}

enum DataReader {
    static func load<T>(from data: Data, type: T.Type) -> T {
        return data.withUnsafeBytes {
            $0.load(as: T.self)
        }
    }
    
    static func read4Bytes(_ data: Data, offset: Int) throws -> Data {
        let range = Range(uncheckedBounds: (offset, offset + 4))
        return data[range]
    }
    
    static func readInt(_ data: Data, offset: Int) throws -> CInt {
        let bytes = try read4Bytes(data, offset: offset)
        return load(from: bytes, type: CInt.self)
    }
    
    static func readString(_ data: Data, offset: Int, length: Int) throws -> String {
        let range = Range(uncheckedBounds: (offset, offset + length))
        let bytes = data[range]
        var chars = bytes.map { CChar($0) }
        if chars.last! != CChar() {
            chars.append(CChar())
        }

        return String(cString: chars)
    }
}

struct WADHeaders {
    let identification: String
    let numberOfLumps: CInt
    let infoTableOffset: CInt
    
    init(data: Data) throws {
        identification = try DataReader.readString(data, offset: HeaderIndex.id.rawValue, length: 4)
        numberOfLumps = try DataReader.readInt(data, offset: HeaderIndex.lumps.rawValue)
        infoTableOffset = try DataReader.readInt(data, offset: HeaderIndex.infoTable.rawValue)
    }
}

extension WADHeaders: Equatable {}

struct LumpInfo {
    let offset: CInt
    let size: CInt
    let name: String
    let index: Int32
}

extension LumpInfo: Equatable {}

extension LumpInfo: Identifiable {
    var id: Int32 { index }
}

struct WADBundle {
    let reader: WADReader
    
    var wad: Data {
        reader.wadData
    }
    
    var dir: [LumpInfo] {
        reader.directory
    }
    
    var mapNames: [String] {
        dir.filter {
            $0.name.wholeMatch(of: MapSectionNames.marker) != nil
        }.map(\.name)
    }
    
    var maps: [String: Map] {
        Dictionary(uniqueKeysWithValues: mapNames.map { name in self[name]! }.map { ($0.first!.name, Map(with: $0, from: wad)) })
    }
    
    init(reader: WADReader? = nil) throws {
        guard let reader else {
            self.reader = try WADReader.default()
            return
        }
        self.reader = reader
    }
    
    subscript(index: String) -> Data? {
        guard let entry = dir.first(where: { $0.name == index}) else {
            return nil
        }
        
        return wad[entry.offset..<entry.offset + entry.size]
    }
    
    subscript(mapName: String) -> [LumpInfo]? {
        guard let entry = dir.firstIndex(where: { $0.name == mapName}) else {
            return nil
        }
        
        return dir[entry...entry + 10].map { $0 }
    }
}

struct WADReader {
    var wadData: Data
    var wadHeaders: WADHeaders
    var directory: [LumpInfo]
    
    static func `default`() throws -> WADReader {
        let data = try open()
        let headers = try readHeaders(wad: data)
        let directory = try generateDirectory(wad: data)
        
        return WADReader(wadData: data, wadHeaders: headers, directory: directory)
    }
    
    static func from(url: URL?) throws -> WADReader {
        let data = try open(url: url)
        let headers = try readHeaders(wad: data)
        let directory = try generateDirectory(wad: data)
        
        return WADReader(wadData: data, wadHeaders: headers, directory: directory)
    }
    
    static func open(url: URL? = nil) throws -> Data {
        guard let fileURL = url ?? Bundle.main.url(forResource: "doom1", withExtension: "wad") else {
            throw WADError.noFile
        }
        return try Data(contentsOf: fileURL)
    }
    
    static func readHeaders(wad: Data) throws -> WADHeaders {
        return try WADHeaders(data: wad)
    }
    
    static func generateDirectory(wad: Data) throws -> [LumpInfo] {
        var lumps = [LumpInfo]()
        
        let headers = try readHeaders(wad: wad)
        
        for i in 0..<headers.numberOfLumps {
            let offset = headers.infoTableOffset + (i * 16)
            
            let lumpOffset = try DataReader.readInt(wad, offset: Int(offset))
            let size = try DataReader.readInt(wad, offset: Int(offset) + 4)
            let name = try DataReader.readString(wad, offset: Int(offset) + 8, length: 8)
            let info = LumpInfo(offset: lumpOffset, size: size, name: name, index: i)
            lumps.append(info)
        }
        return lumps
    }
}

extension WADReader: Equatable {}
extension WADBundle: Equatable {}

extension Array where Element == LumpInfo {
    var totalSize: Int {
        self.reduce(0, {$0 + Int($1.size)})
    }
}
