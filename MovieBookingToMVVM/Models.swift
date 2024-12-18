//
//  Models.swift
//  MovieBookingToMVVM
//
//  Created by Lydia Lu on 2024/12/13.
//

import Foundation
import UIKit

// MARK: - API Response Models
struct MovieResponse: Codable {
   let results: [Movie]
}

struct Movie: Codable {
   let id: Int
   let title: String
   let overview: String
   let posterPath: String?
   let releaseDate: String
   let duration: Int?
   
   enum CodingKeys: String, CodingKey {
       case id
       case title
       case overview
       case posterPath = "poster_path"
       case releaseDate = "release_date"
       case duration = "runtime"
   }
}

struct ShowTime: Codable {
   let id: Int
   let movieId: Int
   let startTime: Date
   let theater: String
   let price: Decimal
   var availableSeats: [Seat]
}

struct Seat: Codable {
   let row: String
   let number: Int
   var isAvailable: Bool
}

struct Booking: Codable {
   let id: Int
   let showTimeId: Int
   let selectedSeats: [Seat]
   let totalPrice: Decimal
   let bookingTime: Date
}

// MARK: - Seat Layout Models
struct SeatLayoutConfiguration {
   let numberOfRows: Int
   let seatsPerRow: Int
   let ticketPrice: Int
   
   static let standard = SeatLayoutConfiguration(
       numberOfRows: 8,
       seatsPerRow: 10,
       ticketPrice: 280
   )
}

struct SeatDisplayInfo {
   let seatsText: String
   let totalPriceText: String
}

enum SeatLayoutStatus {
   case available
   case occupied
   case selected
   
   var backgroundColor: UIColor {
       switch self {
       case .available: return .systemGray5
       case .occupied: return .systemGray3
       case .selected: return .systemGreen
       }
   }
}

struct SeatLayout {
   let row: Int
   let column: Int
   var status: SeatLayoutStatus
   
   var displayName: String {
       let rowLabel = String(UnicodeScalar("A".unicodeScalars.first!.value + UInt32(row))!)
       return "\(rowLabel)\(column + 1)"
   }
}


struct ShowtimeModel {
    let period: String
    let time: String
    let isAvailable: Bool
}

struct ShowtimeDateModel {
    let date: Date
    let showtimes: [ShowtimeModel]
}
