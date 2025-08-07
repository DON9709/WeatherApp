//
//  OneCallResponse.swift
//  WeatherApp
//
//  Created by 장은새 on 8/6/25.
//
// API 전체 호출 및 응답 모델

import Foundation

struct OneCallResponse: Codable {
    let lat: Double
    let lon: Double
    let timezone: String
    let timezone_offset: Int
    let current: CurrentWeather
    let hourly: [HourlyWeather]
    let daily: [DailyWeather]
}
