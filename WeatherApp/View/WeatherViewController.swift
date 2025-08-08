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
}

// MARK: - HourlyWeatherCell

final class HourlyWeatherCell: UIView {
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 8
        layout.itemSize = CGSize(width: 60, height: 100)
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()

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
        collectionView.snp.makeConstraints { $0.edges.equalToSuperview().inset(16) }

        snp.makeConstraints { $0.height.equalTo(140) }
    }
}

// MARK: - WeeklyForecastCell

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
}

