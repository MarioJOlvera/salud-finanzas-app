//
//  FinanceModels.swift
//  SaludFinanzasApp
//
//  Created by Mario Alberto Juarez Olvera on 17/02/26.
//

import Foundation
import GRDB

// MARK: - Account

struct FinanceAccount: Codable, FetchableRecord, PersistableRecord, Identifiable {
    static let databaseTableName = "finance_account"
    
    var id: String
    var name: String
    var type: String
    var createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id, name, type
        case createdAt = "created_at"
    }
}

// MARK: - Category

struct FinanceCategory: Codable, FetchableRecord, PersistableRecord, Identifiable {
    static let databaseTableName = "finance_category"
    
    var id: String
    var name: String
    var kind: String
    var createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id, name, kind
        case createdAt = "created_at"
    }
}

// MARK: - Transaction

struct FinanceTransaction: Codable, FetchableRecord, PersistableRecord, Identifiable {
    static let databaseTableName = "finance_transaction"
    
    var id: String
    var occurredAt: String
    var amount: Double
    var currency: String
    var direction: String // expense | income
    var accountId: String
    var categoryId: String?
    var note: String?
    var source: String?
    var externalId: String?
    var metadata: String?
    var createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case occurredAt = "occurred_at"
        case amount, currency, direction
        case accountId = "account_id"
        case categoryId = "category_id"
        case note, source
        case externalId = "external_id"
        case metadata
        case createdAt = "created_at"
    }
}


