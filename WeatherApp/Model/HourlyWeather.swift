//
//  HourlyWeather.swift
//  WeatherApp
//
//  Created by 장은새 on 8/6/25.
//
// 시간별 날씨 모델

import Foundation

struct HourlyWeather: Codable {
    let dt: Int
    let temp: Double
    let feels_like: Double
    let pressure: Int
    let humidity: Int
    let uvi: Double
    let clouds: Int
    let visibility: Int
    let wind_speed: Double
    let pop: Double
    let weather: [Weather]
}
