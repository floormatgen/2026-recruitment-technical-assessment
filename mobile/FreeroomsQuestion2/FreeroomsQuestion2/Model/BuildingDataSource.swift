//
//  BuildingDataSource.swift
//  FreeroomsQuestion2
//
//  Created by Matthew Yuen on 11/2/2026.
//

import Foundation
import Observation

@Observable
final class BuildingDataSource {
    
    enum Source {
        case bundle(Bundle, name: String)
        case url(URL)
        case data(Date)
    }
    
    private(set) var buildingsResult: Result<[Building], any Error>?
    
    var buildings: [Building]? {
        try? buildingsResult?.get()
    }
    
    var loadError: (any Error)? {
        guard case .failure(let error) = buildingsResult else { return nil }
        return error
    }
    
    private(set) var generation: UUID
    
    private let importer: BuildingImporter
    
    init() {
        self.importer = BuildingImporter()
        self.generation = UUID()
    }
    
    func loadBuildings() async {
        do {
            self.buildingsResult = .success(try await _loadBuildings())
        } catch {
            self.buildingsResult = .failure(error)
        }
        self.generation = UUID()
    }
    
    @concurrent // If the file is large we don't want it to block the main thread
    private func _loadBuildings() async throws -> [Building] {
        let importer = BuildingImporter()
        return try importer.loadBuildings()
    }
    
}
