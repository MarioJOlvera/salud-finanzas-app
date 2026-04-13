//
//  AppEnvironment.swift
//  SaludFinanzasApp
//
//  Created by Mario Alberto Juarez Olvera on 17/02/26.
//

import Foundation
import Observation

@MainActor
@Observable 

final class AppEnvironment: Observable {
    let db: AppDatabase
    
    init() {
        do {
            self.db = try AppDatabase()
            print("Base de Datos Lista")
        } catch {
            fatalError("No se puede iniciar la Base de Datos: \(error)")
        }
    }
}
