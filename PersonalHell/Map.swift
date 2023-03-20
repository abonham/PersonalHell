//
//  Map.swift
//  MyDoom
//
//  Created by Aaron Bonham on 18/3/2023.
//

import Foundation

struct CStr_8 {
    let str: (CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar)
}

extension CStr_8: CustomDebugStringConvertible {
    var debugDescription: String {
        String(cString: [str.0, str.1, str.2, str.3, str.4, str.5, str.6, str.7, 0])
    }
}

public struct Vector2<T> {
    let x: T
    let y: T
}

struct MapThing {
    let x: Int16
    let y: Int16
    let direction: Int16
    let type: Int16
    let flags: Int16
}

struct MapLine {
    let startVertexID: Int16
    let endVertexID: Int16
    let flags: Int16
    let type: Int16
    let sectorTag: Int16
    let frontSideDef: Int16
    let backSideDef: Int16
}

struct MapSideDefinition {
    let xOffset: Int16
    let yOffset: Int16
    let upper: CStr_8
    let middle: CStr_8
    let lower: CStr_8
    let sector: Int16
}

struct MapSegment {
    let vertex1: Int16
    let vertex2: Int16
    let angle: Int16
    let line: Int16
    let side: Int16
    let offset: Int16
}

struct MapSSector {
    let count: Int16
    let firstSegment: Int16
}

struct BoundingBox {
    let top: Int16
    let bottom: Int16
    let left: Int16
    let right: Int16
}

struct MapNode {
    let partitionX: Int16
    let partitionY: Int16
    let partitionXDelta: Int16
    let partitionYDelta: Int16
    let rightBoundingBox: BoundingBox
    let leftBoundingBox: BoundingBox
    let rightChild: Int16
    let leftChild: Int16
}

struct MapSector {
    let floorHeight: Int16
    let ceilingHeight: Int16
    let floorTexture: CStr_8
    let ceilingTexture: CStr_8
    let lightLevel: Int16
    let special: Int16
    let tag: Int16
}


typealias MapReject = [UInt8]

typealias RawBlockMap = [UInt8]

enum MapSectionNames {
    static let marker = /(E[0-9]M[0-9]|MAP[0-9][0-9])/
    static let things = "THINGS"
    static let linedefs = "LINEDEFS"
    static let sidedefs = "SIDEDEFS"
    static let vertexes = "VERTEXES"
    static let segs = "SEGS"
    static let ssectors = "SSECTORS"
    static let nodes = "NODES"
    static let sectors = "SECTORS"
    static let reject = "REJECT"
    static let blockMap = "BLOCKMAP"
}

struct MapDataChunk {
    let directory: [LumpInfo]
    let data: Data
    
    static func lump(_ named: String, in directory: [LumpInfo]) -> LumpInfo {
        directory.first(where: { $0.name == named })!
    }
    
    static func lump(matching regex: some RegexComponent, in dir: [LumpInfo]) -> LumpInfo? {
        dir.first(where: { $0.name.wholeMatch(of: regex) != nil  })
    }
    
    static func lumpObjects<T>(info: LumpInfo, in data: Data) -> [T] {
        let raw = data[info.offset..<info.offset + info.size].withUnsafeBytes { $0.bindMemory(to: T.self) }
        return raw.map { $0 }
    }
    
    let marker: LumpInfo
    let things: [MapThing]
    let sidedefs: [MapSideDefinition]
    let vertexes: [Vector2<Int16>]
    let linedefs: [MapLine]
    let segments: [MapSegment]
    let ssectors: [MapSSector]
    let nodes: [MapNode]
    let sectors: [MapSector]
    let reject: MapReject
    let blockMap: RawBlockMap
    
    init(directory: [LumpInfo], data: Data) {
        self.directory = directory
        self.data = data
        marker = Self.lump(matching: MapSectionNames.marker, in: directory)!
        things = Self.lumpObjects(info: Self.lump(MapSectionNames.things, in: directory), in: data)
        sidedefs = Self.lumpObjects(info: Self.lump(MapSectionNames.sidedefs, in: directory), in: data)
        vertexes = Self.lumpObjects(info: Self.lump(MapSectionNames.vertexes, in: directory), in: data)
        linedefs = Self.lumpObjects(info: Self.lump(MapSectionNames.linedefs, in: directory), in: data)
        segments = Self.lumpObjects(info: Self.lump(MapSectionNames.segs, in: directory), in: data)
        ssectors = Self.lumpObjects(info: Self.lump(MapSectionNames.ssectors, in: directory), in: data)
        nodes = Self.lumpObjects(info: Self.lump(MapSectionNames.nodes, in: directory), in: data)
        sectors = Self.lumpObjects(info: Self.lump(MapSectionNames.sectors, in: directory), in: data)
        reject = Self.lumpObjects(info: Self.lump(MapSectionNames.reject, in: directory), in: data)
        blockMap = Self.lumpObjects(info: Self.lump(MapSectionNames.blockMap, in: directory), in: data)
    }
    
}

public struct Map {
    public typealias Vertex = (x: Int16, y: Int16)
    
    let mapData: MapDataChunk
    
    init(with directory: [LumpInfo], from wad: Data) {
        mapData = MapDataChunk(directory: directory, data: wad)
    }
}

public extension CGPoint {
    init(vertex: Map.Vertex) {
        let x = CGFloat(Int(vertex.x))
        let y = CGFloat(Int(vertex.y))
        self.init(x: x, y: y)
    }
    
    init(vertex: Vector2<Int16>) {
        let x = CGFloat(Int(vertex.x))
        let y = CGFloat(Int(vertex.y))
        self.init(x: x, y: y)
    }
}
