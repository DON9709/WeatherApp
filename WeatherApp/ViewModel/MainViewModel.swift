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
            self.fetchWeather(for: city) { [weak self] result in
                defer { group.leave() }

                switch result {
                case .success(let current):
                    let display = WeatherDisplayData(
                        cityName: current.locationName ?? city,
                        temperatureText: "\(Int(current.main.temp))°C",
                        iconName: self?.mapIcon(code: current.weather.first?.icon ?? "") ?? "cloud"
                    )
                    DispatchQueue.main.async {
                        self?.weatherList.append(display)
                    }
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
    
// MARK: - 내부데이터 가져오기 (도시 이름 기반)
    private func fetchWeather(for city: String, completion: @escaping (Result<CurrentWeather, Error>) -> Void) {
        let apiKey = Bundle.main.object(forInfoDictionaryKey: "OPEN_WEATHER_API_KEY") as? String ?? ""
        guard !apiKey.isEmpty else {
            completion(.failure(NSError(domain: "MainViewModel", code: -1, userInfo: [NSLocalizedDescriptionKey: "Missing OPEN_WEATHER_API_KEY"])))
            return
        }
        var components = URLComponents(string: "https://api.openweathermap.org/data/2.5/weather")
        components?.queryItems = [
            URLQueryItem(name: "q", value: city),
            URLQueryItem(name: "appid", value: apiKey),
            URLQueryItem(name: "units", value: "metric")
        ]
        guard let url = components?.url else {
            completion(.failure(NSError(domain: "MainViewModel", code: -2, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error)); return
            }
            guard let http = response as? HTTPURLResponse, 200..<300 ~= http.statusCode, let data = data else {
                completion(.failure(NSError(domain: "MainViewModel", code: -3, userInfo: [NSLocalizedDescriptionKey: "Network error or empty data"])))
                return
            }
            do {
                let current = try JSONDecoder().decode(CurrentWeather.self, from: data)
                completion(.success(current))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
}
