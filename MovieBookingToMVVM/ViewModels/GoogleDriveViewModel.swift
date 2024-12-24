//
//  GoogleDriveViewModel.swift
//  MovieBookingToMVVM
//
//  Created by Lydia Lu on 2024/12/19.
//

import Foundation

enum UploadStatus {
    case idle
    case uploading
    case success
    case failed(Error)
}

class GoogleDriveViewModel {
    var uploadStatus: UploadStatus = .idle
    var uploadStatusHandler: ((UploadStatus) -> Void)?
    
    func uploadBookingData(
        bookingData: BookingData,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        // 模擬上傳邏輯
        uploadStatus = .uploading
        uploadStatusHandler?(uploadStatus)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.uploadStatus = .success
            self?.uploadStatusHandler?(self?.uploadStatus ?? .success)
            completion(.success(()))
        }
    }
}




