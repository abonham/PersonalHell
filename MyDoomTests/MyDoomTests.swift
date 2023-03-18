//
//  MyDoomTests.swift
//  MyDoomTests
//
//  Created by Aaron Bonham on 17/3/2023.
//

import XCTest
import Foundation
@testable import MyDoom

final class MyDoomTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testOpenWAD() throws {
        _ = try WADReader.open()
    }
    
    func testReadHeaders() throws {
        let reader = try WADReader.default()
        let headers = reader.wadHeaders
        XCTAssertEqual("IWAD", headers.identification)
        XCTAssertEqual(1264, headers.numberOfLumps)
        XCTAssertEqual(4175796, headers.infoTableOffset)
    }
    
    func testReadDirectory() throws {
        let reader = try WADReader.default()
        let result = reader.directory
        XCTAssertEqual(reader.wadHeaders.numberOfLumps as Int32, Int32(result.count))
        print(result)
    }
    
    func testBundle() throws {
        let bundle = try? WADBundle()
        XCTAssertNotNil(bundle)
    }
    
    func testBundleSubscript() throws {
        let bundle = try! WADBundle()
        guard let demo1: Data = bundle["DEMO1"] else {
            XCTFail("no data")
            return
        }
        XCTAssertEqual(demo1.count, 20118)
    }
    
    func testMapVertex() throws {
        let bundle = try! WADBundle()
        guard let vertexes: Data = bundle["VERTEXES"] else {
            XCTFail()
            return
        }
        
        let map = Map(from: vertexes)
        XCTAssertEqual(467, map.vertexes.count)
        let first = map.vertexes.first!
        XCTAssertEqual(1088, first.x)
        XCTAssertEqual(-3680, first.y)
        
        let last = map.vertexes.last!
        XCTAssertEqual(2912, last.x)
        XCTAssertEqual(-4848, last.y)
    }
    
    func testBoundingBox() {
        let bundle = try! WADBundle()
        guard let vertexes: Data = bundle["VERTEXES"] else {
            XCTFail()
            return
        }
        
        let map = Map(from: vertexes)
        let points = map.vertexes.map { CGPoint(vertex: $0) }
        let box = boundedBox(points)
    }
    
    func testGetAllMapLumps() {
        let bundle = try! WADBundle()
        guard let map: [LumpInfo] = bundle["E1M1"] else {
            XCTFail()
            return
        }
        XCTAssertEqual(11, map.count)
        XCTAssertEqual("BLOCKMAP", map.last!.name)
    }
    
    func testLump() {
        let bundle = try! WADBundle()
        
        let things = Lump<MapThing>.from(info: bundle.dir.first(where: { $0.name == "THINGS" })!, wad: bundle.wad)
        XCTAssertEqual(138, things.objects.count)
        
        let vertexes = Lump<Vector2<Int16>>.from(info: bundle.dir.first(where: { $0.name == "VERTEXES" })!, wad: bundle.wad)
        XCTAssertEqual(467, vertexes.objects.count)
    }
    
    func testMapDir() throws {
        let bundle = try! WADBundle()
        let mapInfo: [LumpInfo]! = bundle["E1M1"]
        let map = MapDataChunk(directory: mapInfo, data: bundle.wad)
        let things = map.things
        XCTAssertEqual(138, things.count)
        
        let lineDefs = map.linedefs
        XCTAssertEqual(475, lineDefs.count)
        print(lineDefs)
        
        let sideDefs = map.sidedefs
        XCTAssertEqual(648, sideDefs.count)
        
        let vertexes = map.vertexes
        XCTAssertEqual(467, vertexes.count)
        
        let segDefs = map.segments
        XCTAssertEqual(732, segDefs.count)
        
        let ssectors = map.ssectors
        XCTAssertEqual(237, ssectors.count)
        
        let nodes = map.nodes
        XCTAssertEqual(236, nodes.count)
        
        let sectors = map.sectors
        XCTAssertEqual(85, sectors.count)
    }
    
    func testBoolLayout() {
        print(MemoryLayout<Bool>.size)
        print(MemoryLayout<Int>.size)
    }
}

