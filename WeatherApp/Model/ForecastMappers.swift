//
//  ForecastMappers.swift
//  WeatherApp
//
//  Created by 장은새 on 8/12/25.
//
import Foundation

extension ForecastResponse {
    func toHourly() -> [HourlyWeather] {
        list.map { item in
            HourlyWeather(
                dt: item.dt,
                temp: item.main.temp,
                pop: item.pop ?? 0.0, weather: [],
                icon: item.weather.first?.icon ?? "",
                description: item.weather.first?.description ?? ""
            )
        }
    }
    
    func toDaily(calendar: Calendar = .current, timeZone: TimeZone = TimeZone.current) -> [DailyWeather] {
        var tzCalendar = calendar
        tzCalendar.timeZone = timeZone
        let grouped = Dictionary(grouping: list) { item -> Date in
            let date = Date(timeIntervalSince1970: TimeInterval(item.dt))

            return tzCalendar.startOfDay(for: date)
        }
        
        let days = grouped.keys.sorted()
        return days.compactMap { day in
            guard let items = grouped[day], !items.isEmpty else { return nil }
            let temps = items.map { $0.main.temp }
            let minTemp = temps.min() ?? items[0].main.temp
            let maxTemp = temps.max() ?? items[0].main.temp
            let noon = tzCalendar.date(bySettingHour: 12, minute: 0, second: 0, of: day) ?? day
            let best = items.min(by: {
                abs(Date(timeIntervalSince1970: TimeInterval($0.dt)).timeIntervalSince(noon)) <
                abs(Date(timeIntervalSince1970: TimeInterval($1.dt)).timeIntervalSince(noon))
            }) ?? items[0]
            
            return DailyWeather(
                date: day,
                min: minTemp,
                max: maxTemp,
                icon: best.weather.first?.icon ?? "01d",
                description: best.weather.first?.description ?? ""
            )
        }
    }
}

