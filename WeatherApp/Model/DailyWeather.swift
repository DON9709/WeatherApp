//
//  DailyWeather.swift
//  WeatherApp
//
//  Created by 장은새 on 8/6/25.
//
// 요일별 날씨 모델

import Foundation

struct DailyWeather: Codable {
    let dt: Int
    let sunrise: Int
    let sunset: Int
    let temp: DailyTemperature
    let pop: Double
    let weather: [Weather]
}

struct DailyTemperature: Codable {
    let min: Double
    let max: Double
}
