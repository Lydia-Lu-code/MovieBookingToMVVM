//
//  ShowtimeSelectionViewModel.swift
//  MovieBookingToMVVM
//
//  Created by Lydia Lu on 2024/12/18.
//

import Foundation

class ShowtimeSelectionViewModel {
    let movieTitle: String
    
    // MARK: - Properties
    private let calendar = Calendar.current
    private(set) var selectedDate: Date?
    private(set) var selectedShowtime: ShowtimeModel?
    
    var showtimes: [ShowtimeModel] = []
    var showAlert: (() -> Void)?
    
    init(movieTitle: String) {
        self.movieTitle = movieTitle
    }
    
    // MARK: - Outputs
    var updateShowtimes: (([ShowtimeModel]) -> Void)?
    var updateSelectSeatButtonState: ((Bool) -> Void)?
    
    // MARK: - Calendar Configuration
    var availableDateRange: DateInterval {
        let today = calendar.startOfDay(for: Date())
        let sevenDaysLater = calendar.date(byAdding: .day, value: 7, to: today)!
        return DateInterval(start: today, end: sevenDaysLater)
    }
    
    // 修改選座按鈕的動作檢查
    func canProceedToSeatSelection() -> Bool {
        if selectedShowtime == nil {
            showAlert?()
            return false
        }
        return true
    }
    
    // MARK: - Public Methods
    func selectDate(_ date: Date) {
        selectedDate = date
        selectedShowtime = nil

        // 在實際應用中，這裡可能需要從API獲取該日期的場次
        showtimes = createShowtimes(for: date)
        updateShowtimes?(showtimes)
    }
    
    func selectShowtime(_ showtime: ShowtimeModel) {
        selectedShowtime = showtime
        updateSelectSeatButtonState?(true)
    }
    
    // MARK: - Private Methods
    private func createShowtimes(for date: Date) -> [ShowtimeModel] {
        return [
            ShowtimeModel(period: "早上", time: "10:30", isAvailable: true),
            ShowtimeModel(period: "下午", time: "13:30", isAvailable: true),
            ShowtimeModel(period: "下午", time: "14:50", isAvailable: true),
            ShowtimeModel(period: "下午", time: "16:20", isAvailable: true),
            ShowtimeModel(period: "晚上", time: "19:00", isAvailable: true),
            ShowtimeModel(period: "晚上", time: "21:30", isAvailable: true)
        ]
    }
}
