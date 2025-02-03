//
//  ShowtimeSelectionViewController.swift
//  MovieBookingToMVVM
//
//  Created by Lydia Lu on 2024/12/18.
//

import UIKit

class ShowtimeSelectionViewController: UIViewController {
    // MARK: - Properties
    private let viewModel: ShowtimeSelectionViewModel
//    private var movieTitle: String
    // MARK: - Initialization
    init(viewModel: ShowtimeSelectionViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
   // MARK: - UI Components
    private lazy var calendarView: UICalendarView = {
        let view = UICalendarView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.calendar = .current
        view.fontDesign = .rounded
        view.delegate = self
        view.tintColor = .systemBlue
        
        // 修改可選擇範圍
        let today = Calendar.current.startOfDay(for: Date())
        let threeMonthsLater = Calendar.current.date(byAdding: .month, value: 3, to: today)!
        view.availableDateRange = DateInterval(start: today, end: threeMonthsLater)
        
        // 設置單日選擇模式
        let dateSelection = UICalendarSelectionSingleDate(delegate: self)
        view.selectionBehavior = dateSelection
        
        return view
    }()
    
   private lazy var showtimeCollectionView: UICollectionView = {
       let layout = UICollectionViewFlowLayout()
       layout.scrollDirection = .vertical
       layout.minimumLineSpacing = 10
       layout.minimumInteritemSpacing = 10
       
       let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
       collectionView.translatesAutoresizingMaskIntoConstraints = false
       collectionView.backgroundColor = .systemBackground
       collectionView.delegate = self
       collectionView.dataSource = self
       collectionView.register(ShowtimeCell.self, forCellWithReuseIdentifier: "ShowtimeCell")
       collectionView.allowsMultipleSelection = false
       return collectionView
   }()
   
   private lazy var selectSeatButton: UIButton = {
       let button = UIButton(type: .system)
       button.translatesAutoresizingMaskIntoConstraints = false
       button.setTitle("選擇座位", for: .normal)
       button.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
       button.backgroundColor = .systemBlue
       button.setTitleColor(.white, for: .normal)
       button.layer.cornerRadius = 8
       button.addTarget(self, action: #selector(selectSeatButtonTapped), for: .touchUpInside)
//       button.isEnabled = false
       return button
   }()
   
   
   // MARK: - Lifecycle
   override func viewDidLoad() {
       super.viewDidLoad()
       
       
       title = viewModel.movieTitle // 先設置標題
       print("ShowtimeSelection - 設定標題完成: \(title ?? "沒有標題")")  // 確認標題已設置
           
       
       setupUI()
       setupConstraints()
       setupBindings()
   }
   
   // MARK: - Setup
   private func setupUI() {
       view.backgroundColor = .systemBackground
//       title = "選擇場次"
       
       view.addSubview(calendarView)
       view.addSubview(showtimeCollectionView)
       view.addSubview(selectSeatButton)
   }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            calendarView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            calendarView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            calendarView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            // 移除固定高度約束
            // calendarView.heightAnchor.constraint(equalToConstant: 300),
            
            showtimeCollectionView.topAnchor.constraint(equalTo: calendarView.bottomAnchor, constant: 20),
            showtimeCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            showtimeCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            selectSeatButton.topAnchor.constraint(equalTo: showtimeCollectionView.bottomAnchor, constant: 20),
            selectSeatButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            selectSeatButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            selectSeatButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            selectSeatButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        // 設置 showtimeCollectionView 的高度約束
        let collectionViewHeight = showtimeCollectionView.heightAnchor.constraint(equalToConstant: 200)
        collectionViewHeight.isActive = true
        collectionViewHeight.priority = .defaultHigh  // 設置優先級，讓它可以被壓縮
    }
   
    private func setupBindings() {
        viewModel.updateShowtimes = { [weak self] showtimes in
            self?.showtimeCollectionView.reloadData()
        }
        
        viewModel.updateSelectSeatButtonState = { [weak self] isEnabled in
            self?.selectSeatButton.isEnabled = isEnabled
        }
        
        // 新增提醒綁定
        viewModel.showAlert = { [weak self] in
            self?.showTimeSelectionAlert()
        }
    }
    
    // 修改選座按鈕動作
    @objc private func selectSeatButtonTapped() {
        if viewModel.canProceedToSeatSelection() {
            let seatVC = SeatLayoutViewController()
            
            // 從 viewModel 取得選擇的日期和時間
            if let selectedDate = viewModel.selectedDate,
               let selectedShowtime = viewModel.selectedShowtime {
                print("ShowtimeSelection - 傳送資料到座位頁面")
                print("電影名稱: \(viewModel.movieTitle)")  // 使用 viewModel 中的電影名稱

                // 設定訂票資訊
                seatVC.setupBookingData(
                    movieName: viewModel.movieTitle,
                    showDate: selectedDate,
                    showTime: selectedShowtime.time
                )
            }
            
            navigationController?.pushViewController(seatVC, animated: true)
        }
    }
    
    // 新增提醒方法
    private func showTimeSelectionAlert() {
        let alert = UIAlertController(
            title: "提醒",
            message: "請選擇觀影時段",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "確定", style: .default))
        present(alert, animated: true)
    }

}

// MARK: - UICalendarViewDelegate
extension ShowtimeSelectionViewController: UICalendarViewDelegate {
   func calendarView(_ calendarView: UICalendarView, decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
       return nil
   }
}

// MARK: - UICalendarSelectionSingleDateDelegate
extension ShowtimeSelectionViewController: UICalendarSelectionSingleDateDelegate {
   func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
       guard let dateComponents = dateComponents,
             let date = Calendar.current.date(from: dateComponents) else { return }
       viewModel.selectDate(date)
   }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension ShowtimeSelectionViewController: UICollectionViewDataSource, UICollectionViewDelegate {
   func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       return viewModel.showtimes.count
   }
   
   func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
       let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ShowtimeCell", for: indexPath) as! ShowtimeCell
       let showtime = viewModel.showtimes[indexPath.item]
       cell.configure(with: showtime)
       return cell
   }
   
   func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
       let showtime = viewModel.showtimes[indexPath.item]
       viewModel.selectShowtime(showtime)
   }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension ShowtimeSelectionViewController: UICollectionViewDelegateFlowLayout {
   func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
       let width = (collectionView.bounds.width - 10) / 2
       return CGSize(width: width, height: 60)
   }
}
