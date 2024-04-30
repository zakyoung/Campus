//
//  MapViewCoordinator.swift
//  Campus
//
//  Created by Zak Young on 3/9/24.
//

import Foundation
import MapKit
class MapViewCoordinator : NSObject, MKMapViewDelegate {
    let manager : MapManager
    init(manager: MapManager) {
        self.manager = manager
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard let title = annotation.title else {
                return nil
            }
            guard let building = manager.allBuildings[title!] else {
                guard annotation is MKUserLocation else{
                    let markerID = "USERPLACED" // This is the case where it is a user placed pin
                    let marker = mapView.dequeueReusableAnnotationView(withIdentifier: markerID) as? MKMarkerAnnotationView ?? MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: markerID)
                    marker.clusteringIdentifier = markerID
                    marker.glyphImage = UIImage(systemName: "circle")
                    marker.markerTintColor = UIColor.yellow
                    return marker
                }
                let markerID = "Current Location"
                let marker = mapView.dequeueReusableAnnotationView(withIdentifier: markerID) as? MKMarkerAnnotationView ?? MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: markerID)
                marker.clusteringIdentifier = markerID
                marker.displayPriority = .required
                marker.glyphImage = UIImage(systemName: "circle.fill")
                marker.markerTintColor = UIColor.blue
                return marker
            }
            let buildingId = "Building"
            let heartId = "Heart"
            let markerID = building.favorited! ? heartId : buildingId
            let marker = mapView.dequeueReusableAnnotationView(withIdentifier: markerID) as? MKMarkerAnnotationView ?? MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: markerID)
            marker.clusteringIdentifier = markerID
            if building.favorited! {
                marker.glyphImage = UIImage(systemName: building.favorited! ? "heart.fill" : "mappin.circle.fill")
                marker.markerTintColor = building.favorited! ? UIColor.red : UIColor.green
            } else {
                marker.glyphImage = UIImage(systemName: building.favorited! ? "heart.fill" : "mappin.circle.fill")
                marker.markerTintColor = building.favorited! ? UIColor.red : UIColor.green
            }
            
            return marker
    }
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let title = view.annotation?.title else{
            return
        }
        if (manager.allBuildings[title!] != nil) {
           manager.selectedBuilding = manager.allBuildings[title!]
        }
        else if (manager.userPlacedMarkers[title!] != nil){
            manager.selectedMarker = title
        }
    }
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let currentRegion = mapView.region
        DispatchQueue.main.async {
            self.manager.camera = .region(currentRegion)
        }
    }
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        switch overlay {
        case is MKPolyline:
            let polyLineRenderer = MKPolylineRenderer(overlay: overlay)
            if overlay.title == "Route"{
                polyLineRenderer.strokeColor = UIColor.red
            }
            else{
                polyLineRenderer.strokeColor = UIColor.blue
            }
            polyLineRenderer.lineWidth = 4.0
            return polyLineRenderer
        default:
            assert(false, "Unhandled Overlay")
        }
    }
    @objc
    func handleLongPress(recognizer: UILongPressGestureRecognizer){
        if recognizer.state == .began {
            let mapView = recognizer.view! as! MKMapView
            let touchLocation = recognizer.location(in: mapView)
            let coordinate = mapView.convert(touchLocation, toCoordinateFrom: mapView)
            manager.addUserPlacedMarker(coordinate: coordinate)
        }
    }
}
