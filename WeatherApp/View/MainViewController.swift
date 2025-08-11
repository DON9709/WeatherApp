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
    private let ListButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.systemBlue
        setupUI()
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
        let regionCell = RegionWeatherCell()
        let hourlyCell = HourlyWeatherCell()
        let weeklyCell = WeeklyForecastCell()

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
}
