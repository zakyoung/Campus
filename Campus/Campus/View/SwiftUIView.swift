//
//  SwiftUIView.swift
//  Campus
//
//  Created by Zak Young on 3/9/24.
//

import SwiftUI
import MapKit

struct mapView2 : UIViewRepresentable{
    @EnvironmentObject var mapManager: MapManager
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.region = mapManager.camera.region!
        mapView.showsUserLocation = true
        mapView.showsUserTrackingButton = true
        mapView.delegate = context.coordinator
        mapView.preferredConfiguration = mapManager.getConfig()
        let longPressGesture = UILongPressGestureRecognizer(target: context.coordinator, action: #selector(MapViewCoordinator.handleLongPress(recognizer:)))
        longPressGesture.minimumPressDuration = 0.5
        mapView.addGestureRecognizer(longPressGesture)
        return mapView
    }
    func updateUIView(_ mapView: MKMapView, context: Context) {
        mapView.removeAnnotations(mapView.annotations)
        mapView.removeOverlays(mapView.overlays)
        mapView.preferredConfiguration = mapManager.getConfig()
        mapView.addAnnotations(mapManager.updateAnnotations())
        mapView.addAnnotations(Array(mapManager.userPlacedMarkers.values))
        if let routePoly = mapManager.routes.first?.polyline{
            routePoly.title = "Route"
            mapView.addOverlay(routePoly)
        }
        if let stepPoly = mapManager.routes.first?.steps[mapManager.currentStepIndex].polyline{
            stepPoly.title = "Step"
            mapView.addOverlay(stepPoly)
        }
        mapView.region = mapManager.camera.region!
    }
    func makeCoordinator() -> MapViewCoordinator {
        MapViewCoordinator(manager: mapManager)
    }
}

