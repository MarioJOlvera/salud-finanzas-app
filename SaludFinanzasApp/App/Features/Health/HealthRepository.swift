//
//  HealthRepository.swift
//  SaludFinanzasApp
//
//  Created by Mario Alberto Juarez Olvera on 09/04/26.
//

import Foundation
import GRDB

final class HealthRepository {
    private let dbQueue: DatabaseQueue
    
    init(dbQueue: DatabaseQueue) {
        self.dbQueue = dbQueue
    }
    
    func seedBiomarkersIfNeeded() throws {
        try dbQueue.write { db in
            let count = try Biomarker.fetchCount(db)
            if count == 0 {
                let now = Date().toISO8601UTCString()
                
                let seeds = [
                    Biomarker(id: UUID().uuidString, code: "GLU", name: "Glucosa", createdAt: now),
                    Biomarker(id: UUID().uuidString, code: "LDL", name: "Colesterol LDL", createdAt: now),
                    Biomarker(id: UUID().uuidString, code: "HDL", name: "Colesterol HDL", createdAt: now),
                    Biomarker(id: UUID().uuidString, code: "TRI", name: "Triglicéridos", createdAt: now),
                    Biomarker(id: UUID().uuidString, code: "HBA1C", name: "Hemoglobina glucosilada", createdAt: now)
                ]
                
                for biomarker in seeds {
                    try biomarker.insert(db)
                }
            }
        }
    }
    
    func fetchBiomarkers() throws -> [Biomarker] {
        try dbQueue.read {
            db in try Biomarker
                .order(Column("name").asc)
                .fetchAll(db)
        }
    }
    
    func fetchLabResults() throws -> [LabResult] {
        try dbQueue.read {
            db in try LabResult
                .order(sql: "tested_at DESC")
                .fetchAll(db)
        }
    }
    
    func fetchLabResults(for biomarkerId: String) throws -> [LabResult] {
        try dbQueue.read {
            db in try LabResult
                .filter(Column("biomarker_id") == biomarkerId)
                .order(sql: "tested_at DESC")
                .fetchAll(db)
        }
    }
    
    func addLabResult(
        biomarkerId: String,
        value: Double,
        unit: String,
        referenceMin: Double?,
        referenceMax: Double?
    ) throws {
        let now = Date().toISO8601UTCString()
        
        let result = LabResult(
            id: UUID().uuidString,
            biomarkerId: biomarkerId,
            testedAt: now,
            value: value,
            unit: unit,
            referenceMin: referenceMin,
            referenceMax: referenceMax,
            metadata: nil,
            createdAt: now
        )
        
        try dbQueue.write {
            db in try result.insert(db)
        }
    }
    
    func fetchProfessionals() throws -> [Professional] {
        try dbQueue.read {
            db in try Professional
                .order(Column("name").asc)
                .fetchAll(db)
        }
    }
    
    func addProfessional(
        name: String,
        specialty: String,
        phone: String?,
        email: String?
    ) throws {
        let now = Date().toISO8601UTCString()
        
        let professional = Professional(
            id: UUID().uuidString,
            name: name,
            specialty: specialty,
            phone: phone?.isEmpty == true ? nil : phone,
            email: email?.isEmpty == true ? nil : email,
            createdAt: now
        )
        
        try dbQueue.write {
            db in try professional.insert(db)
        }
    }
    
    
}


