//
//  SeatLayout2ViewController.swift
//  MovieBookingToMVVM
//
//  Created by Lydia Lu on 2024/12/17.
//

import UIKit

class SeatLayoutViewController: UIViewController {
    private var selectedButtons: Set<UIButton> = []
    private let numberOfRows = 8
    private let seatsPerRow = 10
    private let labelSize: CGFloat = 30
    
    private let ticketPrice: Int = 280  // 每張票價格
    
    // 新增的UI元件
    private lazy var selectedSeatsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "已選座位："
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var totalPriceLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "總金額：$0"
        label.font = .systemFont(ofSize: 18, weight: .bold)
        return label
    }()
    
    private lazy var infoStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.alignment = .leading
        return stackView
    }()
    
    private lazy var containerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 5
        return stackView
    }()
    
    private lazy var rowLabelsStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 5
        //        stackView.distribution = .fillEqually
        stackView.distribution = .fill
        return stackView
    }()
    
    private lazy var mainContentStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 5
        return stackView
    }()
    
    private lazy var columnLabelsStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 5
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    private lazy var mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 5
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    private lazy var ticketTypeSegment: UISegmentedControl = {
        let segment = UISegmentedControl(items: ["一般票", "套餐票"])
        segment.translatesAutoresizingMaskIntoConstraints = false
        segment.selectedSegmentIndex = 0
        segment.addTarget(self, action: #selector(ticketTypeChanged(_:)), for: .valueChanged)
        return segment
    }()
    
    private lazy var checkoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        button.layer.cornerRadius = 8
        button.setTitle("去結帳", for: .normal)
        button.addTarget(self, action: #selector(checkoutButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Properties
    private let viewModel: SeatLayoutViewModel
    
    // MARK: - Initialization
    init(viewModel: SeatLayoutViewModel = SeatLayoutViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        self.viewModel = SeatLayoutViewModel()
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        createSeatingLayout()
        setupInfoSection()
        setupTicketControls()
        setupBindings()
        
        viewModel.initialize()
    }
    
    @objc private func seatTapped(_ sender: UIButton) {
        if selectedButtons.contains(sender) {
            selectedButtons.remove(sender)
            sender.backgroundColor = .systemGray5
        } else {
            selectedButtons.insert(sender)
            sender.backgroundColor = .systemGreen
        }
        
        let row = sender.tag / seatsPerRow
        let column = sender.tag % seatsPerRow
        viewModel.toggleSeat(at: row, column: column)
        
        updateSelectionInfo()
    }

    private func updateSelectionInfo() {
        let sortedSeats = selectedButtons.sorted { $0.tag < $1.tag }
        let seatLabels = sortedSeats.map { button -> String in
            let row = button.tag / seatsPerRow
            let seat = button.tag % seatsPerRow + 1
            let rowLabel = String(UnicodeScalar("A".unicodeScalars.first!.value + UInt32(row))!)
            return "\(rowLabel)\(seat)"
        }
        
        let greenButtonsCount = selectedButtons.filter { $0.backgroundColor == .systemGreen }.count
        
        let currentTicketPrice = (ticketTypeSegment.selectedSegmentIndex == 0) ? 280 : 400
        
        if seatLabels.isEmpty {
            selectedSeatsLabel.text = "已選座位：尚未選擇"
            totalPriceLabel.text = "總金額：$0"
        } else {
            selectedSeatsLabel.text = "已選座位：" + seatLabels.joined(separator: "、")
            
            let totalPrice = greenButtonsCount * currentTicketPrice
            totalPriceLabel.text = "總金額：$\(totalPrice)"
        }
    }
    
    private func updateSeatsInfo() {
        selectedSeatsLabel.text = viewModel.getSelectedSeatsText()
    }
    
    private func updateTotalPriceDisplay() {
        totalPriceLabel.text = viewModel.getTotalPrice()
    }



    // 在 setupBindings 中
    private func setupBindings() {
        viewModel.updateSelectedSeatsInfo = { [weak self] in
            self?.updateSeatsInfo()
        }
        
        viewModel.updateTotalPrice = { [weak self] in
            self?.updateTotalPriceDisplay()
        }
    }
    
    
    @objc private func ticketTypeChanged(_ sender: UISegmentedControl) {
        viewModel.toggleTicketType()
        
        // 手動觸發更新金額顯示
        updateSelectionInfo()
    }
    
    private func setupTicketControls() {
        // 移除 ticketCountControl，只保留 ticketTypeSegment
        view.addSubview(ticketTypeSegment)
        view.addSubview(checkoutButton)
        
        // 預設選擇一般票
        ticketTypeSegment.selectedSegmentIndex = 0
        
        NSLayoutConstraint.activate([
            ticketTypeSegment.topAnchor.constraint(equalTo: infoStackView.bottomAnchor, constant: 20),
            ticketTypeSegment.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            ticketTypeSegment.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            checkoutButton.heightAnchor.constraint(equalToConstant: 50),
            checkoutButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            checkoutButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            checkoutButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
   
    
    @objc private func checkoutButtonTapped() {
        // 這裡添加結帳邏輯
    }
    

    
    private func setupInfoSection() {
        view.addSubview(infoStackView)
        infoStackView.addArrangedSubview(selectedSeatsLabel)
        infoStackView.addArrangedSubview(totalPriceLabel)
        
        NSLayoutConstraint.activate([
            infoStackView.topAnchor.constraint(equalTo: containerStackView.bottomAnchor, constant: 20),
            infoStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            infoStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    
    private func createSeatingLayout() {
       // 1. 創建座位按鈕
       var buttonReferences: [UIButton] = [] // 保存第一列按鈕的引用
       
       for row in 0..<numberOfRows {
           let rowStack = UIStackView()
           rowStack.axis = .horizontal
           rowStack.spacing = 5
           rowStack.distribution = .fillEqually
           
           for seat in 0..<seatsPerRow {
               let button = UIButton()
               // 隨機決定是否將座位設為已占用（60%的機率）
               let isOccupied = Double.random(in: 0...1) < 0.6
               button.backgroundColor = isOccupied ? .systemGray3 : .systemGray5  // 已占用座位用深一點的灰色
               button.layer.cornerRadius = 5
               button.tag = row * seatsPerRow + seat
               button.addTarget(self, action: #selector(seatTapped(_:)), for: .touchUpInside)
               button.isEnabled = !isOccupied  // 已占用的座位不能點擊
               rowStack.addArrangedSubview(button)
               
               // 保存第一列的按鈕引用
               if seat == 0 {
                   buttonReferences.append(button)
               }
           }
           
           mainStackView.addArrangedSubview(rowStack)
       }
       
       // 2. 創建標籤
       let cornerLabel = UILabel()
       cornerLabel.heightAnchor.constraint(equalToConstant: labelSize).isActive = true
       rowLabelsStack.addArrangedSubview(cornerLabel)
       
       // 3. 創建並添加字母標籤
       var rowLabels: [UILabel] = []
       for row in 0..<numberOfRows {
           let label = UILabel()
           label.text = String(UnicodeScalar("A".unicodeScalars.first!.value + UInt32(row))!)
           label.textAlignment = .center
           label.font = .systemFont(ofSize: 14, weight: .medium)
           rowLabelsStack.addArrangedSubview(label)
           rowLabels.append(label)
       }
       
       // 4. 創建數字標籤
       for column in 0..<seatsPerRow {
           let label = UILabel()
           label.text = "\(column + 1)"
           label.textAlignment = .center
           label.font = .systemFont(ofSize: 14, weight: .medium)
           columnLabelsStack.addArrangedSubview(label)
       }
       
       // 等所有視圖都加入層級後，設置高度約束
       DispatchQueue.main.async {
           // 確保在主線程中設置約束
           for (index, label) in rowLabels.enumerated() {
               if index < buttonReferences.count {
                   label.heightAnchor.constraint(equalTo: buttonReferences[index].heightAnchor).isActive = true
               }
           }
       }
    }

    private func setupLayout() {
        view.backgroundColor = .systemBackground
        title = "選擇座位"
        
        // 確保先建立視圖層級
        view.addSubview(containerStackView)
        containerStackView.addArrangedSubview(rowLabelsStack)
        containerStackView.addArrangedSubview(mainContentStack)
        mainContentStack.addArrangedSubview(columnLabelsStack)
        mainContentStack.addArrangedSubview(mainStackView)
        
        NSLayoutConstraint.activate([
            containerStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            containerStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            containerStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            rowLabelsStack.widthAnchor.constraint(equalToConstant: labelSize)
        ])
    }
}
