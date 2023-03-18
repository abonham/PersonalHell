//
//  MapVertexView.swift
//  MyDoom
//
//  Created by Aaron Bonham on 18/3/2023.
//

import SwiftUI

extension CGPoint: Identifiable {
    public var id: String {
        "x:\(x),y:\(y)"
    }
}

func boundedBox(_ points: [CGPoint]) -> CGRect {
    let minX = points.map(\.x).min()!
    let minY = points.map(\.y).min()!
    let maxX = points.map(\.x).max()!
    let maxY = points.map(\.y).max()!
    let dX = minX.distance(to: maxX)
    let dY = minY.distance(to: maxY)
    return .init(x: minX, y: minY, width: dX, height: dY)
}

func convert(point: CGPoint, from: CGRect, to: CGRect) -> CGPoint {
    let scaleX = to.width / from.width
    let scaleY = to.height / from.height
    return .init(x: point.x * scaleX, y: point.y * scaleY)
}

extension Array where Element == CGPoint {
    func standardize() -> [CGPoint] {
        let minX = Swift.min(self.map(\.x).min()!, 0)
        let minY = Swift.min(self.map(\.y).min()!, 0)
        return self.map {
            .init(x: $0.x + abs(minX), y: $0.y + (abs(minY)))
        }
    }
}

func remapX(_ x: CGFloat, in rect: CGRect) -> CGFloat {
    return (max(rect.minX, min(x, rect.maxX)) - rect.maxX) * (
        30 - rect.maxX - 30) / (rect.maxX - rect.minX) + 30
}

func remapY(_ y: CGFloat, in rect: CGRect) -> CGFloat {
    return (max(rect.minY, min(y, rect.maxY)) - rect.maxY) * (
        30 - rect.maxY - 30) / (rect.maxY - rect.minY) + 30
}

struct MapVertexView: View {
    let map: Map
    
    let points: [CGPoint]
    let boundingBox: CGRect
    let aspect: CGFloat
    
    init(map: Map) {
        self.map = map
        self.points = map.mapData.vertexes.map(CGPoint.init(vertex:))
        self.boundingBox = boundedBox(points)
        aspect = boundingBox.standardized.width / boundingBox.standardized.height
    }
    
    let dotSize = 6.0
    
    var body: some View {

        Canvas { context, size in
            context.fill(Path(CGRect(origin: .zero, size: size)), with: .color(.black))
            let s = points.standardize()
            
            s.forEach { point in
                let converted = convert(point: point, from: boundingBox.standardized, to: .init(origin: .zero, size: size).insetBy(dx: dotSize, dy: dotSize))
                let x = converted.x
                let y = converted.y
                    context.fill(
                        Path(ellipseIn: .init(x: x, y: y, width: dotSize, height: dotSize)),
                        with: .color(.white)
                    )
            }
            
            map.mapData.linedefs.forEach { line in
                let start = s[Int(line.startVertexID)]
                let end = s[Int(line.endVertexID)]
                let convertedStart = convert(point: start, from: boundingBox.standardized, to: .init(origin: .zero, size: size).insetBy(dx: dotSize, dy: dotSize))
                let convertedEnd = convert(point: end, from: boundingBox.standardized, to: .init(origin: .zero, size: size).insetBy(dx: dotSize, dy: dotSize))
                var path = Path()
                path.move(to: convertedStart)
                path.addLine(to: convertedEnd)
                print(start, end)
                context.stroke(path, with: .color(.red), style: StrokeStyle(lineWidth: 2))
            }
            
        }.aspectRatio(
            aspect,
            contentMode: .fit)
        .padding(32).background(Color.black)
    }
}

struct MapVertexView_Previews: PreviewProvider {
    static var previews: some View {
        MapVertexView(map: MyDoomApp.map)
    }
}
