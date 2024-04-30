//
//  buildingSelectionPicker.swift
//  Campus
//
//  Created by Zak Young on 2/22/24.
//

import SwiftUI

struct buildingSelectionPicker: View {
    @EnvironmentObject var mapManager: MapManager
    var body: some View {
        Picker("Filter Results", selection: $mapManager.currentFilterSeleciton){
            ForEach(selectionOptions.allCases, id: \.self){ selection in
                                Text("\(selection.rawValue)")
                            }
                        }
                            .pickerStyle(.segmented)
    }
}

#Preview {
    buildingSelectionPicker()
        .environmentObject(MapManager())
}
