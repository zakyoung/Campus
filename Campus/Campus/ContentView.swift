//
//  ContentView.swift
//  Campus
//
//  Created by Zak Young on 2/18/24.
//

import SwiftUI
// Finalizing
struct ContentView: View {
    @EnvironmentObject var mapManager: MapManager
    var body: some View {
        VStack {
            NavigationStack{
                if mapManager.currentRoute.routeActive{
                    Text("Estimated Travel Time: \(mapManager.estimateTime())")
                }
                mapView2()
                    .sheet(item: $mapManager.selectedBuilding){ selectedBuild in
                        PlaceDetailView(place: selectedBuild)
                            .presentationDetents([.fraction(0.6)])
                    }
                    .sheet(item: $mapManager.selectedMarker){ selectedMarker in
                        customLocationSheet(markerName: selectedMarker)
                    }
                    .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
                if mapManager.currentRoute.routeActive{
                    stepView()
                }
                HStack{
                    NavigationLink(destination: { selectBuildingsView() }) {
                        Image(systemName: "building.2")
                            .resizable()
                            .frame(width: 24, height: 24)
                    }
                        .padding()
                        .disabled(mapManager.currentRoute.routeActive)
                    Spacer()
                    Button(action: {
                        mapManager.selectAllLogic()
                    }) {
                        Image(systemName: mapManager.allFavoritesSelected ? "heart.fill" : "heart")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundColor(mapManager.currentRoute.routeActive ? .gray : mapManager.allFavoritesSelected ? .red : .blue)
                    }
                    .padding()
                    .disabled(mapManager.currentRoute.routeActive)
                    Spacer()
                    Button(action: {mapManager.clearEverything()}, label: {
                        Text("Clear")
                            .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                    })
                    .padding()
                    .disabled(mapManager.currentRoute.routeActive)
                    Spacer()
                    Menu{
                        mapPreferences()
                        Text("Select Map Preference")
                            .disabled(true)
                    } label:{
                        Image(systemName: "gearshape")
                            .resizable()
                            .frame(width: 24, height: 24)
                    }
                    .padding()
                    .disabled(mapManager.currentRoute.routeActive)
                    Spacer()
                    NavigationLink(destination: { directionSelection() }) {
                        Image(systemName: "mappin.and.ellipse")
                            .resizable()
                            .frame(width: 24, height: 24)
                    }
                        .padding()
                        .disabled(mapManager.currentRoute.routeActive)
                }
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
        .environmentObject(MapManager())
}

/*
 Notes:
    Mkdirections you are giving it two seperate coordinates and it will return the directions
 
    In manager.directions you can see the provideDirections function which will create a request
 
    tab view can be used to scroll through the different steps in the directions
 
    Within the route there will be the steps which you can use to display to the user.
 
    For project 8 there is a map reader that you can wrap around a map and it can be used to convert bentween CLLocationCoordinate2D and CGPoint allowing us to determine where on the screen
    the user clicked. Use MapPwoxy which has conversion functions to convert from  CGPoint -> CLLocationCoordinate2D. The code for disabling a map gesture is in the Downtown Map file adn it has to do with the interactionMode Binding. You can also look at the downtown map file to see how the map reader is being used to find out where the gesture happened.
 
    For project 8: In the downtown map file the var regions will allow you to add shapes to the map 
 
    IBeacons allow you to tell current location indoors with high accuracy.
 */
