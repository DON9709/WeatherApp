//
//  WeatherService.swift
//  WeatherApp
//
//  Created by 이돈혁 on 8/5/25.
//
//  날씨 API 통신 및 데이터 처리

import Foundation

class WeatherService {
    
    private let apiKey: String = Bundle.main.object(forInfoDictionaryKey: "OPEN_WEATHER_API_KEY") as? String ?? ""
    
    // URL 쿼리 아이템들.
    // 서울역 위경도.
    private lazy var urlQueryItems: [URLQueryItem] = [
        URLQueryItem(name: "lat", value: "37.5"),
        URLQueryItem(name: "lon", value: "126.9"),
        URLQueryItem(name: "appid", value: self.apiKey),
        URLQueryItem(name: "units", value: "metric")
    ]
    
    // 서버 데이터를 불러오는 메서드
    private func fetchData<T: Decodable>(url: URL, completion: @escaping (T?) -> Void) {
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
        
        fetchData(url: url) { [weak self] (result: CurrentWeather?) in
            guard let result else {
                return
            }
            DispatchQueue.main.async {
                completion(result)
            }
            
        }
        
    }
}
