//
//  CampusApp.swift
//  Campus
//
//  Created by Zak Young on 2/18/24.
//

import SwiftUI

@main
struct CampusApp: App {
    @StateObject var mapManager: MapManager = MapManager()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(mapManager)
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
                    mapManager.saveBuildingStates()
                }
        }
    }
}
