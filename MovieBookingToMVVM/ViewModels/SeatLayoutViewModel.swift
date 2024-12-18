//
//  SeatLayoutViewModel.swift
//  MovieBookingToMVVM
//
//  Created by Lydia Lu on 2024/12/18.
//

import Foundation

class SeatLayoutViewModel {
    // MARK: - Properties
    private let configuration: SeatLayoutConfiguration
    private var seats: [[SeatLayout]] = []
    
    // MARK: - Published Properties
    var selectedSeats: [SeatLayout] = [] {
        didSet {
            updateSelectedSeatsInfo?()
        }
    }
    
    // MARK: - Public Properties
    var numberOfRows: Int { configuration.numberOfRows }
    var seatsPerRow: Int { configuration.seatsPerRow }
    
    // MARK: - Callbacks
    var updateSelectedSeatsInfo: (() -> Void)?
    var updateSeatStatus: ((Int, Int, SeatLayoutStatus) -> Void)?
    
    // MARK: - Initialization
    init(configuration: SeatLayoutConfiguration = .standard) {
        self.configuration = configuration
    }
    
    // MARK: - Public Methods
    func initialize() {
        createInitialSeats()
    }
    
    func toggleSeat(at row: Int, column: Int) {
        guard isValidSeatPosition(row: row, column: column) else { return }
        
        var seat = seats[row][column]
        guard seat.status != .occupied else { return }
        
        updateSeatStatus(seat: &seat, at: row, column: column)
    }
    
    func getDisplayInfo() -> SeatDisplayInfo {
        return SeatDisplayInfo(
            seatsText: getSelectedSeatsText(),
            totalPriceText: getTotalPriceText()
        )
    }
    
    // MARK: - Private Methods
    private func createInitialSeats() {
        seats = (0..<numberOfRows).map { row in
            (0..<seatsPerRow).map { column in
                let isAvailable = Double.random(in: 0...1) < 0.6  // 60% 機率是可選的（淺灰色）
                return SeatLayout(
                    row: row,
                    column: column,
                    status: isAvailable ? .occupied : .available  // 改變這裡的邏輯
                )
            }
        }
    }
    
    
    private func updateSeatStatus(seat: inout SeatLayout, at row: Int, column: Int) {
        if seat.status == .selected {
            seat.status = .occupied    // 取消選擇時恢復為淺灰色（可選狀態）
            selectedSeats.removeAll { $0.row == row && $0.column == column }
        } else {
            seat.status = .selected
            selectedSeats.append(seat)
        }
        
        seats[row][column] = seat
        updateSeatStatus?(row, column, seat.status)
    }
    
    
    private func isValidSeatPosition(row: Int, column: Int) -> Bool {
        row < seats.count && column < seats[row].count
    }

    
    private func getSelectedSeatsText() -> String {
        if selectedSeats.isEmpty {
            return "已選座位：尚未選擇"
        }
        let sortedSeats = selectedSeats.sorted { ($0.row, $0.column) < ($1.row, $1.column) }
        return "已選座位：" + sortedSeats.map { $0.displayName }.joined(separator: "、")
    }
    
    private func getTotalPriceText() -> String {
        return "總金額：$\(selectedSeats.count * configuration.ticketPrice)"
    }
}

