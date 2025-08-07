//
//  LocalListViewController.swift
//  WeatherApp
//
//  Created by 송명균 on 8/7/25.
//

import UIKit
import SnapKit

final class ListViewController: UIViewController {
    private let tableView = UITableView()
    private let deleteButton = UIButton(type: .system)
    private let addButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "local list"
        setupUI()
    }

    private func setupUI() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "back", style: .plain, target: nil, action: nil)

        view.addSubview(tableView)
        tableView.snp.makeConstraints { $0.edges.equalToSuperview() }

        view.addSubview(deleteButton)
        deleteButton.setTitle("🗑️", for: .normal)
        deleteButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(8)
            $0.right.equalToSuperview().inset(16)
        }

        view.addSubview(addButton)
        addButton.setTitle("+", for: .normal)
        addButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(8)
            $0.left.equalToSuperview().inset(16)
        }
    }
}
