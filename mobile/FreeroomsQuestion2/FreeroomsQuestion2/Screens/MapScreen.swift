//
//  MapScreen.swift
//  FreeroomsQuestion2
//
//  Created by Matthew Yuen on 11/2/2026.
//

import SwiftUI
import MapKit

struct MapScreen: View {
    
    @Environment(BuildingDataSource.self) private var buildingDataSource
    
    private var mapInitialPosition: MapCameraPosition {
        .camera(
            MapCamera(
                centerCoordinate: CLLocationCoordinate2D(
                    latitude: -33.91735175082757,
                    longitude: 151.23127026218918
                ),
                distance: 2_500
            )
        )
    }
    
    var body: some View {
        if let buildings = buildingDataSource.buildings {
            Map(initialPosition: mapInitialPosition) {
                ForEach(buildings) { building in
                    Marker(
                        building.name,
                        coordinate: .init(latitude: building.latitude, longitude: building.longitude)
                    )
                }
            }
        } else {
            if let error = buildingDataSource.loadError {
                ContentUnavailableView(
                    "Unable to load buildings",
                    systemImage: Symbols.error,
                    description: Text(error.localizedDescription)
                )
            } else {
                ContentUnavailableView(
                    "Loading buildings...",
                    systemImage: Symbols.buildings
                )
            }
        }
    }
    
}

#Preview {
    let buildingDataSource = BuildingDataSource()
    TabView {
        MapScreen()
            .tabItem {
                Label("Map", systemImage: Symbols.mapFill)
            }
            .onAppear {
                Application.applyAppearance()
            }
            .environment(buildingDataSource)
            .task(buildingDataSource.loadBuildings)
    }
}
