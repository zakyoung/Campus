//
//  mapView.swift
//  Campus
//
//  Created by Zak Young on 2/18/24.
//

import SwiftUI
import MapKit
struct mapView: View {
    @EnvironmentObject var mapManager: MapManager
    @State var selectedBuilding: Building?
    var body: some View {
        Map(position: $mapManager.camera){
            selectedAnnotations
            UserAnnotation()
            ForEach(mapManager.routes, id: \.self){ route in
                    MapPolyline(route.polyline)
                        .stroke(Color.blue, lineWidth: 5)
            }
            if let stepPolyline = mapManager.routes.first?.steps[mapManager.currentStepIndex].polyline{
                MapPolyline(stepPolyline)
                    .stroke(Color.red, lineWidth: 5)
            }
        }
        .mapControls{
            MapCompass()
            MapPitchToggle()
        }
        .mapStyle(.standard(pointsOfInterest: []))
        .sheet(item: $selectedBuilding){ selectedBuild in
            PlaceDetailView(place: selectedBuild)
                .presentationDetents([.fraction(0.6)])
        }
    }
}
extension mapView {
    var selectedAnnotations: some MapContent {
        ForEach(Array(mapManager.selectedBuildings.values), id: \.id) { selectedBuild in
            Annotation(selectedBuild.name, coordinate: CLLocationCoordinate2D(latitude: selectedBuild.latitude, longitude: selectedBuild.longitude)) {
                Button{
                    selectedBuilding = selectedBuild
                } label: {
                    Image(systemName: selectedBuild.favorited == true ? "heart.fill":"mappin.circle.fill")
                        .font(.title)
                        .font(.system(size: selectedBuild.favorited == true ? 40 : 35))
                        .foregroundStyle(selectedBuild.favorited == true ? .red : .green)
                }
            }
        }
    }
}
#Preview {
    mapView(selectedBuilding: nil)
        .environmentObject(MapManager())
}


