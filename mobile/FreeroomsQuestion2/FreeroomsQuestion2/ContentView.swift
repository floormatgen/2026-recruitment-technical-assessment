//
//  ContentView.swift
//  FreeroomsQuestion2
//
//  Created by Matthew Yuen on 9/2/2026.
//

import SwiftUI

struct ContentView: View {
    let buildingDataSource = BuildingDataSource()
    
    var body: some View {
        TabView {
            BuildingsScreen()
                .tabItem {
                    Label("Buildings", systemImage: Symbols.buildingFill)
                }
            MapScreen()
                .tabItem {
                    Label("Map", systemImage: Symbols.mapFill)
                }
            RoomsScreen()
                .tabItem {
                    Label("Rooms", systemImage: Symbols.door)
                }
        }
        .environment(buildingDataSource)
        .task(buildingDataSource.loadBuildings)
    }
}

#Preview {
    ContentView()
        .onAppear {
            Application.applyAppearance()
        }
}
