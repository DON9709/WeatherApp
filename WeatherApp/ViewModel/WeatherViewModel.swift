//
//  WeatherViewModel.swift
//  WeatherApp
//
//  Created by 이돈혁 on 8/8/25.
//

import Foundation

struct RegionWeatherData {
    let city: String
    let currentTemp: String
    let minTemp: String
    let maxTemp: String
}

struct HourlyWeatherItem {
    let hour: String
    let icon: String
    let temp: String
}

struct DailyWeatherItem {
    let day: String
    let icon: String
    let minTemp: String
    let maxTemp: String
}

final class WeatherViewModel {
    private(set) var regionData: RegionWeatherData?
    private(set) var hourlyData: [HourlyWeatherItem] = []
    private(set) var weeklyData: [DailyWeatherItem] = []

    var onUpdate: (() -> Void)?

    func configure(with raw: WeatherRawModel) {
        // 가정: WeatherRawModel은 외부에서 주입되는 날씨 모델 (예: API 디코딩 결과)

        self.regionData = RegionWeatherData(
            city: raw.cityName,
            currentTemp: "\(Int(raw.currentTemp))°",
            minTemp: "\(Int(raw.minTemp))°",
            maxTemp: "\(Int(raw.maxTemp))°"
        )

        self.hourlyData = raw.hourlyList.map {
            HourlyWeatherItem(
                hour: $0.hour,
                icon: mapIcon(from: $0.iconCode),
                temp: "\(Int($0.temp))°"
            )
        }

        self.weeklyData = raw.dailyList.map {
            DailyWeatherItem(
                day: $0.day,
                icon: mapIcon(from: $0.iconCode),
                minTemp: "\(Int($0.minTemp))°",
                maxTemp: "\(Int($0.maxTemp))°"
            )
        }

        onUpdate?()
    }

    private func mapIcon(from code: String) -> String {
        switch code {
        case "01d": return "☀️"
        case "01n": return "🌙"
        case "02d", "02n": return "🌤"
        case "03d", "03n": return "☁️"
        case "09d", "09n": return "🌧"
        case "10d", "10n": return "🌦"
        case "11d", "11n": return "⛈"
        case "13d", "13n": return "❄️"
        case "50d", "50n": return "🌫"
        default: return "☁️"
        }
    }
}

// 이 ViewModel은 외부에서 WeatherRawModel을 받아 configure(with:)로 설정되며,
// 이후 각 뷰가 필요한 데이터를 접근할 수 있음.
