//
//  singleSelectView.swift
//  Campus
//
//  Created by Zak Young on 2/18/24.
//

import SwiftUI

struct singleSelectView: View {
    @EnvironmentObject var mapManager: MapManager
    var buildingName: String
    var body: some View {
        HStack{
            HStack{
                Image(systemName:  mapManager.allBuildings[buildingName]?.selected ?? false ? "checkmark.square.fill" : "square")
                    .padding()
                    .foregroundColor(mapManager.allBuildings[buildingName]?.selected ?? false ? Color.green : Color.gray)
                Text(buildingName)
                    .fontWeight(.medium)
                    .font(.system(size: 20))
                Spacer()
            }
            .background(Color.white)
            Image(systemName:"heart.fill")
                .foregroundColor(mapManager.allBuildings[buildingName]?.favorited ?? false ? Color.red : Color.gray)
                .padding()
                .onTapGesture {
                    mapManager.allBuildings[buildingName]?.favorited?.toggle()
                    mapManager.updateFavorites()
                    mapManager.updateSelected()
                }
                .opacity(mapManager.allBuildings[buildingName]?.favorited ?? false ? 1: 0)
        }
        .onTapGesture {
            mapManager.allBuildings[buildingName]?.selected?.toggle()
            mapManager.updateSelected()
        }
    }
}

#Preview {
    singleSelectView(buildingName: "House building")
        .environmentObject(MapManager())
}
