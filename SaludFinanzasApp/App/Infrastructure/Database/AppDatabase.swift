import Foundation
import GRDB

final class AppDatabase {
    
    let dbQueue: DatabaseQueue
    
    init() throws {
        let dbURL = try Self.makeDatabaseURL()
        dbQueue = try DatabaseQueue(path: dbURL.path)
        try migrator.migrate(dbQueue)
    }
    
    private static func makeDatabaseURL() throws -> URL {
        let fm = FileManager.default
        let appSupport = try fm.url(for: .applicationSupportDirectory,
                                    in: .userDomainMask,
                                    appropriateFor: nil,
                                    create: true)
        
        let folder = appSupport.appendingPathComponent("SaludFinanzasApp", isDirectory: true)
        if !fm.fileExists(atPath: folder.path) {
            try fm.createDirectory(at: folder, withIntermediateDirectories: true)
        }
        
        return folder.appendingPathComponent("app.sqlite")
    }
    
    private var migrator: DatabaseMigrator{
        var migrator = DatabaseMigrator()
        
        migrator.eraseDatabaseOnSchemaChange = true
        
        migrator.registerMigration("v1") {
            db in try db.execute(sql: "PRAGMA foreign_keys = ON;")
            
            // SALUD
            try db.execute(
                sql: """
                    CREATE TABLE biomarker (
                        id TEXT PRIMARY KEY NOT NULL, 
                        code TEXT NOT NULL UNIQUE, 
                        name TEXT NOT NULL, 
                        created_at TEXT NOT NULL
                    );
                    """
            )
            
            try db.execute(
                sql: """
                    CREATE TABLE lab_result (
                        id TEXT PRIMARY KEY NOT NULL, 
                        biomarker_id TEXT NOT NULL, 
                        tested_at TEXT NOT NULL, 
                        value REAL NOT NULL, 
                        unit TEXT NOT NULL, 
                        reference_min REAL, 
                        reference_max REAL, 
                        metadata TEXT, 
                        created_at TEXT NOT NULL, 
                        FOREIGN KEY (biomarker_id) REFERENCES biomarker(id) ON DELETE RESTRICT 
                    );
                    """
            )
            
            try db.execute(
                sql: """
                    CREATE TABLE medication (
                        id TEXT PRIMARY KEY NOT NULL, 
                        name TEXT NOT NULL, 
                        created_at TEXT NOT NULL
                    );
                    """
            )
            
            try db.execute(
                sql: """
                    CREATE TABLE dose_log(
                        id TEXT PRIMARY KEY NOT NULL, 
                        medication_id TEXT NOT NULL, 
                        taken_at TEXT NOT NULL, 
                        dose_amount REAL NOT NULL, 
                        dose_unit REAL NOT NULL, 
                        note TEXT, 
                        created_at TEXT NOT NULL, 
                        FOREIGN KEY (medication_id) REFERENCES medication(id) ON DELETE CASCADE
                    );
                    """
            )
            
            try db.execute(
                sql: """
                    CREATE TABLE habit (
                        id TEXT PRIMARY KEY NOT NULL, 
                        name TEXT NOT NULL, 
                        created_at TEXT NOT NULL, 
                        is_active INTEGER NOT NULL DEFAULT 1
                    );
                    """
            )
            
            try db.execute(
                sql: """
                    CREATE TABLE habit_log (
                        id TEXT PRIMARY KEY NOT NULL, 
                        habit_id TEXT NOT NULL, 
                        occurred_at TEXT NOT NULL, 
                        quantity REAL, 
                        unit TEXT, 
                        note TEXT, 
                        created_at TEXT NOT NULL, 
                        FOREIGN KEY (habit_id) REFERENCES habit(id) ON DELETE CASCADE
                    );
                    """
            )
            
            try db.execute(
                sql: """
                    CREATE TABLE professional (
                        id TEXT PRIMARY KEY NOT NULL, 
                        name TEXT NOT NULL, 
                        specialty TEXT NOT NULL, 
                        phone TEXT, 
                        email TEXT, 
                        created_at TEXT NOT NULL
                    );
                    """
            )
            
            try db.execute(
                sql: """
                    CREATE TABLE appointment (
                        id TEXT PRIMARY KEY NOT NULL, 
                        professional_id TEXT NOT NULL, 
                        scheduled_at TEXT NOT NULL, 
                        location TEXT, 
                        note TEXT, 
                        status TEXT NOT NULL, 
                        reminder_enabled INTEGER NOT NULL DEFAULT 1, 
                        metadata TEXT, 
                        created_at TEXT NOT NULL, 
                        FOREIGN KEY (professional_id) REFERENCES professional(id) ON DELETE CASCADE, 
                        CHECK (status IN ('scheduled', 'completed', 'cancelled'))
                    );
                    """
            )
            
            try db.execute(
                sql: """
                    CREATE TABLE document_attachment (
                        id TEXT PRIMARY KEY NOT NULL, 
                        file_name TEXT, 
                        file_type TEXT, 
                        file_size INTEGER, 
                        storage_path TEXT, 
                        sha256 TEXT, 
                        metadata TEXT, 
                        created_at TEXT NOT NULL
                    );
                    """
            )
            
            try db.execute(
                sql: """
                    CREATE TABLE attachment_link(
                        id TEXT PRIMARY KEY NOT NULL, 
                        attachment_id TEXT NOT NULL, 
                        target_type TEXT NOT NULL, 
                        target_id TEXT NOT NULL,
                        note TEXT, 
                        created_at TEXT NOT NULL,
                        FOREIGN KEY (attachment_id) REFERENCES document_attachment(id) ON DELETE CASCADE
                    );
                    """
            )
            
            try db.execute(
                sql: """
                    CREATE INDEX idx_lab_result_biomarker_tested_at
                        ON lab_result (biomarker_id, tested_at);
                    """
            )
            
            // FINANZAS
            
            try db.execute(
                sql: """
                    CREATE TABLE finance_account (
                        id TEXT PRIMARY KEY NOT NULL, 
                        name TEXT NOT NULL, 
                        type TEXT NOT NULL, 
                        created_at TEXT NOT NULL
                    );
                    """
            )
            
            try db.execute(
                sql: """
                    CREATE TABLE finance_category (
                        id TEXT PRIMARY KEY NOT NULL, 
                        name TEXT NOT NULL, 
                        kind TEXT NOT NULL, 
                        created_at TEXT NOT NULL, 
                        UNIQUE(name, kind), 
                        CHECK (kind IN ('expense', 'income'))
                    );
                    """
            )
            
            try db.execute(
                sql: """
                    CREATE TABLE finance_transaction (
                        id TEXT PRIMARY KEY NOT NULL, 
                        occurred_at TEXT NOT NULL, 
                        amount REAL NOT NULL, 
                        currency TEXT NOT NULL DEFAULT 'MXN', 
                        direction TEXT NOT NULL, 
                        account_id TEXT NOT NULL, 
                        category_id TEXT, 
                        note TEXT, 
                        source TEXT NOT NULL DEFAULT 'manual', 
                        external_id TEXT, 
                        metadata TEXT,
                        created_at TEXT NOT NULL, 
                        FOREIGN KEY (account_id) REFERENCES finance_account(id) ON DELETE RESTRICT, 
                        FOREIGN KEY (category_id) REFERENCES finance_category(id) ON DELETE SET NULL, 
                        CHECK (direction IN ('expense', 'income')), 
                        CHECK (source IN ('manual', 'import'))
                    );
                    """
            )
            
            try db.execute(
                sql: """
                    CREATE INDEX idx_fin_tx_occurred_at
                        ON finance_transaction(occurred_at);
                    """
            )
        }
        
        migrator.registerMigration("v2") {
            db in try db.execute(sql:"""
                UPDATE biomarker
                SET name = CASE 
                    WHEN name = 'Colesterok HDL' THEN 'Colesterol HDL'
                    WHEN name = 'Triglicéridocs' THEN 'Triglicéridos' 
                    ELSE name
                END
                """)
        }
        
        migrator.registerMigration("v3") {
            db in try db.execute(sql: """
                UPDATE biomarker
                SET name = CASE 
                    WHEN name = 'Colesterok HDL' THEN 'Colesterol HDL' 
                    WHEN name = 'Triglicéridocs' THEN 'Triglicéridos' 
                    ELSE name 
                END
                """)
        }
        
        return migrator
    }
}
