//
//  SeatLayoutViewModel.swift
//  MovieBookingToMVVM
//
//  Created by Lydia Lu on 2024/12/18.
//

import Foundation

class SeatLayoutViewModel {
    // MARK: - Properties
    let numberOfRows = 8  // 改為 internal (默認)
    let seatsPerRow = 10  // 改為 internal (默認)
    private let ticketPrice = 280
    private var seats: [[SeatLayout]] = []
    
//    // MARK: - Properties
//    private let numberOfRows = 8
//    private let seatsPerRow = 10
//    private let ticketPrice = 280
//    private var seats: [[SeatLayout]] = []
    
    // MARK: - Outputs
    var selectedSeats: [SeatLayout] = [] {
        didSet {
            updateSelectedSeatsInfo?()
        }
    }
    
    // MARK: - Callbacks
    var updateSelectedSeatsInfo: (() -> Void)?
    var updateSeatStatus: ((Int, Int, SeatLayoutStatus) -> Void)?
    
    // MARK: - Public Methods
    func initialize() {
        seats = (0..<numberOfRows).map { row in
            (0..<seatsPerRow).map { column in
                let isOccupied = Double.random(in: 0...1) < 0.6
                return SeatLayout(row: row,
                          column: column,
                          status: isOccupied ? .occupied : .available)
            }
        }
    }
    
    func getSeat(at row: Int, column: Int) -> SeatLayout? {
        guard row < seats.count, column < seats[row].count else { return nil }
        return seats[row][column]
    }
    
    func toggleSeat(at row: Int, column: Int) {
        guard row < seats.count, column < seats[row].count else { return }
        
        var seat = seats[row][column]
        if seat.status == .occupied { return }
        
        if seat.status == .selected {
            seat.status = .available
            selectedSeats.removeAll { $0.row == row && $0.column == column }
        } else {
            seat.status = .selected
            selectedSeats.append(seat)
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
    
    func getTotalPriceText() -> String {
        return "總金額：$\(selectedSeats.count * ticketPrice)"
    }
}
