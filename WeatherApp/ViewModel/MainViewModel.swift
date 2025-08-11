//
//  MainViewModel.swift
//  WeatherApp
//
//  Created by 이돈혁 on 8/5/25.
//

import Foundation

struct WeatherDisplayData {
    let cityName: String
    let temperatureText: String
    let iconName: String
}

class MainViewModel {
    private let weatherService = WeatherService() // 은새씨가 해놨다고 가정함
    private(set) var weatherList: [WeatherDisplayData] = []

    var onUpdate: (() -> Void)?
    
    var selectedIndex: Int = 0

    func loadWeather(for locations: [String]) {
        weatherList = []
        let group = DispatchGroup()

        for city in locations {
            group.enter()
            WeatherService.fetchWeather(for: city) { [weak self] result in // weatherService 아직 안돼있어서 에러 잡힐거임
                defer { group.leave() }

                switch result {
                case .success(let weather):
                    let display = WeatherDisplayData(
                        cityName: weather.name,
                        temperatureText: "\(Int(weather.main.temp))°C",
                        iconName: self?.mapIcon(code: weather.weather.first?.icon ?? "") ?? "cloud"
                    )
                    self?.weatherList.append(display)
                case .failure(let error):
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
