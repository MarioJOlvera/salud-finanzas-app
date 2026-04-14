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
    
    func deleteProfessional(id: String) throws {
        try dbQueue.write {
            db in _ = try Professional.deleteOne(db, key: id)
        }
    }
    
    func fetchAppointments() throws -> [Appointment] {
        try dbQueue.read {
            db in try Appointment.order(sql: "scheduled_at ASC").fetchAll(db)
        }
    }
    
    func addAppointment(
        professionalId: String,
        scheduledAt: String,
        location: String?,
        note: String?,
        status: String = "scheduled",
        reminderEnabled: Bool = true
    ) throws {
        let now = Date().toISO8601UTCString()
        
        let appointment = Appointment(
            id: UUID().uuidString,
            professionalId: professionalId,
            scheduledAt: scheduledAt,
            location: location?.isEmpty == true ? nil : location,
            note: note?.isEmpty == true ? nil : note,
            status: status,
            reminderEnabled: reminderEnabled,
            metadata: nil,
            createdAt: now
        )
        
        try dbQueue.write {
            db in try appointment.insert(db)
        }
    }
    
    func deleteAppointment(id: String) throws {
        try dbQueue.write {
            db in _ = try Appointment.deleteOne(db, key: id)
        }
    }
    
    func fetchHealthSummary() throws -> HealthSummary {
        try dbQueue.read {
            db in
            let biomarkerCount = try Biomarker.fetchCount(db)
            let labResultCount = try LabResult.fetchCount(db)
            let appointmentCount = try Appointment.fetchCount(db)
            
            
            return HealthSummary(
                biomarkerCount: biomarkerCount,
                labResultCount: labResultCount,
                appointmentCount: appointmentCount
            )
        }
    }
    
    func fetchRecentLabResultSummaries(limit: Int = 5) throws -> [RecentLabResultSummary] {
        try dbQueue.read {
            db in
            let rows = try Row.fetchAll(db, sql: """
                SELECT 
                    lr.id, 
                    b.name AS biomarker_name, 
                    lr.value,
                    lr.unit, 
                    lr.tested_at
                FROM lab_result lr 
                INNER JOIN biomarker b ON lr.biomarker_id = b.id 
                ORDER BY lr.tested_at DESC 
                LIMIT ?
                """, arguments: [limit])
            
            return rows.map {
                row in
                RecentLabResultSummary(
                    id: row["id"],
                    biomarkerName: row["biomarker_name"],
                    value: row["value"],
                    unit: row["unit"],
                    testedAt: row["tested_at"]
                )
            }
        }
    }
    
    func fetchUpcomingAppointmentSummaries(limit: Int = 5) throws -> [UpcomingAppointmentSummary] {
        let now = Date().toISO8601UTCString()
        
        return try dbQueue.read {
            db in
            let rows = try Row.fetchAll(db, sql: """
                SELECT 
                    a.id, 
                    p.name AS professional_name, 
                    p.specialty, 
                    a.scheduled_at, 
                    a.location, 
                    a.status
                FROM appointment a 
                INNER JOIN professional p ON a.professional_id = p.id 
                WHERE a.scheduled_at >= ? 
                ORDER BY a.scheduled_at ASC
                LIMIT ?
                """, arguments: [now, limit])
            
            return rows.map {
                row in UpcomingAppointmentSummary(
                    id: row["id"],
                    professionalName: row["professional_name"],
                    specialty: row["specialty"],
                    scheduledAt: row["scheduled_at"],
                    location: row["location"],
                    status: row["status"]
                )
            }
        }
    }
    
    
}


