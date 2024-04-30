//
//  customLocationSheet.swift
//  Campus
//
//  Created by Zak Young on 3/10/24.
//

import SwiftUI

struct customLocationSheet: View {
    var markerName: String
    @EnvironmentObject var mapManager: MapManager
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        VStack(alignment: .leading){
            Button("Close") {
                self.presentationMode.wrappedValue.dismiss()
            }
            .padding([.leading,.bottom,.top], 20)
            HStack{
                Text(markerName)
                    .font(.system(size: 26))
                    .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                    .padding([.leading], 20)
                Spacer()
                Button("Start Route") {
                    mapManager.currentRoute.startLocation = "Current Location"
                    mapManager.currentRoute.endLocation = "\(markerName)"
                    mapManager.startRoute()
                    presentationMode.wrappedValue.dismiss()}
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.green)
                    .cornerRadius(10)
            }
            .padding()
            Spacer()
            HStack(alignment: .center, content: {
                Spacer()
                Button("Delete") {
                    mapManager.userPlacedMarkers[markerName] = nil
                    presentationMode.wrappedValue.dismiss()}
                .padding()
                .foregroundColor(.white)
                .background(Color.red)
                .cornerRadius(10)
                
            Spacer()
            })
            
        }
    }
}

#Preview {
    customLocationSheet(markerName: "Location 1")
}
