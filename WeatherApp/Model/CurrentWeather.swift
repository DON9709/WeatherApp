//
//  CurrentWeather.swift
//  WeatherApp
//
//  Created by 이돈혁 on 8/5/25.
//
// 현재 날씨 모델
//  날씨 데이터 모델(API 응답 구조 기반)

import Foundation

struct CurrentWeather: Codable {
    let dt: Int
    let sunrise: Int
    let sunset: Int
    let temp: Double
    let feels_like: Double
    let pressure: Int
    let humidity: Int
    let uvi: Double
    let clouds: Int
    let visibility: Int
    let wind_speed: Double
    let weather: [Weather]
}
