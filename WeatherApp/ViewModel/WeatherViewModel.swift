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

    func configure(with raw: OneCallResponse) {
        // OneCallResponse는 실제 API 응답 모델
        self.regionData = RegionWeatherData(
            city: "",
            currentTemp: "\(Int(raw.current.main.temp))°",
            minTemp: "\(Int(raw.daily.first?.temp.min ?? 0))°",
            maxTemp: "\(Int(raw.daily.first?.temp.max ?? 0))°"
        )

        self.hourlyData = raw.hourly.prefix(12).map {
            let date = Date(timeIntervalSince1970: TimeInterval($0.dt))
            let hour = DateFormatter.localizedString(from: date, dateStyle: .none, timeStyle: .short)
            return HourlyWeatherItem(
                hour: hour,
                icon: mapIcon(from: $0.weather.first?.icon ?? ""),
                temp: "\(Int($0.temp))°"
            )
        }

        self.weeklyData = raw.daily.prefix(5).map {
            let date = Date(timeIntervalSince1970: TimeInterval($0.dt))
            let day = DateFormatter.localizedString(from: date, dateStyle: .short, timeStyle: .none)
            return DailyWeatherItem(
                day: day,
                icon: mapIcon(from: $0.weather.first?.icon ?? ""),
                minTemp: "\(Int($0.temp.min))°",
                maxTemp: "\(Int($0.temp.max))°"
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

