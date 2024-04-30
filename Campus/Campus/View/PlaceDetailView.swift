//
//  PlaceDetailView.swift
//  Campus
//
//  Created by Zak Young on 2/18/24.
//

import SwiftUI

struct PlaceDetailView: View {
    @EnvironmentObject var mapManager : MapManager   
    @Environment(\.presentationMode) var presentationMode
    var place : Building
    var body: some View {
        VStack(alignment: .leading){
            Button("Close") {
                self.presentationMode.wrappedValue.dismiss()
            }
            .padding([.leading,.bottom,.top], 20)
            HStack{
                Text(place.name)
                    .font(.system(size: 26))
                    .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                    .padding([.leading], 20)
                Spacer()
                Image(systemName:"heart.fill")
                    .onTapGesture {
                        mapManager.allBuildings[place.name]?.favorited?.toggle()
                        mapManager.updateFavorites()
                        mapManager.updateSelected()
                    }
                    .foregroundColor(mapManager.allBuildings[place.name]?.favorited ?? false ? Color.red : Color.gray)
                    .font(.system(size: 36))
                    .padding([.trailing], 20)
            }
            if let year = place.yearConstructed{
                Text("Built in: " + String(year))
                    .padding([.leading], 20)
            }
            HStack{
                Spacer()
                if let photo = place.photo{
                    Image("\(photo)")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
                Spacer()
            }
            Spacer()
            
        }
    }
}
#Preview {
    PlaceDetailView(place: Building(latitude: 40.7942326850635, longitude: -77.865425957745, name: "Deike", bldgCode: 503000,photo: "deike",yearConstructed: 1965))
        .environmentObject(MapManager())
}
/*
 "latitude": 40.7942326850635,
 "longitude": -77.865425957745,
 "name": "Deike",
 "opp_bldg_code": 503000,
 "photo": "deike",
 "year_constructed": 1965
 */
