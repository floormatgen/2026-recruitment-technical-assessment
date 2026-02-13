//
//  BuildingImporter.swift
//  FreeroomsQuestion2
//
//  Created by Matthew Yuen on 9/2/2026.
//

import Foundation

nonisolated struct BuildingImporter {
    
    enum Error: Swift.Error {
        case failedToFindDataFile
    }
    
    private static let decoder = JSONDecoder()
    
    private struct _BuildingObject: Decodable {
        var id: String
        var name: String
        var aliases: [String]
        var lat: Double
        var long: Double
    }
    
    func loadBuildings() throws -> [Building] {
        let bundle = Bundle.main
        guard let dataURL = bundle.url(forResource: "BuildingData", withExtension: "json") else {
            throw Error.failedToFindDataFile
        }
        let data = try Data(contentsOf: dataURL)
        let buildingData = try Self.decoder.decode([_BuildingObject].self, from: data)
        return buildingData.map {
            Building(
                id: $0.id,
                name: $0.name,
                aliases: $0.aliases,
                latitude: $0.lat,
                longitude: $0.long,
                starRating: Double.random(in: 0...5),
                availableRooms: Int.random(in: 0...100)
            )
        }
    }
    
}
