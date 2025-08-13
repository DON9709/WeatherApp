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
    private let ChangeButton = UIButton(type: .system)
    
    // Weather subviews as properties for data updates
    private let regionCell = RegionWeatherCell()
    private let hourlyCell = HourlyWeatherCell()
    private let weeklyCell = WeeklyForecastCell()
    
    // ViewModel for weather data
    private let weatherViewModel = WeatherViewModel()
    private let mainViewModel = MainViewModel()

    // Service for /weather + /forecast (무료 엔드포인트)
    private let weatherService = WeatherService()
    
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
        //변환 버튼
        bottomBar.addSubview(ChangeButton)
        ChangeButton.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        ChangeButton.tintColor = .white
        ChangeButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().inset(16)
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
        if let first = locations.first { fetch(city: first) }
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
        // TODO: 변수 이름 확인
        // Update regionCell with OneCall-based region data
      if let region = weatherViewModel.current {
            regionCell.update(with: region)
        }
        
        // Update hourly and weekly cells with actual data
        hourlyCell.update(items: weatherViewModel.hourly)
        weeklyCell.update(items: weatherViewModel.daily)

    }

    // MARK: - Free API pipeline (/weather + /forecast → WeatherViewModel)
    private func fetch(city: String) {
        weatherService.fetchCurrentWeather(city: city) { [weak self] curResult in
            switch curResult {
            case .success(let current):
                self?.weatherService.fetchForecast(city: city) { frResult in
                    switch frResult {
                    case .success(let forecast):
                        self?.weatherViewModel.configure(current: current, forecast: forecast)
                    case .failure(let error):
                        print("forecast error:", error)
                    }
                }
            case .failure(let error):
                print("current error:", error)
            }
        }
    }
    
    @objc private func segmentedChanged(_ sender: UISegmentedControl) {
        let idx = sender.selectedSegmentIndex
        guard idx >= 0, idx < mainViewModel.weatherList.count else { return }
        let city = mainViewModel.weatherList[idx].cityName
        fetch(city: city)
    }
    
}
