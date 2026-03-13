//
//  Date+Finance.swift
//  SaludFinanzasApp
//
//  Created by Mario Alberto Juarez Olvera on 12/03/26.
//

import Foundation

enum FinanceDateHelper {
    static let isoUTC: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()

    static let monthYearFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_MX")
        formatter.timeZone = .current
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()

    static let shortDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_MX")
        formatter.timeZone = .current
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter
    }()
}

extension Date {
    func toISO8601UTCString() -> String {
        FinanceDateHelper.isoUTC.string(from: self)
    }

    func formattedMonthYear() -> String {
        FinanceDateHelper.monthYearFormatter.string(from: self).capitalized
    }

    func startOfMonthUTC() -> Date {
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents(in: TimeZone(secondsFromGMT: 0)!, from: self)
        return calendar.date(from: DateComponents(
            timeZone: TimeZone(secondsFromGMT: 0),
            year: components.year,
            month: components.month,
            day: 1,
            hour: 0,
            minute: 0,
            second: 0
        ))!
    }

    func startOfNextMonthUTC() -> Date {
        let calendar = Calendar(identifier: .gregorian)
        return calendar.date(byAdding: .month, value: 1, to: startOfMonthUTC())!
    }
}

extension String {
    func formattedShortDate() -> String {
        guard let date = FinanceDateHelper.isoUTC.date(from: self) else {
            return self
        }
        return FinanceDateHelper.shortDateFormatter.string(from: date)
    }
}
