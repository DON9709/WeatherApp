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
    
    private var results: [GeocodingResult] = []
    private let geocodingService = GeocodingService(apiKey: "<여기에_본인_API키>")
    
    private var searchTask: DispatchWorkItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
    }
    
    private func setupUI() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "back", style: .plain, target: self, action: #selector(backTapped))
        
        view.addSubview(searchBar)
        searchBar.delegate = self
        searchBar.placeholder = "도시 이름 검색"
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
        searchTask?.cancel() // 기존 요청 취소
        guard !searchText.isEmpty else {
            results.removeAll()
            tableView.reloadData()
            return
        }
        
        // 0.3초 딜레이 후 API 요청 (타이핑 중 호출 방지)
        let task = DispatchWorkItem { [weak self] in
            self?.fetchCities(query: searchText)
        }
        searchTask = task
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: task)
    }
    
    private func fetchCities(query: String) {
        geocodingService.searchCity(query, limit: 10) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let cities):
                    self?.results = cities
                    self?.tableView.reloadData()
                case .failure(let error):
                    print("검색 실패:", error)
                    self?.results.removeAll()
                    self?.tableView.reloadData()
                }
            }
        }
    }
    
    // MARK: - Table DataSource & Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let city = results[indexPath.row]
        let state = city.state != nil ? " \(city.state!)" : ""
        cell.textLabel?.text = "\(city.name)\(state), \(city.country)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCity = results[indexPath.row]
        
        // 저장할 때는 이름 + 위도/경도 같이 저장하는 게 안전
        var savedCities = UserDefaults.standard.array(forKey: "savedCities") as? [[String: Any]] ?? []
        
        let cityData: [String: Any] = [
            "name": selectedCity.name,
            "lat": selectedCity.lat,
            "lon": selectedCity.lon,
            "country": selectedCity.country
        ]
        
        // 중복 방지
        if !savedCities.contains(where: { ($0["name"] as? String) == selectedCity.name }) {
            savedCities.append(cityData)
            UserDefaults.standard.set(savedCities, forKey: "savedCities")
        }
        
        navigationController?.popViewController(animated: true)
    }
}
