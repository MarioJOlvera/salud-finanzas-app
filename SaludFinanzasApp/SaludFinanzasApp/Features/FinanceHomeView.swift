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
    @State private var monthlyIncome: Double = 0
    @State private var monthlyExpense: Double = 0
    
    private var repo: FinanceRepository {
        FinanceRepository(dbQueue: env.db.dbQueue)
    }
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Resumen del mes").font(.headline)
                        
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Ingresos")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text(monthlyIncome.currencyMXN())
                                    .foregroundStyle(Color.green)
                            }
                            Spacer()
                            
                            VStack(alignment: .leading) {
                                Text("Gastos")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text(monthlyExpense.currencyMXN())
                                    .foregroundStyle(Color.secondary)
                                
                                let balance = monthlyIncome - monthlyExpense
                                
                                Text(balance.currencyMXN())
                                    .fontWeight(.bold)
                                    .foregroundStyle(balance >= 0 ? .blue : .red)
                            }
                        }
                    }
                }
                .padding(.vertical, 8)
                
                if let errorMessage {
                    Text("Error: \(errorMessage)").foregroundStyle(Color.red)
                }
                if transactions.isEmpty {
                    Text("Sin movimientos").foregroundStyle(Color.secondary)
                } else {
                    ForEach(transactions) {
                        tx in HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(tx.direction == "expense" ? "Gasto" : "Ingreso").font(.headline)
                                Text(tx.note?.isEmpty == false ? tx.note! : "-").foregroundStyle(Color.secondary)
                                Text(tx.occurredAt.formattedShortDate()).foregroundStyle(Color.secondary)
                            }
                            
                            Spacer()
                            
                            let sign = (tx.direction == "expense") ? "-" : "+"
                            Text("\(sign)\(String(format: "%.2f", tx.amount)) \(tx.currency)").font(.headline)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Finanzas")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAdd = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    NavigationLink(destination: FinanceSettingsView()) {
                        Image(systemName: "gearshape")
                    }
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
            transactions = try repo.fetchTransactions()
            loadSummary()
            errorMessage = nil
        } catch { errorMessage = "\(error)" }
    }
    
    private func loadSummary() {
        do {
            let totals = try repo.monthlyTotals(forMonthContaining: Date())
            monthlyIncome = totals.income
            monthlyExpense = totals.expense
        } catch { errorMessage = "\(error)" }
    }
}

