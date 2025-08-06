//
//  Weather.swift
//  WeatherApp
//
//  Created by 이돈혁 on 8/5/25.
//
// 현재 날씨
//  날씨 데이터 모델(API 응답 구조 기반)

import Foundation

struct WeatherResponse: Codable {
    let name: String
    let weather: [Weather]
    let main: WeatherMain
}

struct Weather: Codable {
    let id: Int
    let main: String
    let description: String
    let icon: String
}

struct WeatherMain: Codable {
    let temp: Double
    let feels_like: Double
    let temp_min: Double
    let temp_max: Double
    let pressure: Double
    let humidity: Double
    
    enum CodingKeys: String, CodingKey {
        case temp
        case feels_like = "feels_like"
        case temp_min = "temp_min"
        case temp_max = "temp_max"
        case pressure
        case humidity
    }
}
