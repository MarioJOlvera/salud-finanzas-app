//
//  FinanceRepository.swift
//  SaludFinanzasApp
//
//  Created by Mario Alberto Juarez Olvera on 17/02/26.
//

import Foundation
import GRDB

final class FinanceRepository {
    private let dbQueue: DatabaseQueue
    
    init(dbQueue: DatabaseQueue) {
        self.dbQueue = dbQueue
    }
    
    // Helper: ISO String simple
    
    private func nowISO() -> String {
        ISO8601DateFormatter().string(from: Date())
    }
    
    // Seed: crea cuenta / categorías si no existen
    
    func seedIfNeeded() throws {
        try dbQueue.write {
            db in let accountCount = try FinanceAccount.fetchCount(db)
            if accountCount == 0 {
                let cash = FinanceAccount(
                    id: UUID().uuidString,
                    name: "Efectivo",
                    type: "cash",
                    createdAt: nowISO()
                )
                try cash.insert(db)
            }
            
            let categoryCount = try FinanceCategory.fetchCount(db)
            if categoryCount == 0 {
                let food = FinanceCategory(
                    id: UUID().uuidString,
                    name: "Comida",
                    kind: "expense",
                    createdAt: nowISO()
                )
                let salary = FinanceCategory(
                    id: UUID().uuidString,
                    name: "Ingreso",
                    kind: "income",
                    createdAt: nowISO()
                )
                
                try food.insert(db)
                try salary.insert(db)
            }
        }
    }
    
    func fetchTransactions() throws -> [FinanceTransaction] {
        try dbQueue.read {
            db in try FinanceTransaction
                .order(sql: "occurred_at DESC")
                .fetchAll(db)
        }
    }
    
    func fetchAccounts() throws -> [FinanceAccount] {
        try dbQueue.read {
            db in try FinanceAccount.fetchAll(db)
        }
    }
    
    func fetchCategories(kind: String) throws -> [FinanceCategory] {
        try dbQueue.read {
            db in try FinanceCategory
                .filter(sql: "kind  = ?", arguments: [kind])
                .fetchAll(db)
        }
    }
    
    func addTransaction(
        amount: Double,
        direction: String,
        accountId: String,
        categoryId: String?,
        note: String?
    ) throws {
        let tx = FinanceTransaction(
            id: UUID().uuidString,
            occurredAt: nowISO(),
            amount: amount,
            currency: "MXN",
            direction: direction,
            accountId: accountId,
            categoryId: categoryId,
            note: note,
            source: "manual",
            externalId: nil,
            metadata: nil,
            createdAt: nowISO()
        )
        
        try dbQueue.write { db in try tx.insert(db)}
    }
    
    func addAccount(name: String, type: String) throws {
        let iso = ISO8601DateFormatter().string(from: Date())
        let a = FinanceAccount(id: UUID().uuidString, name: name, type: type, createdAt: iso)
        try dbQueue.write { db in try a.insert(db) }
    }
    
    func deleteAccount(id: String) throws {
        try dbQueue.write { db in
            _ = try FinanceAccount.deleteOne(db, key: id)
        }
    }
    
    func addCategory(name: String, kind: String) throws {
        let iso = ISO8601DateFormatter().string(from: Date())
        let c = FinanceCategory(id: UUID().uuidString, name: name, kind: kind, createdAt: iso)
        try dbQueue.write { db in try c.insert(db) }
    }
    
    func deleteCategory(id: String) throws {
        try dbQueue.write { db in
            _ = try FinanceCategory.deleteOne(db, key: id)
        }
    }
    
    func monthlyTotals(forMonthContaining date: Date) throws -> (income: Double, expense: Double) {
        let cal = Calendar.current
        let start = cal.date(from: cal.dateComponents([.year, .month], from: date))!
        let end = cal.date(byAdding: .month, value: 1, to: start)!
        
        let iso = ISO8601DateFormatter()
        let startS = iso.string(from: start)
        let endS = iso.string(from: end)
        
        return try dbQueue.read {
            db in let income: Double = try Double.fetchOne(db, sql: """
                SELECT COALESCE(SUM(amount), 0)
                FROM finance_transaction
                WHERE direction = 'income' AND occurred_at >= ? AND occurred_at < ?
                """, arguments: [startS, endS]) ?? 0
            
            let expense: Double = try Double.fetchOne(db, sql: """
                SELECT COALESCE(SUM(amount), 0) 
                FROM finance_transaction 
                WHERE direction = 'expense' AND occurred_at >= ? AND occurred_at < ?
                """, arguments: [startS, endS]) ?? 0
            
            return (income, expense)
        }
    }
}
