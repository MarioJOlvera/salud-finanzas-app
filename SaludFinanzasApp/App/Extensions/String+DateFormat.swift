//
//  String+DateFormat.swift
//  SaludFinanzasApp
//
//  Created by Mario Alberto Juarez Olvera on 20/02/26.
//

import Foundation

extension String {
    func formattedShortDate() -> String {
        let iso = ISO8601DateFormatter()
        guard let date = iso.date(from: self) else { return self }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        formatter.locale = Locale(identifier: "es_MX")
        
        return formatter.string(from: date)
    }
}
