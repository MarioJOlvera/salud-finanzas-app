//
//  FinanceHomeView.swift
//  SaludFinanzasApp
//
//  Created by Mario Alberto Juarez Olvera on 17/02/26.
//

import SwiftUI

struct FinanceHomeView: View {
    @Environment(AppEnvironment.self) var env
    
    @State private var transactions: [FinanceTransaction] = []
    @State private var showAdd = false
    @State private var errorMessage: String?
    
    private var repo: FinanceRepository {
        FinanceRepository(dbQueue: env.db.dbQueue)
    }
    
    var body: some View {
        NavigationView {
            List {
                if let errorMessage {
                    Text("Error: \(errorMessage)").foregroundStyle(Color.red)
                }
                if transactions.isEmpty {
                    Text("Sin movimientos").foregroundStyle(Color.secondary)
                } else {
                    ForEach(transactions) { tx in
                        HStack {
                            VStack (alignment: .leading) {
                                let sign = (tx.direction == "expense") ? "-" : "+"
                                Text("\(sign)\(String(format: "%.2f", tx.amount)) \(tx.currency)")
                                    .font(.headline)
                            }
                            Spacer()
                            Text(String(format: "%.2f %@", tx.amount, tx.currency)).font(.headline)
                            Text(tx.occurredAt).font(.caption).foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Finanzas")
            .toolbar {
                Button {
                    showAdd = true
                } label: {
                    Image(systemName: "plus")
                }
            }
            .sheet(isPresented: $showAdd) {
                AddTransactionView(repo: repo) {
                    load()
                }
            }
            .onAppear {
                load()
            }
        }
    }
    
    private func load() {
        do {
            try repo.seedIfNeeded()
            transactions = try repo.fetchTransactions()
            errorMessage = nil
        } catch {
            errorMessage = "\(error)"
        }
    }
}

