//
//  Weather.swift
//  WeatherApp
//
//  Created by 장은새 on 8/6/25.
//
// 공통 날씨 데이터 모델

import Foundation


struct Weather: Codable {
    let id: Int
    let main: String
    let description: String
    let icon: String
}

struct WeatherMain: Codable {
    let temp: Double
    let tempMin : Double
    let tempMax : Double
    
    enum CodingKeys: String, CodingKey {
        case temp
        case tempMin = "temp_min"
        case tempMax = "temp_max"
    }
}
