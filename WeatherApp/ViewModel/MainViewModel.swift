//
//  MainViewModel.swift
//  WeatherApp
//
//  Created by 이돈혁 on 8/5/25.
//

import Foundation
import Combine

struct WeatherDisplayData {
    let cityName: String
    let temperatureText: String
    let iconName: String
}

class MainViewModel: ObservableObject {
    private let weatherService = WeatherService()
    private(set) var weatherList: [WeatherDisplayData] = []

    @Published var currentWeather: CurrentWeather?
    @Published var errorMessage: String?
    
    private(set) var hourlyData: [HourlyWeather] = []
    private(set) var weeklyData: [DailyWeather] = []

    var onUpdate: (() -> Void)?
    
    var selectedIndex: Int = 0

    func loadWeather(for locations: [String]) {
        weatherList = []
        hourlyData = []
        weeklyData = []
        let group = DispatchGroup()

        for city in locations {
            group.enter()
            self.weatherService.fetchCurrentWeather(city: city) { [weak self] result in
                defer { group.leave() }

                switch result {
                case .success(let current):
                    self?.currentWeather = current
                    let display = WeatherDisplayData(
                        cityName: current.locationName ?? city,
                        temperatureText: "\(Int(current.main?.temp ?? 0))°C",
                        iconName: self?.mapIcon(code: current.weather.first?.icon ?? "") ?? "cloud"
                    )
                    DispatchQueue.main.async {
                        self?.weatherList.append(display)
                    }

                    guard let coord = current.coord else { return }
                    self?.weatherService.fetchHourlyWeather(lat: coord.lat, lon: coord.lon) { result in
                        switch result {
                        case .success(let hourly):
                            DispatchQueue.main.async {
                                self?.hourlyData = hourly
                                self?.onUpdate?()
                            }
                        case .failure(let error):
                            print("Hourly fetch failed: \(error)")
                        }
                    }

                    self?.weatherService.fetchDailyWeather(lat: coord.lat, lon: coord.lon) { result in
                        switch result {
                        case .success(let daily):
                            DispatchQueue.main.async {
                                self?.weeklyData = daily
                                self?.onUpdate?()
                            }
                        case .failure(let error):
                            print("Daily fetch failed: \(error)")
                        }
                    }
                case .failure(let error):
                    self?.errorMessage = "Error fetching weather for \(city): \(error.localizedDescription)"
                    print("Error fetching weather for \(city): \(error)")
                }
            }
        }

        group.notify(queue: .main) {
            self.onUpdate?()
        }
    }

    private func mapIcon(code: String) -> String {
        switch code {
        case "01d": return "sun.max.fill"
        case "01n": return "moon.stars.fill"
        case "02d", "02n": return "cloud.sun.fill"
        case "03d", "03n", "04d", "04n": return "cloud.fill"
        case "09d", "09n", "10d", "10n": return "cloud.rain.fill"
        case "11d", "11n": return "cloud.bolt.fill"
        case "13d", "13n": return "snow"
        case "50d", "50n": return "cloud.fog.fill"
        default: return "cloud"
        }
    }
    
    func numberOfLocations() -> Int {
        return weatherList.count
    }

    func titleForSegment(at index: Int) -> String? {
        guard weatherList.indices.contains(index) else { return nil }
        return weatherList[index].cityName
    }

    func currentWeatherData() -> WeatherDisplayData? {
        guard weatherList.indices.contains(selectedIndex) else { return nil }
        return weatherList[selectedIndex]
    }
}
