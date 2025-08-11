//
//  GeocodingService.swift
//  WeatherApp
//
//  Created by 장은새 on 8/8/25.
//
//  도시 위치 API 통신 및 데이터 처리

import Foundation

struct GeocodingResult: Codable, Hashable {
    let name: String
    let localNames: [String: String]?
    let lat: Double
    let lon: Double
    let country: String
    let state: String?

    enum CodingKeys: String, CodingKey {
        case name
        case localNames = "local_names"
        case lat, lon, country, state
    }
}

// MARK: - 프로토콜 채택
extension GeocodingService: GeocodingServiceProtocol {}

final class GeocodingService {
    private let base = "https://api.openweathermap.org"
    private let path = "/geo/1.0/direct"
    private static let hardcodedAPIKey = "<PUT_YOUR_OPENWEATHER_API_KEY_HERE>"
    private let apiKey: String

    init(apiKey: String = "") {
        // If caller passes empty or placeholder, use the hardcoded key.
        if apiKey.isEmpty || apiKey == "<API키>" || apiKey == "<API키>" {
            self.apiKey = Self.hardcodedAPIKey
        } else {
            self.apiKey = apiKey
        }
    }

    /// 도시명으로 좌표 검색
    func searchCity(_ query: String,
                    limit: Int = 5,
                    completion: @escaping (Result<[GeocodingResult], Error>) -> Void) {
        var comps = URLComponents(string: base)!
        comps.path = path
        comps.queryItems = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "limit", value: String(limit)),
            URLQueryItem(name: "appid", value: apiKey)
        ]
        guard let url = comps.url else {
            return completion(.failure(NSError(domain: "URL", code: -1)))
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error { return completion(.failure(error)) }
            guard let http = response as? HTTPURLResponse,
                  (200...299).contains(http.statusCode),
                  let data else {
                return completion(.failure(NSError(domain: "HTTP", code: 0)))
            }
            do {
                let results = try JSONDecoder().decode([GeocodingResult].self, from: data)
                completion(.success(results))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
