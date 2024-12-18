//
//  MovieCell.swift
//  MovieBookingToMVVM
//
//  Created by Lydia Lu on 2024/12/13.
//

import UIKit

class MovieCell: UITableViewCell {

    // 添加代理協議
    protocol MovieCellDelegate: AnyObject {
        func movieCell(_ cell: MovieCell, didTapDetailButtonFor movieId: Int)
    }
    
    
    private let detailButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("查看詳情", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        // 設置內邊距讓按鈕更美觀
        button.contentEdgeInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.numberOfLines = 8
        return label
    }()
    
    // 添加代理屬性和 movieId
    weak var delegate: MovieCellDelegate?
    private var movieId: Int = 0
    
    
  
    private let movieImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill // 改為 .scaleAspectFit 來保持圖片比例
        imageView.clipsToBounds = true
        imageView.backgroundColor = .systemGray6 // 添加背景色以便識別圖片區域
        return imageView
    }()
    
    
    private let releaseDateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .systemGray
        return label
    }()
    
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        [movieImageView, titleLabel, releaseDateLabel, detailButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        
        // 添加這行來連接按鈕事件
        detailButton.addTarget(self, action: #selector(detailButtonTapped), for: .touchUpInside)

        
        NSLayoutConstraint.activate([
            // 海報圖片約束
            movieImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            movieImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8), // 增加上下間距
            movieImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            movieImageView.widthAnchor.constraint(equalToConstant: 60), // 保持寬度
                        
            
            
            // 詳情按鈕約束 - 固定寬度和位置
            detailButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            detailButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            detailButton.widthAnchor.constraint(equalToConstant: 80), // 固定寬度
            
            // 標題標籤約束
            titleLabel.leadingAnchor.constraint(equalTo: movieImageView.trailingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: detailButton.leadingAnchor, constant: -12),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            
            // 日期標籤約束
            releaseDateLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            releaseDateLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            releaseDateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }
    
    
    
    // 按鈕點擊處理
    @objc private func detailButtonTapped() {
        print("=== Button Tapped in Cell ===")
        print("MovieID: \(movieId)")
        print("Delegate exists: \(delegate != nil)")
        delegate?.movieCell(self, didTapDetailButtonFor: movieId)
    }
    
    
    // 更新 configure 方法
    func configure(with movie: Movie) {
        print("=== Configuring Cell ===")
        print("Setting MovieID: \(movie.id)")
        movieId = movie.id
        titleLabel.text = movie.title
        releaseDateLabel.text = "上映日期：\(movie.releaseDate)"
        
        if let posterPath = movie.posterPath {
            loadImage(from: posterPath)
        }
    }

    
    
    private func loadImage(from path: String) {
        let baseURL = "https://image.tmdb.org/t/p/w200"
        guard let url = URL(string: baseURL + path) else { return }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self?.movieImageView.image = image
                }
            }
        }.resume()
    }
}

