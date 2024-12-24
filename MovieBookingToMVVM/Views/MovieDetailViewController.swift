//
//  MovieDetailViewController.swift
//  MovieBookingToMVVM
//
//  Created by Lydia Lu on 2024/12/13.
//

import UIKit

class MovieDetailViewController: UIViewController {
    // MARK: - Properties
    private var viewModel: MovieDetailViewModel
    
    // MARK: - UI Components
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let posterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .systemGray6
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.numberOfLines = 0
        return label
    }()
    
    private let releaseDateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14)
        label.textColor = .systemGray
        return label
    }()
    
    private let durationLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14)
        label.textColor = .systemGray
        return label
    }()
    
    private let overviewTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "劇情簡介"
        label.font = .systemFont(ofSize: 18, weight: .bold)
        return label
    }()
    
    private let overviewLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16)
        label.numberOfLines = 0
        return label
    }()
    
    private let showTimesButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("選擇場次", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        return button
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    // MARK: - Initialization
    init(viewModel: MovieDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        self.viewModel = MovieDetailViewModel(movieId: 0) // 預設值
        super.init(coder: coder)
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupBindings()
        viewModel.fetchMovieDetail()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        navigationItem.largeTitleDisplayMode = .never
        
        // Add subviews
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // 移除 showTimesButton，只添加其他視圖
        [posterImageView, titleLabel, releaseDateLabel, durationLabel,
         overviewTitleLabel, overviewLabel].forEach { contentView.addSubview($0) }
        
        // 將按鈕直接添加到主視圖
        view.addSubview(showTimesButton)
        view.addSubview(activityIndicator)
        
        // Add target
        showTimesButton.addTarget(self, action: #selector(showTimesButtonTapped), for: .touchUpInside)
    }
    
    private func setupConstraints() {
       let contentGuide = contentView.layoutMarginsGuide
       
       NSLayoutConstraint.activate([
           // ScrollView - 修改 bottom 約束
           scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
           scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
           scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
           scrollView.bottomAnchor.constraint(equalTo: showTimesButton.topAnchor, constant: -20),
           
           // ContentView
           contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
           contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
           contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
           contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
           contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
           
           // PosterImageView
           posterImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
           posterImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
           posterImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
           posterImageView.heightAnchor.constraint(equalTo: posterImageView.widthAnchor, multiplier: 0.6),
           
           // TitleLabel
           titleLabel.topAnchor.constraint(equalTo: posterImageView.bottomAnchor, constant: 16),
           titleLabel.leadingAnchor.constraint(equalTo: contentGuide.leadingAnchor),
           titleLabel.trailingAnchor.constraint(equalTo: contentGuide.trailingAnchor),
           
           // ReleaseDateLabel
           releaseDateLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
           releaseDateLabel.leadingAnchor.constraint(equalTo: contentGuide.leadingAnchor),
           
           // DurationLabel
           durationLabel.centerYAnchor.constraint(equalTo: releaseDateLabel.centerYAnchor),
           durationLabel.leadingAnchor.constraint(equalTo: releaseDateLabel.trailingAnchor, constant: 16),
           
           // OverviewTitleLabel
           overviewTitleLabel.topAnchor.constraint(equalTo: releaseDateLabel.bottomAnchor, constant: 24),
           overviewTitleLabel.leadingAnchor.constraint(equalTo: contentGuide.leadingAnchor),
           overviewTitleLabel.trailingAnchor.constraint(equalTo: contentGuide.trailingAnchor),
           
           // OverviewLabel
           overviewLabel.topAnchor.constraint(equalTo: overviewTitleLabel.bottomAnchor, constant: 8),
           overviewLabel.leadingAnchor.constraint(equalTo: contentGuide.leadingAnchor),
           overviewLabel.trailingAnchor.constraint(equalTo: contentGuide.trailingAnchor),
           overviewLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),  // 新增
           
           // ShowTimesButton - 移動到主視圖並固定在底部
           showTimesButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
           showTimesButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
           showTimesButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
           showTimesButton.heightAnchor.constraint(equalToConstant: 50),
           
           // ActivityIndicator
           activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
           activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
       ])
    }
    

    
    private func setupBindings() {
        viewModel.updateUI = { [weak self] movie in
            DispatchQueue.main.async {
                self?.updateUI(with: movie)
            }
        }
        
        viewModel.showError = { [weak self] error in
            DispatchQueue.main.async {
                self?.showError(message: error)
            }
        }
    }
    
    // MARK: - UI Updates
    
    private func updateUI(with movie: Movie) {
        activityIndicator.stopAnimating()
        
        titleLabel.text = movie.title
        releaseDateLabel.text = "上映日期：\(movie.releaseDate)"
        durationLabel.text = movie.duration.map { "\($0) 分鐘" } ?? "時長未知"
        overviewLabel.text = movie.overview
        
        // Load poster image
        if let posterPath = movie.posterPath {
            loadImage(from: posterPath)
        }
    }
    

    private func loadImage(from path: String) {
        let baseURL = "https://image.tmdb.org/t/p/w500"
        guard let url = URL(string: baseURL + path) else { return }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self?.posterImageView.image = image
                }
            }
        }.resume()
    }
    
    private func showError(message: String) {
        activityIndicator.stopAnimating()
        
        let alert = UIAlertController(title: "錯誤", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "確定", style: .default))
        present(alert, animated: true)
    }
    

    // 在原始 MovieDetailViewController.swift 中
    @objc internal func showTimesButtonTapped() {  // 改為 internal
//        let testVC = SeatLayoutViewController()
        let testVC = ShowtimeSelectionViewController()
        navigationController?.pushViewController(testVC, animated: true)
    }
    
    func configure(with movieId: Int) {
        viewModel = MovieDetailViewModel(movieId: movieId)
    }

}


