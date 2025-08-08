//
//  LocalListViewController.swift
//  WeatherApp
//
//  Created by 송명균 on 8/7/25.
//

import UIKit
import SnapKit

final class ListViewController: UIViewController {
    private let tableView = UITableView(frame: .zero, style: .plain)
    private var locations: [String] = []
    private var selectedIndexSet: Set<Int> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        setupNavigation()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadSavedCities()
    }
    
    private func setupNavigation() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "back",
            style: .plain,
            target: self,
            action: #selector(backButtonTapped)
        )
    }
    
    private func setupUI() {
        let titleLabel = UILabel()
        titleLabel.text = "local list"
        titleLabel.font = .boldSystemFont(ofSize: 28)
        
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(8)
            $0.left.equalToSuperview().inset(16)
        }
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.left.right.bottom.equalToSuperview()
        }
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorInset = .zero
        tableView.register(ButtonRowCell.self, forCellReuseIdentifier: "ButtonRowCell")
        tableView.register(ListCell.self, forCellReuseIdentifier: "ListCell")
    }
    
    private func loadSavedCities() {
        locations = UserDefaults.standard.stringArray(forKey: "savedCities") ?? []
        tableView.reloadData()
    }
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    private func addLocation() {
        let searchVC = SearchViewController()
        navigationController?.pushViewController(searchVC, animated: true)
    }
    
    private func deleteSelectedLocations() {
        locations = locations.enumerated()
            .filter { !selectedIndexSet.contains($0.offset) }
            .map { $0.element }
        
        selectedIndexSet.removeAll()
        UserDefaults.standard.set(locations, forKey: "savedCities")
        tableView.reloadData()
    }
}

extension ListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ButtonRowCell", for: indexPath) as! ButtonRowCell
            cell.addAction = { [weak self] in self?.addLocation() }
            cell.deleteAction = { [weak self] in self?.deleteSelectedLocations() }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ListCell", for: indexPath) as! ListCell
            let row = indexPath.row - 1
            let isSelected = selectedIndexSet.contains(row)
            cell.configure(title: locations[row], isChecked: isSelected)
            cell.checkButtonAction = { [weak self] in
                guard let self = self else { return }
                if isSelected {
                    self.selectedIndexSet.remove(row)
                } else {
                    self.selectedIndexSet.insert(row)
                }
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.row == 0 ? 50 : 44
    }
}

// 버튼 행 셀
final class ButtonRowCell: UITableViewCell {
    private let addButton = UIButton(type: .system)
    private let deleteButton = UIButton(type: .system)
    
    var addAction: (() -> Void)?
    var deleteAction: (() -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = UIColor.systemGray6
        
        addButton.setImage(UIImage(systemName: "plus"), for: .normal)
        addButton.tintColor = .systemBlue
        
        deleteButton.setImage(UIImage(systemName: "trash"), for: .normal)
        deleteButton.tintColor = .red
        
        let stack = UIStackView(arrangedSubviews: [addButton, deleteButton])
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        contentView.addSubview(stack)
        stack.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        addButton.addTarget(self, action: #selector(addTapped), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
    }
    
    @objc private func addTapped() { addAction?() }
    @objc private func deleteTapped() { deleteAction?() }
    
    required init?(coder: NSCoder) { fatalError() }
}

// 리스트 셀
final class ListCell: UITableViewCell {
    private let titleLabel = UILabel()
    private let checkButton = UIButton(type: .system)
    var checkButtonAction: (() -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        
        checkButton.setImage(UIImage(systemName: "square"), for: .normal)
        checkButton.tintColor = .gray
        checkButton.addTarget(self, action: #selector(checkTapped), for: .touchUpInside)
        
        let stack = UIStackView(arrangedSubviews: [titleLabel, UIView(), checkButton])
        stack.axis = .horizontal
        stack.spacing = 20
        contentView.addSubview(stack)
        stack.snp.makeConstraints { $0.edges.equalToSuperview().inset(12) }
    }
    
    @objc private func checkTapped() {
        checkButtonAction?()
    }
    
    func configure(title: String, isChecked: Bool) {
        titleLabel.text = title
        checkButton.setImage(
            UIImage(systemName: isChecked ? "checkmark.square.fill" : "square"),
            for: .normal
        )
        checkButton.tintColor = isChecked ? .systemBlue : .gray
    }
    
    required init?(coder: NSCoder) { fatalError() }
}
