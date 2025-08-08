//
//  ListViewModel.swift
//  WeatherApp
//
//  Created by 이돈혁 on 8/6/25.
//

import Foundation

class ListViewModel {
    private let storageKey = "savedLocations"
    private(set) var locations: [String] = []

    var onUpdate: (() -> Void)?

    init() {
        fetchLocations()
    }

    func fetchLocations() {
        let defaults = UserDefaults.standard
        locations = defaults.stringArray(forKey: storageKey) ?? []
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

    private func save() {
        UserDefaults.standard.set(locations, forKey: storageKey)
        onUpdate?()
    }
}
