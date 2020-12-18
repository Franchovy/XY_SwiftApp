//
//  DateStringFormatter.swift
//  XY_APP
//
//  Created by Maxime Franchot on 16/12/2020.
//

import Foundation

class DateStringFormatter {
    
    // MARK - PUBLIC METHODS
    
    static func stringFromDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSSSS"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        
        return dateFormatter.string(from: date)
    }
    
    static func dateFormatFromString(_ dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSSSS"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")

        // Create date in original UTC
        var date = dateFormatter.date(from: dateString)

        // Convert to local timezone
        date?.addTimeInterval(TimeInterval(TimeZone.current.secondsFromGMT()))
        
        return date!
    }
}
