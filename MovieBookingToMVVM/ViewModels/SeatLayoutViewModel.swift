//
//  SeatLayoutViewModel.swift
//  MovieBookingToMVVM
//
//  Created by Lydia Lu on 2024/12/18.
//

import Foundation

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

class SeatLayoutViewModel {
    private let configuration: SeatLayoutConfiguration
    private var seats: [[SeatLayout]] = []
    
    private(set) var ticketType: TicketType = .regular {
        didSet {
            updateTotalPrice?()
        }
    }
    
    var selectedSeats: [SeatLayout] = [] {
        didSet {
            updateSelectedSeatsInfo?()
            updateTotalPrice?()
        }
    }
    
    var updateTotalPrice: (() -> Void)?
    var updateSelectedSeatsInfo: (() -> Void)?
    var updateSeatStatus: ((Int, Int, SeatLayoutStatus) -> Void)?
    
    func getSeatStatus(at row: Int, column: Int) -> SeatLayoutStatus {
        guard isValidSeatPosition(row: row, column: column) else {
            return .occupied
        }
        return seats[row][column].status
    }
    
    func canSelectSeat(at row: Int, column: Int) -> Bool {
        guard isValidSeatPosition(row: row, column: column) else { return false }
        return seats[row][column].status == .available
    }
    
    func toggleTicketType() {
        ticketType = ticketType == .regular ? .package : .regular
        updateTotalPrice?()
    }
    
    func getTotalPrice() -> String {
        let currentPrice = ticketType.price
        let total = selectedSeats.count * currentPrice
        return "總金額：$\(total)"
    }
    
    func toggleSeat(at row: Int, column: Int) {
        guard isValidSeatPosition(row: row, column: column) else { return }
        
        var seat = seats[row][column]
        
        switch seat.status {
        case .available:
            seat.status = .selected
            selectedSeats.append(seat)
        case .selected:
            seat.status = .available
            selectedSeats.removeAll { $0.row == row && $0.column == column }
        case .occupied:
            return
        }
        
        seats[row][column] = seat
        updateSeatStatus?(row, column, seat.status)
    }
    
    func getSelectedSeatsText() -> String {
        if selectedSeats.isEmpty {
            return "已選座位：尚未選擇"
        }
        let sortedSeats = selectedSeats.sorted { ($0.row, $0.column) < ($1.row, $1.column) }
        return "已選座位：" + sortedSeats.map { $0.displayName }.joined(separator: "、")
    }
    
    func getTicketTypeText() -> String {
        switch ticketType {
        case .regular: return "一般票"
        case .package: return "套餐票"
        }
    }
    
    var numberOfRows: Int { configuration.numberOfRows }
    var seatsPerRow: Int { configuration.seatsPerRow }
    
    var selectedSeatsCount: Int {
        return selectedSeats.count
    }
    
    init(configuration: SeatLayoutConfiguration = .standard) {
        self.configuration = configuration
    }
    
    func initialize() {
        createInitialSeats()
    }
    
    private func createInitialSeats() {
        seats = (0..<numberOfRows).map { row in
            (0..<seatsPerRow).map { column in
                let isOccupied = Double.random(in: 0...1) < 0.6
                return SeatLayout(
                    row: row,
                    column: column,
                    status: isOccupied ? .occupied : .available
                )
            }
        }
    }
    
    private func isValidSeatPosition(row: Int, column: Int) -> Bool {
        row < seats.count && column < seats[row].count
    }
}
