//
//  directionSelection.swift
//  Campus
//
//  Created by Zak Young on 2/22/24.
//

import SwiftUI

struct directionSelection: View {
    @EnvironmentObject var mapManager: MapManager
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedStartLocation: String?
    @State private var selectedDestinationLocation: String?
    var body: some View {
        VStack{
            HStack{
                Spacer()
                Text("Plan Your Route")
                    .fontWeight(.bold)
                    .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                Spacer()
            }.padding()
            Spacer()
            HStack{
                VStack{
                    Text("Starting point")
                    Picker("Start Location", selection: $selectedStartLocation){
                        Text("Select a location").tag(String?.none)
                        Text("Current Location").tag("Current Location" as String?)
                        ForEach(mapManager.allBuildings.keys.sorted(),id: \.self){ building in
                            Text(building).tag(building as String?)
                        }
                    }.pickerStyle(MenuPickerStyle())
                        .onChange(of: selectedStartLocation) {
                            mapManager.currentRoute.startLocation = $selectedStartLocation.wrappedValue
                        }
                }
                VStack(alignment: .center){
                    Text("Destination")
                    Picker("Destination", selection: $selectedDestinationLocation){
                        Text("Select a location").tag(String?.none)
                        ForEach(mapManager.allBuildings.keys.sorted(),id: \.self){ building in
                            Text(building).tag(building as String?)
                        }
                    }.pickerStyle(MenuPickerStyle())
                        .onChange(of: selectedDestinationLocation) {
                            mapManager.currentRoute.endLocation = $selectedDestinationLocation.wrappedValue
                        }
                }
            }
            Spacer()
            Button("Start Route") {mapManager.startRoute()
                presentationMode.wrappedValue.dismiss()}
                .padding()
                .foregroundColor(.white)
                .background(Color.green)
                .cornerRadius(10)
            Spacer()
        }
    }
}

#Preview {
    directionSelection()
        .environmentObject(MapManager())
}
