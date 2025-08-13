//
//  WeatherViewModel.swift
//  WeatherApp
//
//  Created by 이돈혁 on 8/8/25.
//

import Foundation

final class WeatherViewModel {
    private(set) var current: CurrentWeather?
    private(set) var hourly: [HourlyWeather] = []
    private(set) var daily: [DailyWeather] = []

    var onUpdate: (() -> Void)?

    var cityName: String {
        current?.locationName ?? ""
    }

    var currentTempText: String {
        guard let t = current?.main?.temp else { return "-" }
        return "\(Int(t))°"
    }

    var minTempText: String {
        guard let first = daily.first else { return "-" }
        return "\(Int(first.min))°"
    }
    
    var maxTempText: String {
        guard let first = daily.first else { return "-" }
        return "\(Int(first.max))°"
    }

    func configure(current: CurrentWeather, hourly: [HourlyWeather], daily: [DailyWeather]) {
        self.current = current
        self.hourly = Array(hourly.prefix(12))
        self.daily = Array(daily.prefix(5))
        onUpdate?()
    }
    func hourString(at index: Int, locale: Locale = .current) -> String {
        guard index >= 0, index < hourly.count else { return "" }
        let dt = hourly[index].dt
        let date = Date(timeIntervalSince1970: TimeInterval(dt))
        let df = DateFormatter()
        df.locale = locale
        df.dateStyle = .none
        df.timeStyle = .short
        return df.string(from: date)
    }
}


    // private func mapIcon(from code: String) -> String {
    //        switch code {
    //        case "01d": return "☀️"
    //        case "01n": return "🌙"
    //        case "02d", "02n": return "🌤"
    //        case "03d", "03n": return "☁️"
    //        case "09d", "09n": return "🌧"
    //        case "10d", "10n": return "🌦"
    //        case "11d", "11n": return "⛈"
    //        case "13d", "13n": return "❄️"
    //        case "50d", "50n": return "🌫"
    //        default: return "☁️"
    //        }
    //    }
