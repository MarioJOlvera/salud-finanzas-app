//
//  DateFormatters.swift
//  SaludFinanzasApp
//
//  Created by Mario Alberto Juarez Olvera on 19/02/26.
//

import Foundation


enum DateFormatters {
    static let iso: ISO8601DateFormatter = {
        
        let f = ISO8601DateFormatter()
        
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        return f
    }()
    
    static let isoNoFraction: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        
        f.formatOptions = [.withInternetDateTime]
        
        return f
    }()
    
    static let ddMMyyyy: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "es_MX")
        f.timeZone = .current
        f.dateFormat = "dd/MM/yyyy"
        
        return f
    }()
}

extension String {
    // Convierte ISO8601 String a Date (intenta con y sin milisegundos)
    
    func toDateFromISO() -> Date? {
        if let d = DateFormatters.iso.date(from: self) { return d }
        return DateFormatters.isoNoFraction.date(from: self)
    }
    
    func toDDMMYYYY() -> String {
        guard let d = self.toDateFromISO() else { return self } // fallback
        return DateFormatters.ddMMyyyy.string(from: d)
    }
}
