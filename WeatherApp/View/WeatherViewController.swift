//
//  WeatherViewController.swift
//  WeatherApp
//
//  Created by 이돈혁 on 8/5/25.
//
//  날씨정보 표시 UI

import UIKit
import SnapKit

final class RegionWeatherCell: UIView {
    private let label = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemTeal
        layer.cornerRadius = 16
        setup()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setup() {
        addSubview(label)
        label.text = "지역 이름, 현재 기온, 최고/최저"
        label.textColor = .white
        label.textAlignment = .center
        label.snp.makeConstraints { $0.edges.equalToSuperview().inset(16) }

        snp.makeConstraints { $0.height.equalTo(120) }
    }

    // MARK: - 데이터 바인딩
    func update(with data: RegionWeatherData) {
        let cityName = data.city.isEmpty ? "—" : data.city
        let current = String(format: "%.1f°C", data.currentTemp)
        let min = String(format: "%.1f°C", data.minTemp)
        let max = String(format: "%.1f°C", data.maxTemp)
        label.text = "\(cityName)  \(current)  (최저 \(min) / 최고 \(max))"
    }
}

// MARK: - 시간별

final class HourlyWeatherCell: UIView {
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 8
        layout.itemSize = CGSize(width: 60, height: 100)
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()

    private var items: [HourlyWeatherItem] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemIndigo
        layer.cornerRadius = 16
        setup()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setup() {
        addSubview(collectionView)
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.register(HourCell.self, forCellWithReuseIdentifier: "HourCell")
        collectionView.snp.makeConstraints { $0.edges.equalToSuperview().inset(16) }

        snp.makeConstraints { $0.height.equalTo(140) }
    }

    // MARK: - 데이터 바인딩
    func update(items: [HourlyWeatherItem]) {
        self.items = items
        collectionView.reloadData()
    }
}

private final class HourCell: UICollectionViewCell {
    private let label = UILabel()
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(label)
        label.numberOfLines = 3
        label.textAlignment = .center
        label.textColor = .white
        label.font = .systemFont(ofSize: 12)
        label.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
    required init?(coder: NSCoder) { fatalError() }
    func configure(_ item: HourlyWeatherItem) {
        label.text = "\(item.hour)\n\(item.icon)\n\(item.temp)"
    }
}

extension HourlyWeatherCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HourCell", for: indexPath) as! HourCell
        cell.configure(items[indexPath.item])
        return cell
    }
}

// MARK: - 주간

final class WeeklyForecastCell: UIView {
    private let stackView = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemCyan
        layer.cornerRadius = 16
        setup()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setup() {
        addSubview(stackView)
        stackView.axis = .vertical
        stackView.spacing = 8

        (0..<5).forEach { _ in
            let row = UILabel()
            row.text = "요일, 아이콘, 최저/최고"
            row.textColor = .white
            stackView.addArrangedSubview(row)
        }

        stackView.snp.makeConstraints { $0.edges.equalToSuperview().inset(16) }

        snp.makeConstraints { $0.height.equalTo(240) }
    }

    // MARK: - 데이터 바인딩
    func update(items: [DailyWeatherItem]) {
        // Clear old rows
        stackView.arrangedSubviews.forEach { row in
            stackView.removeArrangedSubview(row)
            row.removeFromSuperview()
        }
        // Add up to 5 rows
        for item in items.prefix(5) {
            let row = UILabel()
            row.text = "\(item.day)   \(item.icon)   최저 \(item.minTemp) / 최고 \(item.maxTemp)"
            row.textColor = .white
            stackView.addArrangedSubview(row)
        }
    }
}
