//
//  BuildingsScreen.swift
//  FreeroomsQuestion2
//
//  Created by Matthew Yuen on 9/2/2026.
//

import SwiftUI

struct BuildingsScreen: View {
    @State private var viewModel = ViewModel()
    
    @Environment(BuildingDataSource.self) private var buildingDataSource
    
    var body: some View {
        NavigationStack {
            Group {
                if let buildings = viewModel.buildings {
                    if !buildings.isEmpty {
                        List {
                            Section {
                                if let searchResults = viewModel.searchResults {
                                    listElements(from: searchResults)
                                } else {
                                    listElements(from: buildings)
                                }
                            } header: {
                                Text("Upper campus")
                                    .foregroundStyle(.heading)
                                    .fontWeight(.regular)
                            }
                        }
                        .overlay {
                            if viewModel.searchResults?.isEmpty == true {
                                ContentUnavailableView.search
                            }
                        }
                    } else {
                        ContentUnavailableView("No buildings found.", systemImage: Symbols.buildings)
                    }
                } else {
                    ContentUnavailableView("Loading buildings...", systemImage: Symbols.downloading)
                }
            }
            .searchable(text: $viewModel.searchText)
            .navigationTitle("Buildings")
            .navigationDestination(for: Building.self) { building in
                Text(building.id)
            }
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    HStack {
                        Button(action: {}) {
                            Image(systemName: Symbols.sort)
                                .foregroundStyle(.accent)
                        }
                        Button(action: {}) {
                            Image(systemName: Symbols.grid)
                                .foregroundStyle(.accent)
                        }
                    }
                }
            }
            .onChange(of: buildingDataSource.generation) {
                switch buildingDataSource.buildingsResult {
                case .success(let buildings):
                    self.viewModel.buildings = buildings
                    self.viewModel.encounteredError = nil
                case .failure(let error):
                    self.viewModel.buildings = nil
                    self.viewModel.encounteredError = error
                case .none:
                    self.viewModel.buildings = nil
                    self.viewModel.encounteredError = nil
                }
            }
        }
    }
    
    @ViewBuilder
    private func listElements(from buildings: [Building]) -> some View {
        ForEach(buildings) { building in
            NavigationLink(value: building) {
                BuildingListCell(building: building)
                    .frame(height: 72)
            }
        }
    }
    
}

extension BuildingsScreen {
    
    @Observable
    final class ViewModel {
        
        var buildings: [Building]?
        var encounteredError: (any Error)?
        
        private(set) var searchResults: [Building]?
        
        var searchText: String = "" {
            didSet { updateSearchResults() }
        }
        
        private func updateSearchResults() {
            guard let buildings = buildings else { return }
            guard !searchText.isEmpty else {
                searchResults = nil
                return
            }
            let lowercasedSearchText = searchText.lowercased()
            withAnimation {
                searchResults = buildings.filter { building in
                    // Check if the name contains the search text first
                    if building.name.lowercased().contains(lowercasedSearchText) { return true }
                    // Otherwise check all aliases
                    return building.aliases.contains { alias in
                        alias.lowercased().contains(lowercasedSearchText)
                    }
                }
            }
        }
        
    }
    
}

#Preview {
    let buildingDataSource = BuildingDataSource()
    TabView {
        BuildingsScreen()
            .tabItem {
                Label("Buildings", systemImage: Symbols.buildingFill)
            }
            .onAppear {
                Application.applyAppearance()
            }
            .environment(buildingDataSource)
            .task(buildingDataSource.loadBuildings)
    }
}
