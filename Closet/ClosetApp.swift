//
//  ClosetApp.swift
//  Closet
//
//  Created by Nolan Gericke on 12/17/25.
//

import SwiftUI
import SwiftData

@main
struct ClosetApp: App {
    
    init() {
        AppAppearance.configure()  // Configures Navigation Bar headers to use SF Pro Rounded
    }
    
    var sharedModelContainer: ModelContainer = {
        
        // Define which models SwiftData should manage
        let schema = Schema([
            Category.self,
            Collection.self,
            Item.self,
        ])
        
        // Get the shared App Groups container URL
        guard let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.nolangericke.closet") else {
            fatalError("Could not find App Groups container.  Did you set up App Groups in Xcode?")
        }
        
        // Create the database file path inside the container
        let storeURL = containerURL.appendingPathComponent("Closet.sqlite")
        
        // Configure SwiftData to use this location
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            url: storeURL,
            cloudKitDatabase: .none
        )
        
        // Create and return the container
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .fontDesign(.rounded)
        }
        .modelContainer(sharedModelContainer)
    }
}
