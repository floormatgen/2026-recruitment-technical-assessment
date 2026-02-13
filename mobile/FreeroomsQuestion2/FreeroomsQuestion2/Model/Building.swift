//
//  Building.swift
//  FreeroomsQuestion2
//
//  Created by Matthew Yuen on 9/2/2026.
//

struct Building: Identifiable, Hashable {
    var id: String
    var name: String
    var aliases: [String]
    var latitude: Double
    var longitude: Double
    
    var starRating: Double
    var availableRooms: Int
}
