//
//  ShowtimeCell.swift
//  MovieBookingToMVVM
//
//  Created by Lydia Lu on 2024/12/18.
//

import UIKit

class ShowtimeCell: UICollectionViewCell {
   // MARK: - UI Components
   private let stackView: UIStackView = {
       let stack = UIStackView()
       stack.translatesAutoresizingMaskIntoConstraints = false
       stack.axis = .vertical
       stack.alignment = .center
       stack.spacing = 4
       return stack
   }()
   
   private let periodLabel: UILabel = {
       let label = UILabel()
       label.font = .systemFont(ofSize: 14)
       label.textColor = .systemGray
       return label
   }()
   
   private let timeLabel: UILabel = {
       let label = UILabel()
       label.font = .systemFont(ofSize: 18, weight: .medium)
       return label
   }()
   
   // MARK: - Initialization
   override init(frame: CGRect) {
       super.init(frame: frame)
       setupUI()
   }
   
   required init?(coder: NSCoder) {
       fatalError("init(coder:) has not been implemented")
   }
   
   // MARK: - Setup
   private func setupUI() {
       backgroundColor = .systemGray6
       layer.cornerRadius = 8
       
       contentView.addSubview(stackView)
       stackView.addArrangedSubview(periodLabel)
       stackView.addArrangedSubview(timeLabel)
       
       NSLayoutConstraint.activate([
           stackView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
           stackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
       ])
   }
   
   override var isSelected: Bool {
       didSet {
           backgroundColor = isSelected ? .systemBlue.withAlphaComponent(0.2) : .systemGray6
           layer.borderWidth = isSelected ? 2 : 0
           layer.borderColor = isSelected ? UIColor.systemBlue.cgColor : nil
       }
   }
   
   // MARK: - Configuration
   func configure(with showtime: ShowtimeModel) {
       periodLabel.text = showtime.period
       timeLabel.text = showtime.time
       isUserInteractionEnabled = showtime.isAvailable
       alpha = showtime.isAvailable ? 1.0 : 0.5
   }
}
