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
    private let viewModel: SearchViewModel
    private let searchBar = UISearchBar()
    private let tableView = UITableView()

    init(viewModel: SearchViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        
        viewModel.onResultsUpdate = { [weak self] in
            self?.tableView.reloadData()
        }
        viewModel.onLocationSaved = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
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
    
    // MARK: - 검색
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.updateSearch(text: searchText)
    }
    
    // MARK: - 테이블 데이터소스 & 델리게이트
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfResults()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        if let city = viewModel.result(at: indexPath.row) {
            let state = city.state.map { " \($0)" } ?? ""
            cell.textLabel?.text = "\(city.name)\(state), \(city.country)"
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.selectResult(at: indexPath.row)
    }
}
