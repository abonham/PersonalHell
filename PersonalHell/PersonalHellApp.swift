//
//  PersonalHell.swift
//  MyDoom
//
//  Created by Aaron Bonham on 17/3/2023.
//

import SwiftUI
import ComposableArchitecture

struct NavFeature: ReducerProtocol {
    struct State: Equatable {
        var selection: Identified<String, String>?
    }
    
    struct Row: Equatable, Identifiable {
      var name: String
      let id: UUID
    }
    
    enum Action: Equatable {
        case selectMap(MapVizFeature.Action)
    }
    
    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .selectMap(let .selectMap(map)):
            state.selection = Identified(map, id: \.self)
            return .none
        }
    }
}

struct MapVizFeature: ReducerProtocol {
    struct State: Equatable {
        var selection: Identified<String, String>?
    }
    
    struct Row: Equatable, Identifiable {
      var name: String
      let id: UUID
    }
    
    enum Action: Equatable {
        case selectMap(String)
    }
    
    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case let .selectMap(map):
            state.selection = Identified(map, id: \.self)
            return .none
        }
    }
}


struct NavView: View {
    let store: StoreOf<MapVizFeature>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            NavigationSplitView {
                List {
                        ForEach(PersonalHellApp.wad.mapNames, id: \.self) { mapName in
                            NavigationLink(
                                        destination: IfLetStore(
                                          self.store.scope(
                                            state: \.selection?.value,
                                            action: MapVizFeature.Action.selectMap
                                          )
                                        ) { _ in
                                            MapVertexView(map: PersonalHellApp.wad.maps[mapName]!)
                                        },
                                        tag: mapName,
                                        selection: viewStore.binding(
                                          get: \.selection?.id,
                                          send: MapVizFeature.Action.selectMap(mapName)
                                        )
                            ) {
                                Text(mapName)
                            }
                        }
                }.listStyle(.sidebar)
            } detail: {
                
                                            MapVertexView(map: PersonalHellApp.map)
            }
        }
    }
}


@main
struct PersonalHellApp: App {
    
    static let wad = try! WADBundle()
    
    static let e1m1: [LumpInfo] = Self.wad["E1M1"]!
    
    static let map = Map(with: Self.e1m1, from: Self.wad.wad)
    var body: some Scene {
        WindowGroup {
            NavView(
                store: Store(
                    initialState: MapVizFeature.State(),
                    reducer: MapVizFeature()
                )
            )
        }
    }
}

struct App_Preview: PreviewProvider {
    static var previews: some View {
            NavView(
                store: Store(
                    initialState: MapVizFeature.State(),
                    reducer: MapVizFeature()
                )
            )
    }
}
