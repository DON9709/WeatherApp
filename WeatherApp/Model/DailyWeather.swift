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
    let feels_like: DailyFeelsLike
    let pressure: Int
    let humidity: Int
    let wind_speed: Double
    let weather: [Weather]
    let clouds: Int
    let pop: Double
    let uvi: Double
}

struct DailyTemperature: Codable {
    let min: Double
    let max: Double
    let day: Double
    let night: Double
    let eve: Double
    let morn: Double
}

struct DailyFeelsLike: Codable {
    let day: Double
    let night: Double
    let eve: Double
    let morn: Double
}
