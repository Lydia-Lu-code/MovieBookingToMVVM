

import Foundation

class MovieListViewModel {
    // MARK: - Properties
    private let apiService: APIServiceProtocol
    private var movies: [Movie] = []
    
    // MARK: - Output
    var numberOfMovies: Int { movies.count }
    var reloadData: (() -> Void)?
    var updateLoadingStatus: ((Bool) -> Void)?
    var showError: ((String) -> Void)?
    
    // MARK: - Initialization
    init(apiService: APIServiceProtocol = APIService()) {
        self.apiService = apiService
    }
    
    // MARK: - Public Methods
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



