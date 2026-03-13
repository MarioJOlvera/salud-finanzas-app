//
//  Date+Finance.swift
//  SaludFinanzasApp
//
//  Created by Mario Alberto Juarez Olvera on 12/03/26.
//

import Foundation


extension Date {
    
    func formattedMonthYear() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_MX")
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: self).capitalized
    }
}

