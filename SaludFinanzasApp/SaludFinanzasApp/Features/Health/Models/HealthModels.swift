//
//  HealthModels.swift
//  SaludFinanzasApp
//
//  Created by Mario Alberto Juarez Olvera on 09/04/26.
//

import Foundation
import GRDB

struct Biomarker: Codable, FetchableRecord, PersistableRecord, Identifiable {
    static let databaseTableName = "biomarker"
    
    var id: String
    var code: String
    var name: String
    var createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id, code, name
        case createdAt = "created_at"
    }
}

struct LabResult: Codable, FetchableRecord, PersistableRecord, Identifiable {
    static let databaseTableName = "lab_result"

    var id: String
    var biomarkerId: String
    var testedAt: String
    var value: Double
    var unit: String
    var referenceMin: Double?
    var referenceMax: Double?
    var metadata: String?
    var createdAt: String

    enum CodingKeys: String, CodingKey {
        case id
        case biomarkerId = "biomarker_id"
        case testedAt = "tested_at"
        case value, unit
        case referenceMin = "reference_min"
        case referenceMax = "reference_max"
        case metadata
        case createdAt = "created_at"
    }
}

struct Professional: Codable, FetchableRecord, PersistableRecord, Identifiable {
    static let databaseTableName = "professional"
    
    var id: String
    var name: String
    var specialty: String
    var phone: String?
    var email: String?
    var createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id, name, specialty, phone, email
        case createdAt = "created_at"
    }
}

struct Appointment: Codable, FetchableRecord, PersistableRecord, Identifiable {
    static let databaseTableName = "appointment"
    
    var id: String
    var professionalId: String
    var scheduledAt: String
    var location: String?
    var note: String?
    var status: String
    var reminderEnabled: Bool
    var metadata: String?
    var createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case professionalId = "professional_id"
        case scheduledAt = "scheduled_at"
        case location, note, status
        case reminderEnabled = "reminder_enabled"
        case metadata
        case createdAt = "created_at"
    }
}

