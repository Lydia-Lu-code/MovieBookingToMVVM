import Foundation

class MovieDetailViewModel {
    let movieId: Int
    private let apiService: APIServiceProtocol
    private var movie: Movie?
    
    private(set) var movieTitle: String?
    
    var updateUI: ((Movie) -> Void)?
    var showError: ((String) -> Void)?
    
    init(movieId: Int, movieTitle: String? = nil, apiService: APIServiceProtocol = APIService()) {
        self.movieId = movieId
        self.movieTitle = movieTitle
        self.apiService = apiService
    }
    
    func fetchMovieDetail() {
        apiService.fetchMovieDetail(id: movieId) { [weak self] result in
            switch result {
            case .success(let movie):
                self?.movie = movie
                self?.movieTitle = movie.title
                self?.updateUI?(movie)
            case .failure(let error):
                self?.showError?(error.localizedDescription)
            }
        }
    }
    // 取得電影名稱的方法
    func getMovieTitle() -> String {
        return movieTitle ?? "預設電影名稱"
    }
    
 
}
