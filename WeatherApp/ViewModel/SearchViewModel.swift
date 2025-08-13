//
//  SearchViewModel.swift
//  WeatherApp
//
//  Created by 이돈혁 on 8/6/25.
//

import Foundation

protocol GeocodingServiceProtocol {
    func searchCity(_ query: String, limit: Int, completion: @escaping (Result<[GeocodingResult], Error>) -> Void)
}

class SearchViewModel {
    // Dependencies
    private let geocoding: GeocodingServiceProtocol
    private let listViewModel: LocalListViewModel

    // State
    private(set) var results: [GeocodingResult] = []
    var searchText: String = "" { didSet { scheduleSearchDebounced() } }

    // Callbacks
    var onResultsUpdate: (() -> Void)?
    var onLocationSaved: (() -> Void)?

    // Debounce
    private var searchTask: DispatchWorkItem?

    init(geocoding: GeocodingServiceProtocol, listViewModel: LocalListViewModel) {
        self.geocoding = geocoding
        self.listViewModel = listViewModel
    }

    // MARK: - 검색
    func updateSearch(text: String) { self.searchText = text }

    private func scheduleSearchDebounced() {
        searchTask?.cancel()
        let text = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else {
            results.removeAll()
            onResultsUpdate?()
            return
        }
        let task = DispatchWorkItem { [weak self] in
            self?.performSearch(query: text)
        }
        searchTask = task
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: task)
    }

    private func performSearch(query: String) {
        geocoding.searchCity(query, limit: 10) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let cities):
                    self.results = cities
                case .failure:
                    self.results = []
                }
                self.onResultsUpdate?()
            }
        }
    }

    // MARK: -
    func numberOfResults() -> Int { results.count }
    func result(at index: Int) -> GeocodingResult? {
        guard results.indices.contains(index) else { return nil }
        return results[index]
    }

    // MARK: - 
    func selectResult(at index: Int) {
        guard let city = result(at: index) else { return }
        let name = city.name
        if !listViewModel.locations.contains(name) {
            listViewModel.addLocation(name) // saves to "savedCities" via VM
        }
        onLocationSaved?()
    }
}
