//
//  campusModel.swift
//  Campus
//
//  Created by Zak Young on 2/18/24.
//

import Foundation
import MapKit

struct Building : Identifiable{
    var latitude: Double
    var longitude: Double
    var name: String
    var bldgCode: Int
    var photo: String?
    var yearConstructed: Int?
    var selected: Bool?
    var favorited: Bool?
    var id = UUID()
    
    enum CodingKeysDecode: String, CodingKey{
        case latitude = "latitude"
        case longitude = "longitude"
        case name = "name"
        case bldgCode = "opp_bldg_code"
        case photo = "photo"
        case yearConstructed = "year_constructed"
        case selected = "selected"
        case favorited = "favorited"
    }
}

extension Building: Decodable{
    init(from decoder: Decoder) throws {
        let baseValues = try decoder.container(keyedBy: CodingKeysDecode.self)
        latitude = try baseValues.decode(Double.self, forKey: .latitude)
        longitude = try baseValues.decode(Double.self, forKey: .longitude)
        name = try baseValues.decode(String.self, forKey: .name)
        bldgCode = try baseValues.decode(Int.self, forKey: .bldgCode)
        photo = try baseValues.decodeIfPresent(String.self, forKey: .photo)
        yearConstructed = try baseValues.decodeIfPresent(Int.self, forKey: .yearConstructed)
        selected = try baseValues.decodeIfPresent(Bool.self, forKey: .selected) ?? false
        favorited = try baseValues.decodeIfPresent(Bool.self, forKey: .favorited) ?? false
    }

}

extension Building: Encodable{
    func encode(to encoder: Encoder) throws{
        var container = encoder.container(keyedBy: CodingKeysDecode.self)
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
        try container.encode(name, forKey: .name)
        try container.encode(bldgCode, forKey: .bldgCode)
        try container.encodeIfPresent(photo, forKey: .photo)
        try container.encodeIfPresent(yearConstructed, forKey: .yearConstructed)
        try container.encodeIfPresent(selected, forKey: .selected)
        try container.encodeIfPresent(favorited, forKey: .favorited)
    }
    
}
enum selectionOptions: String, CaseIterable{
    case ALLBUILDINGS = "All Buildings"
    case SELECTED = "Selected"
    case FAVORITEBUILDINGS = "Favorites"
    case NEARBY = "Near Me"
}
struct route: Identifiable{
    var startLocation: String?
    var endLocation: String?
    var routeActive: Bool
    var id = UUID()
}
enum mapConfig: String, CaseIterable{
    case IMAGERY = "Imagery"
    case HYBRID = "Hybrid"
    case STANDARD = "Standard"
}
extension String: Identifiable {
    public var id: String { self }
}
