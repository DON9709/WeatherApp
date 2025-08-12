//
//  HourlyWeather.swift
//  WeatherApp
//
//  Created by 장은새 on 8/6/25.
//
// 시간별 날씨 모델

import Foundation

struct HourlyWeather: Codable {
    let dt: Int// 시각
    let temp: Double// 기온(섭씨)
    let pop: Double// 강수확률
    let weather: [Weather]// 날씨 배열
    let icon: String
    let description: String
    
}
