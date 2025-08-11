//
//  ListViewModel.swift
//  WeatherApp
//
//  Created by 이돈혁 on 8/6/25.
//

import Foundation

class LocalListViewModel {
    private let storageKey = "savedCities"
    private(set) var locations: [String] = []
    private(set) var selectedIndices: Set<Int> = []

    var onUpdate: (() -> Void)?

    init() {
        fetchLocations()
    }

    func fetchLocations() {
        let defaults = UserDefaults.standard
        locations = defaults.stringArray(forKey: storageKey) ?? []
        selectedIndices.removeAll()
        onUpdate?()
    }

    func addLocation(_ location: String) {
        guard !locations.contains(location) else { return }
        locations.append(location)
        save()
    }

    func removeLocation(at index: Int) {
        guard locations.indices.contains(index) else { return }
        locations.remove(at: index)
        save()
    }

    func numberOfLocations() -> Int {
        return locations.count
    }

    func location(at index: Int) -> String? {
        guard locations.indices.contains(index) else { return nil }
        return locations[index]
    }

    private func save() {
        UserDefaults.standard.set(locations, forKey: storageKey)
        selectedIndices.removeAll()
        onUpdate?()
    }

    // MARK: - 선택영역
    func toggleSelection(at index: Int) {
        guard locations.indices.contains(index) else { return }
        if selectedIndices.contains(index) {
            selectedIndices.remove(index)
        } else {
            selectedIndices.insert(index)
        }
        onUpdate?()
    }

    func isSelected(at index: Int) -> Bool {
        return selectedIndices.contains(index)
    }

    func deleteSelected() {
        guard !selectedIndices.isEmpty else { return }
        let toDelete = selectedIndices
        locations = locations.enumerated().filter { !toDelete.contains($0.offset) }.map { $0.element }
        save()
    }
}
