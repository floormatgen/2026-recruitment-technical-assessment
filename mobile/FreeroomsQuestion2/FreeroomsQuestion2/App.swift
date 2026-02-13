//
//  App.swift
//  FreeroomsQuestion2
//
//  Created by Matthew Yuen on 9/2/2026.
//

import SwiftUI
import UIKit

@main
struct Application: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    Self.applyAppearance()
                }
        }
    }
    
    static func applyAppearance() {
        
        // This is the best way I could find to change the Navigation Title appearance
        // This is not ideal as this doesn't show up in previews automatically
        // I could not find an API to do this with in pure SwiftUI
        let navbarAppearance = UINavigationBar.appearance()
        navbarAppearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor.heading,
        ]
        navbarAppearance.titleTextAttributes = [
            .foregroundColor: UIColor.heading,
        ]
        
    }
}

#Preview {
    ContentView()
        .onAppear {
            Application.applyAppearance()
        }
}
