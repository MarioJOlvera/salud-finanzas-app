//
//  Double+Currency.swift
//  SaludFinanzasApp
//
//  Created by Mario Alberto Juarez Olvera on 20/02/26.
//

import Foundation

extension Double {
    func currencyMXN() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "MXN"
        formatter.locale = Locale(identifier: "es_MXN")
        
        return formatter.string(from: NSNumber(value: self)) ?? "0"
    }
}
