//
//  ForecastResponse.swift
//  WeatherApp
//
//  Created by 장은새 on 8/12/25.
//

import Foundation

struct ForecastResponse: Codable {
    let list: [ForecastItem]
    let city: ForecastCity
}

struct ForecastCity: Codable {
    let name: String
    let coord: Coord
    let country: String
}

struct ForecastItem: Codable {
    let dt: Int
    let main: WeatherMain
    let weather: [Weather]
    let pop: Double?
    
}


