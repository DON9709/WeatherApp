// WeatherService.swift
import Foundation

final class NetworkService {
    func fetch<T: Decodable>(_ url: URL, completion: @escaping (Result<T, Error>) -> Void) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error { return completion(.failure(error)) }
            guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode), let data else {
                return completion(.failure(NSError(domain: "HTTP", code: -1)))
            }
            do {
                let decoded = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decoded))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}

final class WeatherService {
    private let apiKey: String = Bundle.main.object(forInfoDictionaryKey: "OPEN_WEATHER_API_KEY") as? String ?? ""
    private let network = NetworkService()
    
    // MARK: - 현재 날씨 (/data/2.5/weather)
    func fetchCurrentWeather(lat: Double, lon: Double, completion: @escaping (Result<CurrentWeather, Error>) -> Void) {
        guard !apiKey.isEmpty else {
            return completion(.failure(NSError(domain: "API_KEY", code: -1, userInfo: [NSLocalizedDescriptionKey: "Missing OPEN_WEATHER_API_KEY"])))
        }
        var comps = URLComponents(string: "https://api.openweathermap.org/data/2.5/weather")!
        comps.queryItems = [
            .init(name: "lat", value: String(lat)),
            .init(name: "lon", value: String(lon)),
            .init(name: "appid", value: apiKey),
            .init(name: "units", value: "metric"),
        ]
        guard let url = comps.url else { return completion(.failure(NSError(domain: "URL", code: -2))) }
        network.fetch(url, completion: completion)
    }
    
    // 도시명으로 현재 날씨
    func fetchCurrentWeather(city: String, completion: @escaping (Result<CurrentWeather, Error>) -> Void) {
        guard !apiKey.isEmpty else {
            return completion(.failure(NSError(domain: "API_KEY", code: -1, userInfo: [NSLocalizedDescriptionKey: "Missing OPEN_WEATHER_API_KEY"])))
        }
        var comps = URLComponents(string: "https://api.openweathermap.org/data/2.5/weather")!
        comps.queryItems = [
            .init(name: "q", value: city),
            .init(name: "appid", value: apiKey),
            .init(name: "units", value: "metric"),
        ]
        guard let url = comps.url else { return completion(.failure(NSError(domain: "URL", code: -2))) }
        network.fetch(url, completion: completion)
    }
    
    // MARK: 5일/3시간 예보 (/data/2.5/forecast)
    func fetchForecast(lat: Double, lon: Double, completion: @escaping (Result<ForecastResponse, Error>) -> Void) {
        guard !apiKey.isEmpty else {
            return completion(.failure(NSError(domain: "API_KEY", code: -1, userInfo: [NSLocalizedDescriptionKey: "Missing OPEN_WEATHER_API_KEY"])))
        }
        var comps = URLComponents(string: "https://api.openweathermap.org/data/2.5/forecast")!
        comps.queryItems = [
            .init(name: "lat", value: String(lat)),
            .init(name: "lon", value: String(lon)),
            .init(name: "appid", value: apiKey),
            .init(name: "units", value: "metric"),
        ]
        guard let url = comps.url else { return completion(.failure(NSError(domain: "URL", code: -2))) }
        network.fetch(url, completion: completion)
    }
    
    // MARK: Hourly / Daily
    func fetchHourlyWeather(lat: Double, lon: Double, completion: @escaping (Result<[HourlyWeather], Error>) -> Void) {
        fetchForecast(lat: lat, lon: lon) { result in
            switch result {
            case .success(let forecast):
                completion(.success(forecast.toHourly()))
            case .failure(let err):
                completion(.failure(err))
            }
        }
    }
    
    func fetchDailyWeather(lat: Double, lon: Double, completion: @escaping (Result<[DailyWeather], Error>) -> Void) {
        fetchForecast(lat: lat, lon: lon) { result in
            switch result {
            case .success(let forecast):
                completion(.success(forecast.toDaily()))
            case .failure(let err):
                completion(.failure(err))
            }
        }
    }
}
