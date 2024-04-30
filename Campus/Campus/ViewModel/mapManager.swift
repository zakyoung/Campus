//
//  mapManager.swift
//  Campus
//
//  Created by Zak Young on 2/18/24.
//

import Foundation
import MapKit
import SwiftUI
class MapManager: NSObject, ObservableObject{
    @Published var allBuildings: [String:Building] = [:]
    @Published var camera: MapCameraPosition = .region(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 40.7990957268391, longitude: -77.859843719255), span: MKCoordinateSpan(latitudeDelta: 0.0356, longitudeDelta: 0.0356))){
        didSet{
            let cameraCenterLati = camera.region?.center.latitude
            let personCenterLati = locationManager.location?.coordinate.latitude
            let cameraCenterLongi = camera.region?.center.longitude
            let personCenterLongi = locationManager.location?.coordinate.longitude
            centerdAroundPerson = (cameraCenterLati == personCenterLati) && (cameraCenterLongi == personCenterLongi)
        }
}
    @Published var favorites: [String:Building] = [:] // String will be the building name
    @Published var selectedBuildings: [String:Building] = [:]
    @Published var allFavoritesSelected: Bool = false
    @Published var centerdAroundPerson: Bool = false
    @Published var currentFilterSeleciton: selectionOptions = .ALLBUILDINGS
    @Published var currentRoute: route = route(routeActive: false) // We init the route to not being active
    @Published var routes = [MKRoute]()
    @Published var currentStepIndex = 0
    @Published var selectedBuilding: Building?
    @Published var selectedConfiguration: mapConfig = .STANDARD
    @Published var userPlacedMarkers: [String:MKAnnotation] = [:]
    @Published var selectedMarker: String?
    private var nearbyBuildings: [String:Building] = [:]
    let locationManager : CLLocationManager
    let urlPersisted: URL = {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory.appendingPathComponent("updatedBuildings.json")
    }()
    override init(){
        locationManager = CLLocationManager()
        super.init()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        loadBuildings()
        currentRoute.startLocation = allBuildings.keys.sorted().first
        currentRoute.endLocation = allBuildings.keys.sorted().first
        updateCameraPosition()
    }
    func loadBuildings(){
        if FileManager.default.fileExists(atPath: urlPersisted.path){
            loadBuildingStatesGeneral()
        }
        else{
            loadBuildingsFirstStartUp()
        }
        setFavorites()
        setSelected()
    }
    func saveBuildingStates(){
        do{
            var buildingsToWrite: [Building] = []
            for buildingName in allBuildings.keys{
                buildingsToWrite.append(allBuildings[buildingName]!)
            }
            let encoder = JSONEncoder()
            let data = try encoder.encode(buildingsToWrite)
            try data.write(to: urlPersisted, options: .atomicWrite)
        }
        catch{
            print("ERROR")
        }
    }
    func loadBuildingStatesGeneral(){
        var localBuildings: [Building] = []
        do{
                let content = try Data(contentsOf: urlPersisted)
                let decoder = JSONDecoder()
                localBuildings = try decoder.decode([Building].self, from: content)
        }
        catch{
            print("ERROR")
        }
        for building in localBuildings{
            allBuildings[building.name] = building
        }
    }
    func loadBuildingsFirstStartUp() -> Void {
        var localBuildings: [Building] = []
        if let url = Bundle.main.url(forResource: "buildings", withExtension: "json"){
            do{
                let content = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                localBuildings = try decoder.decode([Building].self, from: content)
            }
            catch{
                print("ERROR")
            }
        }
        else{
            print("Error")
        }
        for building in localBuildings{
            allBuildings[building.name] = building
        }
    }
    func setFavorites()->Void{
        for buildingName in allBuildings.keys{
            let building = allBuildings[buildingName]
            if building?.favorited ?? false{
                favorites[building!.name] = building
            }
        }
    }
    func setSelected()->Void{
        for buildingName in allBuildings.keys{
            let building = allBuildings[buildingName]
            if building?.selected ?? false{
                selectedBuildings[building!.name] = building
            }
        }
    }
    func updateFavorites()->Void{
        var newFavorites : [String:Building] = [:]
        for building in allBuildings.keys{
            if allBuildings[building]?.favorited == true{
                newFavorites[allBuildings[building]!.name] = allBuildings[building]!
            }
        }
        favorites = newFavorites
    }
    func updateSelected()->Void{
        var newSelected : [String:Building] = [:]
        for building in allBuildings.keys{
            if allBuildings[building]?.selected == true{
                newSelected[allBuildings[building]!.name] = allBuildings[building]!
            }
        }
        selectedBuildings = newSelected
    }
    func clearMap()->Void{
        for building in allBuildings.keys{
            allBuildings[building]?.selected = false
        }
        updateSelected()
        allFavoritesSelected = false
    }
    func clearEverything()->Void{
        clearMap()
    userPlacedMarkers = [:]
    }
    func selectAllFavorites()->Void{
        for building in allBuildings.keys{
            if allBuildings[building]?.favorited == true{
                allBuildings[building]?.selected = true
            }
        }
        updateSelected()
        allFavoritesSelected = true
    }
    func deselectAllFavorites()->Void{
        for building in allBuildings.keys{
            if allBuildings[building]?.favorited == true{
                allBuildings[building]?.selected = false
            }
        }
        updateSelected()
        allFavoritesSelected = false
    }
  
    func selectAllLogic()->Void{
        if allFavoritesSelected{
            deselectAllFavorites()
        }
        else{
            selectAllFavorites()
        }
    }
    func updateCameraPosition()->Void{
        camera  = .region(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: locationManager.location?.coordinate.latitude ?? 40.7990957268391, longitude: locationManager.location?.coordinate.longitude ?? -77.859843719255), span: MKCoordinateSpan(latitudeDelta: 0.0356, longitudeDelta: 0.0356)))
    }
    func updateNearbyBuildings()->Void{
        var nearbyBuildingsLocal: [String:Building] = [:]
        let spanValue = 0.002 // This will be the range we use for nearby buildings.
        let userCurrentLocation = CLLocationCoordinate2D(latitude: locationManager.location?.coordinate.latitude ?? 40.7990957268391, longitude: locationManager.location?.coordinate.longitude ?? -77.859843719255)
        for building in allBuildings.keys{
            let latitudeCheckLessThan: Bool = (userCurrentLocation.latitude + spanValue) >= allBuildings[building]!.latitude
            let latitudeCheckGreaterThan: Bool = (userCurrentLocation.latitude - spanValue) <= allBuildings[building]!.latitude
            let longitudeCheckLessThan: Bool = (userCurrentLocation.longitude + spanValue) >= allBuildings[building]!.longitude
            let longitudeCheckGreaterThan: Bool = (userCurrentLocation.longitude - spanValue) <= allBuildings[building]!.longitude
            if latitudeCheckLessThan && latitudeCheckGreaterThan && longitudeCheckLessThan && longitudeCheckGreaterThan{
                nearbyBuildingsLocal[building] = allBuildings[building]!
            }
        }
        nearbyBuildings = nearbyBuildingsLocal
    }
    func getBuildingsGivenSelection()->[String:Building] {
        switch currentFilterSeleciton{
        case .ALLBUILDINGS:
                return allBuildings
        case .SELECTED:
            return selectedBuildings
        case .FAVORITEBUILDINGS:
                return favorites
        case .NEARBY:
                updateNearbyBuildings()
                return nearbyBuildings
        }
    }
    func getDirections(fromUser:Bool){
        let request = MKDirections.Request()
        var coordinateEnd: CLLocationCoordinate2D
        var coordinateStart: CLLocationCoordinate2D
        if !fromUser{
            coordinateStart = CLLocationCoordinate2D(latitude: allBuildings[currentRoute.startLocation!]!.latitude, longitude: allBuildings[currentRoute.startLocation!]!.longitude)
        }
        else{
            coordinateStart = CLLocationCoordinate2D(latitude: locationManager.location!.coordinate.latitude, longitude: locationManager.location!.coordinate.longitude)
        }
        let placerStart = MKPlacemark(coordinate: coordinateStart)
        let mapItemStart = MKMapItem(placemark: placerStart)
        if (allBuildings[currentRoute.endLocation!] != nil){
            coordinateEnd = CLLocationCoordinate2D(latitude: allBuildings[currentRoute.endLocation!]!.latitude, longitude: allBuildings[currentRoute.endLocation!]!.longitude)
            allBuildings[currentRoute.endLocation!]!.selected = true
            userPlacedMarkers = [:]
            updateSelected()
        }
        else{
            coordinateEnd = CLLocationCoordinate2D(latitude: userPlacedMarkers[selectedMarker!]!.coordinate.latitude, longitude: userPlacedMarkers[selectedMarker!]!.coordinate.longitude)
            userPlacedMarkers = [selectedMarker!:userPlacedMarkers[selectedMarker!]!]
        }
        let placerEnd = MKPlacemark(coordinate: coordinateEnd)
        let mapItemEnd = MKMapItem(placemark: placerEnd)
        request.source = mapItemStart
        request.destination = mapItemEnd
        request.transportType = .walking
        let directions = MKDirections(request: request)
        directions.calculate { response, error in
            guard error == nil else { print("here");return}
            if let route = response?.routes.first {
                self.routes.append(route)
            }
        }
    }
    func startRoute(){
        currentRoute.routeActive = true
        clearMap()
        if currentRoute.startLocation == "Current Location"{
            getDirections(fromUser: true)
            camera = .region(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: locationManager.location!.coordinate.latitude, longitude: locationManager.location!.coordinate.longitude), span: MKCoordinateSpan(latitudeDelta: 0.003, longitudeDelta: 0.003))) // Changing the camera allows us to center on the start of the route
        }
        else{
            getDirections(fromUser: false)
            clearEverything()
            allBuildings[currentRoute.startLocation!]!.selected = true
            camera = .region(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: allBuildings[currentRoute.startLocation!]!.latitude, longitude: allBuildings[currentRoute.startLocation!]!.longitude), span: MKCoordinateSpan(latitudeDelta: 0.003, longitudeDelta: 0.003))) // Changing the camera allows us to center on the start of the route
            allBuildings[currentRoute.endLocation!]!.selected = true
            updateSelected()
        }
    }
    func endRoute(){
        currentRoute.routeActive = false
        clearEverything()
        currentStepIndex = 0
        routes = [MKRoute]()
        updateCameraPosition()
    }
    func estimateTime()->String{
        let formated = DateComponentsFormatter()
        formated.unitsStyle = .short
        formated.allowedUnits = [.hour, .minute]
        if let routeTime = routes.first?.expectedTravelTime{
            return formated.string(from: TimeInterval(routeTime))!
        }
        else{
            return ""
        }
    }
    func updateAnnotations() -> [MKAnnotation]{
        var annotations: [MKAnnotation] = []
        for building in allBuildings.values {
            if building.selected!{
                let annotation = MKPointAnnotation()
                annotation.title = building.name
                annotation.coordinate = CLLocationCoordinate2D(latitude: building.latitude, longitude: building.longitude)
                annotations.append(annotation)
            }
        }
        return annotations
    }
    func getConfig() -> MKMapConfiguration{
            if selectedConfiguration == .STANDARD {
                return MKStandardMapConfiguration()
            }
            else if selectedConfiguration == .HYBRID {
                return MKHybridMapConfiguration()
            }
        else if selectedConfiguration == .IMAGERY{
            return MKImageryMapConfiguration.init()
            }
        else{
            return MKStandardMapConfiguration()
        }
    }
    func addUserPlacedMarker(coordinate: CLLocationCoordinate2D) {
        let annotation = MKPointAnnotation()
        annotation.title = "Pin \(userPlacedMarkers.count + 1)"
        annotation.coordinate = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
        userPlacedMarkers[annotation.title!] = annotation
    }
    func removeAllUserPlacedMarkers(){
        userPlacedMarkers = [:]
    }
}
