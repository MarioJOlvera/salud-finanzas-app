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
    @State private var monthlyExpenses: Double = 0
    @State private var accountBalances: [AccountBalanceSummary] = []
    @State private var selectedMonth: Date = Date()
    
    private var repo: FinanceRepository {
        FinanceRepository(dbQueue: env.db.dbQueue)
    }
    
    private var monthlyBalance: Double {
        monthlyIncome - monthlyExpenses
    }
    
    var body: some View {
        NavigationView{
            List {
                Section {
                    HStack {
                        Button {
                            if let previousMonth = Calendar.current.date(byAdding: .month, value: -1, to: selectedMonth) {
                                selectedMonth = previousMonth
                            }
                        } label: {
                            Image(systemName: "chevron.left")
                        }
                        
                        Spacer()
                        
                        Text(selectedMonth.formattedMonthYear())
                            .font(.headline)
                        
                        Spacer()
                        
                        Button {
                            if let nextMonth = Calendar.current.date(byAdding: .month, value: 1, to: selectedMonth) {
                                selectedMonth = nextMonth
                            }
                        } label: {
                            Image(systemName: "chevron.right")
                        }
                    }
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Resumen - \(selectedMonth.formattedMonthYear())")
                            .font(.headline)
                        
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Ingresos")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                
                                Text(monthlyIncome.currencyMXN())
                                    .font(.headline)
                                    .foregroundStyle(.green)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Gastos")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                
                                Text(monthlyExpenses.currencyMXN())
                                    .font(.headline)
                                    .foregroundStyle(.red)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Balance")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                
                                Text(monthlyBalance.currencyMXN())
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundStyle(monthlyBalance >= 0 ? .blue : .red)
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                if !accountBalances.isEmpty {
                    Section("Balance por cuenta") {
                        ForEach(accountBalances) {
                            account in
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(account.name)
                                        .font(.headline)
                                    
                                    Text(account.type.capitalized)
                                        .font(.caption)
                                        .foregroundStyle(account.balance >= 0 ? .blue : .red)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
                
                if let errorMessage {
                    Text("Error: \(errorMessage)")
                        .foregroundStyle(.red)
                }
                
                if transactions.isEmpty {
                    Text("Sin movimientos todavía")
                        .foregroundStyle(.secondary)
                } else {
                    Section("Movimientos") {
                        ForEach(transactions) {
                            tx in HStack(alignment: .top, spacing: 12) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(tx.direction == "expense" ? "Gasto" : "Ingreso")
                                        .font(.headline)
                                    
                                    Text(tx.note?.isEmpty == false ? tx.note! : "Sin nota")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                    
                                    Text(tx.occurredAt.formattedShortDate())
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                
                                Spacer()
                                
                                let signedAmount = tx.direction == "expense" ? -tx.amount : tx.amount
                                
                                Text(signedAmount.currencyMXN())
                                    .font(.headline)
                                    .foregroundStyle(tx.direction == "expense" ? .red : .green)
                                    .multilineTextAlignment(.trailing)
                            }
                            
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            
            .listStyle(.insetGrouped)
            .navigationTitle("Finanzas")
            .toolbar {
                ToolbarItem(placement: .principal) {
                    DatePicker(
                        "",
                        selection: $selectedMonth,
                        displayedComponents: .date
                    )
                    .labelsHidden()
                }
            }
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
            .onChange(of: selectedMonth) {
                load()
            }
        }
    }
    
    private func load() {
        do {
            transactions = try repo.fetchTransactions(forMonthContaining: selectedMonth)
            loadSummary()
            loadAccountBalances()
            errorMessage = nil
        } catch {
            errorMessage = "\(error)"
        }
    }
    
    private func loadSummary() {
        do {
            let totals = try repo.monthlyTotals(forMonthContaining: selectedMonth)
            monthlyIncome = totals.income
            monthlyExpenses = totals.expense
        } catch {
            errorMessage = "\(error)"
        }
    }
    
    private func loadAccountBalances() {
        do {
            accountBalances = try repo.fetchAccountBalances()
        } catch {
            errorMessage = "\(error)"
        }
    }
}
