//
//  ViewController.swift
//  MovieBookingToMVVM
//
//  Created by Lydia Lu on 2024/12/13.
//

import UIKit

class MovieListViewController: UIViewController {
    private let viewModel: MovieListViewModel
    private let tableView = UITableView()
    private let refreshControl = UIRefreshControl()
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    
    init(viewModel: MovieListViewModel = MovieListViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        self.viewModel = MovieListViewModel()
        super.init(coder: coder)
    }
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        viewModel.fetchNowPlaying()
    }
    
    private func setupUI() {
        title = "電影"
        view.backgroundColor = .systemBackground
        
        // TableView setup
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        tableView.register(MovieCell.self, forCellReuseIdentifier: "MovieCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.refreshControl = refreshControl
        
        // Activity indicator setup
        view.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    private func setupBindings() {
        viewModel.reloadData = { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
                self?.refreshControl.endRefreshing()
            }
        }
        
        viewModel.updateLoadingStatus = { [weak self] isLoading in
            DispatchQueue.main.async {
                if isLoading {
                    self?.activityIndicator.startAnimating()
                } else {
                    self?.activityIndicator.stopAnimating()
                }
            }
        }
        
        viewModel.showError = { [weak self] error in
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "錯誤", message: error, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "確定", style: .default))
                self?.present(alert, animated: true)
            }
        }
        
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
    }
    
    @objc private func refreshData() {
        viewModel.fetchNowPlaying()
    }
}

// MARK: - UITableViewDelegate & DataSource
extension MovieListViewController: UITableViewDelegate, UITableViewDataSource, MovieCell.MovieCellDelegate {
    
    func movieCell(_ cell: MovieCell, didTapDetailButtonFor movieId: Int) {
        print("=== Delegate Method Called ===")
        print("MovieID received: \(movieId)")
        print("NavigationController exists: \(navigationController != nil)")
        
        DispatchQueue.main.async { [weak self] in
            let detailViewModel = MovieDetailViewModel(movieId: movieId)
            let detailVC = MovieDetailViewController(viewModel: detailViewModel)
            print("DetailVC created with movieId: \(movieId)")
            
            self?.navigationController?.pushViewController(detailVC, animated: true)
            
            if self?.navigationController == nil {
                print("!!! Navigation controller is nil !!!")
            } else {
                print("Navigation controller is available")
            }
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell
        let movie = viewModel.movie(at: indexPath.row)
        cell.configure(with: movie)
        cell.delegate = self
        print("=== Cell Configured at index \(indexPath.row) ===")
        print("Set delegate for movieId: \(movie.id)")
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 100
        }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return viewModel.numberOfMovies
        }


}
