//
//  WeatherService.swift
//  WeatherApp
//
//  Created by 이돈혁 on 8/5/25.
//
//  날씨 API 통신 및 데이터 처리

import Foundation

class NetworkService {
    func fetchData<T: Decodable>(url: URL, completion: @escaping (T?) -> Void) {
        let session = URLSession(configuration: .default)
        session.dataTask(with: URLRequest(url: url)) { data, response, error in
            guard let data, error == nil else {
                print("데이터 로드 실패")
                completion(nil)
                return
            }
            // http status code 성공 범위는 200번대.
            let successRange = 200..<300
            if let response = response as? HTTPURLResponse, successRange.contains(response.statusCode) {
                guard let decodedData = try? JSONDecoder().decode(T.self, from: data) else {
                    print("JSON 디코딩 실패")
                    completion(nil)
                    return
                }
                completion(decodedData)
            } else {
                print("응답 오류")
                completion(nil)
            }
        }.resume()
    }
}

class WeatherService {
    
    private let apiKey: String = Bundle.main.object(forInfoDictionaryKey: "OPEN_WEATHER_API_KEY") as? String ?? ""
    private let networkService = NetworkService()
    
    // URL 쿼리 아이템들.
    // 서울역 위경도.
    private lazy var urlQueryItems: [URLQueryItem] = [
        URLQueryItem(name: "lat", value: "37.5"),
        URLQueryItem(name: "lon", value: "126.9"),
        URLQueryItem(name: "appid", value: self.apiKey),
        URLQueryItem(name: "units", value: "metric")
    ]
    
    // 서버에서 현재 날씨 데이터를 불러오는 메서드.
    private func fetchCurrentWeatherData(completion: @escaping (CurrentWeather?) -> Void) {
        guard !apiKey.isEmpty else {
            print("APIKEY 설정 오류")
            completion(nil)
            return
        }
        var urlComponents = URLComponents(string:"https://api.openweathermap.org/data/2.5/weather")
        urlComponents?.queryItems = self.urlQueryItems
        
        guard let url = urlComponents?.url else {
            print("잘못된 URL")
            return
        }
        
        networkService.fetchData(url: url) { [weak self] (result: CurrentWeather?) in
            guard let result else {
                return
            }
            DispatchQueue.main.async {
                completion(result)
            }
            
        }
        
    }
    
    // MARK: - Public API (도시 이름 기반 현재 날씨)
    func fetchWeather(for city: String, completion: @escaping (Result<CurrentWeather, Error>) -> Void) {
        guard !apiKey.isEmpty else {
            completion(.failure(NSError(domain: "WeatherService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Missing OPEN_WEATHER_API_KEY"])))
            return
        }
        var components = URLComponents(string: "https://api.openweathermap.org/data/2.5/weather")
        components?.queryItems = [
            URLQueryItem(name: "q", value: city),
            URLQueryItem(name: "appid", value: self.apiKey),
            URLQueryItem(name: "units", value: "metric")
        ]
        guard let url = components?.url else {
            completion(.failure(NSError(domain: "WeatherService", code: -2, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        networkService.fetchData(url: url) { (result: CurrentWeather?) in
            DispatchQueue.main.async {
                if let current = result {
                    completion(.success(current))
                } else {
                    completion(.failure(NSError(domain: "WeatherService", code: -3, userInfo: [NSLocalizedDescriptionKey: "Decoding failure or no data"])))
                }
            }
        }
    }
    
    // MARK: - Public API (One Call)
    func fetchOneCall(lat: Double, lon: Double, completion: @escaping (Result<OneCallResponse, Error>) -> Void) {
        guard !self.apiKey.isEmpty else {
            completion(.failure(NSError(domain: "WeatherService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Missing OPEN_WEATHER_API_KEY"])))
            return
        }
        var components = URLComponents(string: "https://api.openweathermap.org/data/2.5/onecall")
        components?.queryItems = [
            URLQueryItem(name: "lat", value: String(lat)),
            URLQueryItem(name: "lon", value: String(lon)),
            URLQueryItem(name: "appid", value: self.apiKey),
            URLQueryItem(name: "units", value: "metric"),
            URLQueryItem(name: "exclude", value: "minutely,alerts")
        ]
        guard let url = components?.url else {
            completion(.failure(NSError(domain: "WeatherService", code: -2, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        self.networkService.fetchData(url: url) { (result: OneCallResponse?) in
            DispatchQueue.main.async {
                if let oneCall = result {
                    completion(.success(oneCall))
                } else {
                    completion(.failure(NSError(domain: "WeatherService", code: -3, userInfo: [NSLocalizedDescriptionKey: "Decoding failure or no data"])))
                }
            }
        }
    }
}
