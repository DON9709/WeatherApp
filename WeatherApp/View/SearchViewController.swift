//
//  SearchViewController.swift
//  WeatherApp
//
//  Created by 이돈혁 on 8/5/25.
//
//  위치 검색 입력 UI

import UIKit
import SnapKit

final class SearchViewController: UIViewController, UISearchBarDelegate {
    private let searchBar = UISearchBar()
    private let tableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
    }

    private func setupUI() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "back", style: .plain, target: self, action: #selector(backTapped))

        view.addSubview(searchBar)
        searchBar.delegate = self
        searchBar.placeholder = "Search"
        searchBar.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.left.right.equalToSuperview()
        }

        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.top.equalTo(searchBar.snp.bottom)
            $0.left.right.bottom.equalToSuperview()
        }
    }

    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }
}
