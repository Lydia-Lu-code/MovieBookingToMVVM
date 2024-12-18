//
//  ViewModels.swift
//  MovieBookingToMVVM
//
//  Created by Lydia Lu on 2024/12/13.
//

import Foundation


class MovieListViewModel {
    private let apiService: APIServiceProtocol
    private var movies: [Movie] = []
    
    var numberOfMovies: Int { movies.count }
    var reloadData: (() -> Void)?
    var updateLoadingStatus: ((Bool) -> Void)?
    var showError: ((String) -> Void)?
    
    init(apiService: APIServiceProtocol = APIService()) {
        self.apiService = apiService
    }
    
    func movie(at index: Int) -> Movie {
        return movies[index]
    }
    
    func fetchNowPlaying() {
        updateLoadingStatus?(true)
        apiService.fetchNowPlaying { [weak self] result in
            self?.updateLoadingStatus?(false)
            switch result {
            case .success(let movies):
                self?.movies = movies
                self?.reloadData?()
            case .failure(let error):
                self?.showError?(error.localizedDescription)
            }
        }
    }
}

