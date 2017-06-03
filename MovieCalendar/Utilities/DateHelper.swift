//
//  DateHelper.swift
//  Talanx
//
//  Created by Angela Cristina Barnes on 23/05/2017.
//  Copyright © 2017 aaronprojects. All rights reserved.
//

import Foundation

extension Formatter {
    
    static let iso8601: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}

extension Date {
    
    func month() -> Int {
        return Calendar.current.component(Calendar.Component.month, from: self)
    }
    
    func monthString() -> String {
        return DateFormatter().monthSymbols[self.month()-1]
    }
    
    func day() -> Int {
        return Calendar.current.component(Calendar.Component.day, from: self)
    }
    
    func weekdayString() -> String {
        let weekday = Calendar.current.component(.weekday, from: self)
        return DateFormatter().shortWeekdaySymbols[weekday-1]
    }
    
    func year() -> Int {
        return Calendar.current.component(Calendar.Component.year, from: self)
    }
    
    func weeks(fromDate date: Date) -> Int {
        return Calendar.current.dateComponents([.weekOfMonth], from: date, to: self).weekOfMonth ?? 0
    }
    
    var iso8601: String {
        return Formatter.iso8601.string(from: self)
    }
}

extension String {
    
    var dateFromISO8601: Date? {
        return Formatter.iso8601.date(from: self)
    }
}
