//
//  BuildingListCell.swift
//  FreeroomsQuestion2
//
//  Created by Matthew Yuen on 9/2/2026.
//

import SwiftUI

struct BuildingListCell: View {
    private let building: Building
    
    init(building: Building) {
        self.building = building
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: 16.0) {
            Image(systemName: Symbols.photo)
                .resizable()
                .scaledToFit()
                .frame(width: 64)
            VStack(alignment: .leading) {
                Text(building.name)
                    .font(.callout)
                    .bold()
                    .foregroundStyle(.heading)
                Text("\(building.availableRooms) rooms available")
                    .font(.caption)
                    .foregroundStyle(.accent)
            }
            Spacer()
            HStack(spacing: 2.0) {
                Text("\(building.starRating.formatted(.number.precision(.fractionLength(1))))")
                    .foregroundStyle(.accent)
                Image(systemName: Symbols.starFill)
                    .foregroundStyle(.yellow)
            }
        }
    }
    
}

#Preview {
    NavigationStack {
        List {
            let building = Building(
                id: "X-000",
                name: "Simple Building",
                aliases: [],
                latitude: 0.5,
                longitude: -0.5,
                starRating: 2.5,
                availableRooms: 41
            )
            NavigationLink(value: building) {
                BuildingListCell(building: building)
            }
        }
        .navigationDestination(for: Building.self) { building in
            Text(building.id)
        }
    }
}
