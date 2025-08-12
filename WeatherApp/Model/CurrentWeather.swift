//
//  CurrentWeather.swift
//  WeatherApp
//
//  Created by 이돈혁 on 8/5/25.
//
// 현재 날씨 모델
//  날씨 데이터 모델(API 응답 구조 기반)

import Foundation

struct Coord: Codable {
    let lon: Double
    let lat: Double
}

struct CurrentWeather: Codable {
    let temp: Double?
    let weather: [Weather]
    let main: WeatherMain?
    let coord: Coord?
    let locationName: String?
    
    private enum CodingKeys: String, CodingKey {
        case temp
        case weather
        case main
        case coord
        case locationName = "name"
    }
    
    var description: String {
        weather.first?.description ?? ""
    }
    
    var icon: String {
        weather.first?.icon ?? ""
    }
}
