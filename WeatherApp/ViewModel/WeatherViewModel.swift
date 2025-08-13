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

    // MARK: - Configure using /forecast (무료 API)
    func configure(current: CurrentWeather, forecast: ForecastResponse) {
        self.current = current
        self.hourly = Array(mapHourly(from: forecast).prefix(12))
        self.daily  = Array(mapDaily(from: forecast).prefix(5))
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

    // MARK: - Mapping helpers (/forecast → hourly/daily)
    private func mapHourly(from forecast: ForecastResponse) -> [HourlyWeather] {
        // forecast.list: 3시간 간격. 앞 12개(=36h)만 사용
        return forecast.list.prefix(12).map { item in
            let icon = item.weather.first?.icon ?? ""
            let desc = item.weather.first?.description ?? ""
            return HourlyWeather(
                dt: Int(item.dt),
                temp: item.main.temp,
                pop: item.pop ?? 0,
                weather: item.weather,
                icon: icon,
                description: desc
            )
        }
    }

    private func mapDaily(from forecast: ForecastResponse) -> [DailyWeather] {
        // 날짜별로 그룹핑하여 min/max 계산
        let calendar = Calendar.current
        var bucket: [Date: (min: Double, max: Double, icon: String, desc: String)] = [:]
        for item in forecast.list {
            let date = Date(timeIntervalSince1970: TimeInterval(item.dt))
            let day  = calendar.startOfDay(for: date)
            let tMin = item.main.tempMin
            let tMax = item.main.tempMax
            let icon = item.weather.first?.icon ?? ""
            let desc = item.weather.first?.description ?? ""
            if var agg = bucket[day] {
                agg.min = Swift.min(agg.min, tMin)
                agg.max = Swift.max(agg.max, tMax)
                // 대표 아이콘/설명은 최초값 유지
                bucket[day] = agg
            } else {
                bucket[day] = (tMin, tMax, icon, desc)
            }
        }
        return bucket.keys.sorted().prefix(5).compactMap { day in
            guard let v = bucket[day] else { return nil }
            return DailyWeather(
                date: day,
                min: v.min,
                max: v.max,
                icon: v.icon,
                description: v.desc
            )
        }
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
