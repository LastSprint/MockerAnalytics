//
//  Models.swift
//  MockerAnalyticsCMD
//
//  Created by Александр Кравченков on 04.12.2019.
//  Copyright © 2019 SurfStudio. All rights reserved.
//

import Foundation

enum LogEvent: String, Codable {
    case getMock = "get_mock"
    case updateModels = "update_models"
}

extension String {
    var date: Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return dateFormatter.date(from: self)
    }
}

struct LogPayload: Codable, Hashable {
    let requestedUrl: String?
    let specificHeaderPath: String?
    let success: Bool
    let err: String?
    let startTime: String?
    let endTime: String?
}

struct Log: Codable, Hashable {
    let payload: LogPayload
    let event: LogEvent
    let key: String
    let time: String
}
