//
//  SeatLayoutViewModel.swift
//  MovieBookingToMVVM
//
//  Created by Lydia Lu on 2024/12/18.
//

import Foundation
import UIKit

// 票種枚舉
enum TicketType {
    case regular
    case package
    
    var price: Int {
        switch self {
        case .regular: return 280
        case .package: return 280 + 120
        }
    }
}

// ViewModel 協議
protocol SeatLayoutViewModelProtocol {
    var selectedSeats: [SeatLayout] { get }
    var ticketType: TicketType { get }
    
    var updateSelectedSeatsInfo: (() -> Void)? { get set }
    var updateTotalPrice: (() -> Void)? { get set }
    
    func initialize()
    func toggleSeat(at row: Int, column: Int)
    func toggleTicketType()
    func getSelectedSeats() -> [SeatLayout]
    func getSelectedSeatsText() -> String
    func getTotalPrice() -> String
    func getTicketTypeText() -> String
    func clearSelectedSeats()
    
    func isSeatSelected(row: Int, column: Int) -> Bool
    var selectedSeatsCount: Int { get }
}

// 座位版面配置協議
protocol SeatLayoutConfigurationProtocol {
    var numberOfRows: Int { get }
    var seatsPerRow: Int { get }
    var ticketPrice: Int { get }
}

class SeatLayoutViewModel: SeatLayoutViewModelProtocol {
    
    func isSeatSelected(row: Int, column: Int) -> Bool {
        return selectedSeats.contains { $0.row == row && $0.column == column }
    }
    
    var selectedSeatsCount: Int {
        return selectedSeats.count
    }
    
    // 配置
    private let configuration: SeatLayoutConfigurationProtocol
    
    // 座位二維陣列
    private var seats: [[SeatLayout]] = []
    
    // 票種
    private(set) var ticketType: TicketType = .regular {
        didSet {
            updateTotalPrice?()
        }
    }
    
    // 已選座位
    var selectedSeats: [SeatLayout] = [] {
        didSet {
            updateSelectedSeatsInfo?()
            updateTotalPrice?()
        }
    }
    
    
    
    // 狀態更新閉包
    var updateTotalPrice: (() -> Void)?
    var updateSelectedSeatsInfo: (() -> Void)?
    var updateSeatStatus: ((Int, Int, SeatLayoutStatus) -> Void)?
    
    // 初始化
    init(configuration: SeatLayoutConfigurationProtocol = SeatLayoutConfiguration.standard) {
        self.configuration = configuration
    }
    
    // 初始化座位
    func initialize() {
        createInitialSeats()
    }
    
    // 建立初始座位
    private func createInitialSeats() {
        seats = (0..<configuration.numberOfRows).map { row in
            (0..<configuration.seatsPerRow).map { column in
                let isOccupied = Double.random(in: 0...1) < 0.6
                return SeatLayout(
                    row: row,
                    column: column,
                    status: isOccupied ? .occupied : .available
                )
            }
        }
    }
    
    // 座位選擇
    func toggleSeat(at row: Int, column: Int) {
        guard isValidSeatPosition(row: row, column: column) else { return }
        
        // 檢查當前狀態
        let isCurrentlySelected = selectedSeats.contains { $0.row == row && $0.column == column }
        
        if isCurrentlySelected {
            // 移除座位
            selectedSeats.removeAll { $0.row == row && $0.column == column }
        } else {
            // 添加座位
            let newSeat = SeatLayout(row: row, column: column, status: .selected)
            selectedSeats.append(newSeat)
        }
        
        // 通知 UI 更新
        updateSelectedSeatsInfo?()
        updateTotalPrice?()
    }
    
    
    // 切換票種
    func toggleTicketType() {
        ticketType = ticketType == .regular ? .package : .regular
        updateTotalPrice?()
    }
    
    // 取得已選座位
    func getSelectedSeats() -> [SeatLayout] {
        return selectedSeats
    }
    
    // 取得已選座位文字
    func getSelectedSeatsText() -> String {
        if selectedSeats.isEmpty {
            return "已選座位：尚未選擇"
        }
        let sortedSeats = selectedSeats.sorted { ($0.row, $0.column) < ($1.row, $1.column) }
        return "已選座位：" + sortedSeats.map { $0.displayName }.joined(separator: "、")
    }
    
    // 取得總金額
    func getTotalPrice() -> String {
        let currentPrice = ticketType.price
        let total = selectedSeats.count * currentPrice
        return "總金額：$\(total)"
    }
    
    // 取得票種文字
    func getTicketTypeText() -> String {
        switch ticketType {
        case .regular: return "一般票"
        case .package: return "套餐票"
        }
    }
    
    // 清除已選座位
    func clearSelectedSeats() {
        selectedSeats.removeAll()
        updateSelectedSeatsInfo?()
        updateTotalPrice?()
    }
    
    // 驗證座位位置
    private func isValidSeatPosition(row: Int, column: Int) -> Bool {
        row < seats.count && column < seats[row].count
    }
}

