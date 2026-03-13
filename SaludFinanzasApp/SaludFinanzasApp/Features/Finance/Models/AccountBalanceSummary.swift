//
//  AccountBalanceSummary.swift
//  SaludFinanzasApp
//
//  Created by Mario Alberto Juarez Olvera on 12/03/26.
//
// proyección o view model de datos.

import Foundation

struct AccountBalanceSummary: Identifiable {
    let id: String
    let name: String
    let type: String
    let balance: Double
}
