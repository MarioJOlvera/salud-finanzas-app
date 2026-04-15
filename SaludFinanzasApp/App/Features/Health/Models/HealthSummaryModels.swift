//
//  HealthModels.swift
//  SaludFinanzasApp
//
//  Created by Mario Alberto Juarez Olvera on 13/04/26.
//

import Foundation

struct HealthSummary {
    let biomarkerCount: Int
    let labResultCount: Int
    let appointmentCount: Int
}

struct RecentLabResultSummary: Identifiable {
    let id: String
    let biomarkerName: String
    let value: Double
    let unit: String
    let testedAt: String
    let referenceMin: Double?
    let referenceMax: Double?
    
    var statusLabel: String {
        guard let min = referenceMin, let max = referenceMax else {
            return "Sin rango"
        }
        
        if value < min { return "Bajo" }
        if value > max { return "Alto" }
        return "En rango"
    }
    
    var statusColorName: String {
        guard let min = referenceMin, let max = referenceMax else {
            return "secondary"
        }
        
        if value < min || value > max { return "red" }
        return "green"
    }
}


struct UpcomingAppointmentSummary: Identifiable {
    let id: String
    let professionalName: String
    let specialty: String
    let scheduledAt: String
    let location: String?
    let status: String
}
