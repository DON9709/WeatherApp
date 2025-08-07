//
//  MainViewController.swift
//  WeatherApp
//
//  Created by 송명균 on 8/7/25.
//



import UIKit
import SnapKit

final class MainViewController: UIViewController {
    private let scrollView = UIScrollView()
    private let contentView = UIStackView()

    private let segmentedControl = UISegmentedControl(items: ["지역1", "지역2"])
    private let flashlightButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.systemBlue
        setupUI()
    }

    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { $0.edges.equalToSuperview() }

        scrollView.addSubview(contentView)
        contentView.axis = .vertical
        contentView.spacing = 16
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }

        let regionCell = RegionWeatherCell()
        let hourlyCell = HourlyWeatherCell()
        let weeklyCell = WeeklyForecastCell()

        [regionCell, hourlyCell, weeklyCell].forEach {
            contentView.addArrangedSubview($0)
        }

        view.addSubview(segmentedControl)
        segmentedControl.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(16)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(8)
        }

        view.addSubview(flashlightButton)
        flashlightButton.snp.makeConstraints {
            $0.right.equalToSuperview().inset(16)
            $0.bottom.equalTo(segmentedControl.snp.top).offset(20)
            $0.width.height.equalTo(40)
        }
    }
}

