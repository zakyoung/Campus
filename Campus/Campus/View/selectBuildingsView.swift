//
//  selectBuildingsView.swift
//  Campus
//
//  Created by Zak Young on 2/18/24.
//

import SwiftUI

struct selectBuildingsView: View {
    @EnvironmentObject var mapManager: MapManager
    var body: some View {
        VStack{
            buildingSelectionPicker()
            List{
                ForEach(mapManager.getBuildingsGivenSelection().keys.sorted(),id: \.self){ name in
                    singleSelectView(buildingName: name)
                        .listRowInsets(EdgeInsets())
                }
            }.listStyle(PlainListStyle())
                .navigationTitle(Text("Buildings"))
        }
    }
}

#Preview {
    selectBuildingsView()
        .environmentObject(MapManager())
}
