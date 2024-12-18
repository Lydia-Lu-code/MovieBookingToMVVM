//
//  MovieDetailViewModel.swift
//  MovieBookingToMVVM
//
//  Created by Lydia Lu on 2024/12/13.
//

import Foundation

class MovieDetailViewModel {
    let movieId: Int
    private let apiService: APIServiceProtocol
    private var movie: Movie?
    
    var updateUI: ((Movie) -> Void)?
    var showError: ((String) -> Void)?
    
    init(movieId: Int, apiService: APIServiceProtocol = APIService()) {
        self.movieId = movieId
        self.apiService = apiService
    }
    
    func fetchMovieDetail() {
        apiService.fetchMovieDetail(id: movieId) { [weak self] result in
            switch result {
            case .success(let movie):
                self?.movie = movie
                self?.updateUI?(movie)
            case .failure(let error):
                self?.showError?(error.localizedDescription)
            }
        }
    }
}


