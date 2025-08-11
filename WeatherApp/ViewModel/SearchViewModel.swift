//
//  SearchViewModel.swift
//  WeatherApp
//
//  Created by 이돈혁 on 8/6/25.
//

import Foundation

class SearchViewModel {
    var searchText: String = "" {
        didSet {
            updateSearchResults()
        }
    }

    private(set) var filteredResults: [String] = []
    var allLocations: [String] = ["서울", "부산", "인천", "대구", "대전", "광주", "제주"] // 임시 지역 써둔거임

    var onResultsUpdate: (() -> Void)?
    var onLocationSelected: ((String) -> Void)?

    private func updateSearchResults() {
        if searchText.isEmpty {
            filteredResults = []
        } else {
            filteredResults = allLocations.filter {
                $0.localizedCaseInsensitiveContains(searchText)
            }
        }
        onResultsUpdate?()
    }

    func selectLocation(_ location: String) {
        onLocationSelected?(location)
    }

    func numberOfResults() -> Int {
        return filteredResults.count
    }

    func result(at index: Int) -> String? {
        guard filteredResults.indices.contains(index) else { return nil }
        return filteredResults[index]
    }
}
