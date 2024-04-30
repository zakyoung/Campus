//
//  mapPreferences.swift
//  Campus
//
//  Created by Zak Young on 3/10/24.
//

import SwiftUI

struct mapPreferences: View {
    @EnvironmentObject var mapManager: MapManager

    var body: some View {
        VStack{
            Picker("Map Type", selection: $mapManager.selectedConfiguration){
                ForEach(mapConfig.allCases, id: \.self){ selection in
                                    Text("\(selection.rawValue)")
                                }
                            }
        }
    }
}

#Preview {
    mapPreferences()
        .environmentObject(MapManager())
}
