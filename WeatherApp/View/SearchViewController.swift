//
//  SearchViewController.swift
//  WeatherApp
//
//  Created by 이돈혁 on 8/5/25.
//
//  위치 검색 입력 UI

import UIKit
import SnapKit

final class SearchViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate {
    private let searchBar = UISearchBar()
    private let tableView = UITableView()
    
    private let allCities = [
        "서울", "부산", "대구", "인천", "광주", "대전", "울산",
        "수원", "창원", "성남", "고양", "용인", "전주", "천안", "안산",
        "제주", "포항", "김해", "청주", "춘천"
    ]
    private var filteredCities: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        filteredCities = allCities
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
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Search
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredCities = searchText.isEmpty
            ? allCities
            : allCities.filter { $0.localizedCaseInsensitiveContains(searchText) }
        tableView.reloadData()
    }
    
    // MARK: - Table DataSource & Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredCities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = filteredCities[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCity = filteredCities[indexPath.row]
        
        var savedCities = UserDefaults.standard.stringArray(forKey: "savedCities") ?? []
        if !savedCities.contains(selectedCity) {
            savedCities.append(selectedCity)
            UserDefaults.standard.set(savedCities, forKey: "savedCities")
        }
        
        navigationController?.popViewController(animated: true)
    }
}
