//
//  DailyWeather.swift
//  WeatherApp
//
//  Created by 장은새 on 8/6/25.
//
// 요일별 날씨 모델

import Foundation

struct DailyWeather {
    let date: Date
    let min: Double
    let max: Double
    let icon: String
    let description: String
}
