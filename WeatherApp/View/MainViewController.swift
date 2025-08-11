//
//  MainViewController.swift
//  WeatherApp
//
//  Created by 송명균 on 8/7/25.
//


import UIKit
import SnapKit

private struct GeoResult: Decodable {
    let name: String?
    let lat: Double
    let lon: Double
}

final class MainViewController: UIViewController {
    private let scrollView = UIScrollView()
    private let contentView = UIStackView()

    private let segmentedControl = UISegmentedControl(items: [])
    private let ListButton = UIButton(type: .system)

    // Weather subviews as properties for data updates
    private let regionCell = RegionWeatherCell()
    private let hourlyCell = HourlyWeatherCell()
    private let weeklyCell = WeeklyForecastCell()

    // ViewModel for weather data
    private let weatherViewModel = WeatherViewModel()
    private let mainViewModel = MainViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.systemBlue
        setupUI()
        weatherViewModel.onUpdate = { [weak self] in
            self?.renderWeather()
        }
        mainViewModel.onUpdate = { [weak self] in
            self?.renderWeather()
        }
        loadInitialWeather()
    }

    private func setupUI() {
        // 스크롤 뷰
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(60) // 하단 탭바 공간 확보
        }

        // 콘텐츠 뷰 (세로 스택)
        scrollView.addSubview(contentView)
        contentView.axis = .vertical
        contentView.spacing = 16
        contentView.alignment = .fill
        contentView.distribution = .equalSpacing

        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView)
        }

        // 각 셀 추가
        [regionCell, hourlyCell, weeklyCell].forEach {
            contentView.addArrangedSubview($0)
            $0.snp.makeConstraints { $0.height.greaterThanOrEqualTo(120) } // 기본 높이
        }

        // 하단 탭바
        let bottomBar = UIView()
        bottomBar.backgroundColor = UIColor.systemTeal
        bottomBar.layer.cornerRadius = 20
        bottomBar.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.addSubview(bottomBar)

        bottomBar.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(60)
        }

        // 세그먼트
        bottomBar.addSubview(segmentedControl)
        segmentedControl.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        segmentedControl.addTarget(self, action: #selector(segmentedChanged(_:)), for: .valueChanged)


        // 리스트 버튼
        bottomBar.addSubview(ListButton)
        ListButton.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        ListButton.tintColor = .white
        ListButton.addTarget(self, action: #selector(ListTapped), for: .touchUpInside)
        ListButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().inset(16)
            make.width.height.equalTo(32)
        }
    }

    @objc private func ListTapped() {
        let listVC = ListViewController()
        navigationController?.pushViewController(listVC, animated: true)
    }

    private func loadInitialWeather() {
        let locations = ["Seoul", "Busan"]
        mainViewModel.loadWeather(for: locations)
        if let first = locations.first { bootstrapOneCall(for: first) }
    }

    private func renderWeather() {
        // Update segmented control titles to match weather list city names
        segmentedControl.removeAllSegments()
        for (index, weather) in mainViewModel.weatherList.enumerated() {
            segmentedControl.insertSegment(withTitle: weather.cityName, at: index, animated: false)
        }
        if segmentedControl.numberOfSegments > 0 {
            segmentedControl.selectedSegmentIndex = min(segmentedControl.selectedSegmentIndex, segmentedControl.numberOfSegments - 1)
        }

        // Update regionCell with OneCall-based region data
        if let region = weatherViewModel.regionData {
            regionCell.update(with: region)
        }

        // Update hourly and weekly cells with actual data
        hourlyCell.update(items: weatherViewModel.hourlyData)
        weeklyCell.update(items: weatherViewModel.weeklyData)
    }

    /// 외부에서 OneCall 응답을 받았을 때 호출해주세요.
    func applyOneCall(_ raw: OneCallResponse) {
        weatherViewModel.configure(with: raw)
    }
    // MARK: - OneCall bootstrap (지오코딩 → 원콜 → 화면 반영)
    private func bootstrapOneCall(for city: String) {
        geocode(city: city) { [weak self] result in
            switch result {
            case .success(let coord):
                self?.fetchOneCall(lat: coord.0, lon: coord.1) { oneCall in
                    if let oneCall = oneCall {
                        DispatchQueue.main.async { self?.applyOneCall(oneCall) }
                    }
                }
            case .failure(let error):
                print("Geocoding failed: \(error)")
            }
        }
    }

    private func geocode(city: String, completion: @escaping (Result<(Double, Double), Error>) -> Void) {
        let apiKey = Bundle.main.object(forInfoDictionaryKey: "OPEN_WEATHER_API_KEY") as? String ?? ""
        guard !apiKey.isEmpty else {
            completion(.failure(NSError(domain: "MainViewController", code: -10, userInfo: [NSLocalizedDescriptionKey: "Missing OPEN_WEATHER_API_KEY"]))); return
        }
        var comp = URLComponents(string: "https://api.openweathermap.org/geo/1.0/direct")
        comp?.queryItems = [
            URLQueryItem(name: "q", value: city),
            URLQueryItem(name: "limit", value: "1"),
            URLQueryItem(name: "appid", value: apiKey)
        ]
        guard let url = comp?.url else {
            completion(.failure(NSError(domain: "MainViewController", code: -11, userInfo: [NSLocalizedDescriptionKey: "Invalid geocode URL"]))); return
        }
        URLSession.shared.dataTask(with: url) { data, resp, err in
            if let err = err { completion(.failure(err)); return }
            guard let data = data else {
                completion(.failure(NSError(domain: "MainViewController", code: -12, userInfo: [NSLocalizedDescriptionKey: "No geocode data"]))); return
            }
            do {
                let results = try JSONDecoder().decode([GeoResult].self, from: data)
                if let first = results.first {
                    completion(.success((first.lat, first.lon)))
                } else {
                    completion(.failure(NSError(domain: "MainViewController", code: -13, userInfo: [NSLocalizedDescriptionKey: "No geocode result"])))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    private func fetchOneCall(lat: Double, lon: Double, completion: @escaping (OneCallResponse?) -> Void) {
        let apiKey = Bundle.main.object(forInfoDictionaryKey: "OPEN_WEATHER_API_KEY") as? String ?? ""
        guard !apiKey.isEmpty else { completion(nil); return }
        var comp = URLComponents(string: "https://api.openweathermap.org/data/2.5/onecall")
        comp?.queryItems = [
            URLQueryItem(name: "lat", value: String(lat)),
            URLQueryItem(name: "lon", value: String(lon)),
            URLQueryItem(name: "appid", value: apiKey),
            URLQueryItem(name: "units", value: "metric"),
            URLQueryItem(name: "exclude", value: "minutely,alerts")
        ]
        guard let url = comp?.url else { completion(nil); return }
        URLSession.shared.dataTask(with: url) { data, resp, err in
            if let _ = err { completion(nil); return }
            guard let data = data else { completion(nil); return }
            do {
                let decoded = try JSONDecoder().decode(OneCallResponse.self, from: data)
                completion(decoded)
            } catch {
                print("onecall decode error: \(error)")
                completion(nil)
            }
        }.resume()
    }

    @objc private func segmentedChanged(_ sender: UISegmentedControl) {
        let idx = sender.selectedSegmentIndex
        guard idx >= 0, idx < mainViewModel.weatherList.count else { return }
        let city = mainViewModel.weatherList[idx].cityName
        bootstrapOneCall(for: city)
    }
}
