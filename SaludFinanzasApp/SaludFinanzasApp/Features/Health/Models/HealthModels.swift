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


