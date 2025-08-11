//
//  GeocodingResponse.swift
//  WeatherApp
//
//  Created by 장은새 on 8/8/25.
//
// 도시이름 Geocoding API 응답 모델

import Foundation

struct GeocodingResponse: Codable {
    
    let name: String
    let localNames: [String: String]?
    let lat: Double
    let lon: Double
    let country: String
    let state: String?
    
    enum CodingKeys: String, CodingKey {
        case name
        case localNames = "local_names"
        case lat, lon, country, state
        
    }
}
