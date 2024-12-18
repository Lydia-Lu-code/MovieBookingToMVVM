//
//  NetworkLayer.swift
//  MovieBookingToMVVM
//
//  Created by Lydia Lu on 2024/12/13.
//

import Foundation

protocol APIServiceProtocol {
    func fetchNowPlaying(completion: @escaping (Result<[Movie], Error>) -> Void)
    func fetchMovieDetail(id: Int, completion: @escaping (Result<Movie, Error>) -> Void)
}

class APIService: APIServiceProtocol {
    private let baseURL = "https://api.themoviedb.org/3"
    private let apiKey = "89edb46b4a3f5f980e081e1d9ab7bda5"
    
    func fetchNowPlaying(completion: @escaping (Result<[Movie], Error>) -> Void) {
        let urlString = "\(baseURL)/movie/now_playing?api_key=\(apiKey)"
        performRequest(with: urlString, expecting: MovieResponse.self) { result in
            switch result {
            case .success(let response):
                completion(.success(response.results))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func fetchMovieDetail(id: Int, completion: @escaping (Result<Movie, Error>) -> Void) {
        let urlString = "\(baseURL)/movie/\(id)?api_key=\(apiKey)"
        performRequest(with: urlString, expecting: Movie.self, completion: completion)
    }
    
    private func performRequest<T: Decodable>(with urlString: String,
                                            expecting: T.Type,
                                            completion: @escaping (Result<T, Error>) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(NetworkError.invalidResponse))
                return
            }
            
            guard let data = data else {
                completion(.failure(NetworkError.noData))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let result = try decoder.decode(T.self, from: data)
                completion(.success(result))
            } catch {
                completion(.failure(NetworkError.decodingError))
            }
        }.resume()
    }
}



// MARK: - NetworkError
enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case noData
    case decodingError
}
