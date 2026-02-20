//
//  AddTransactionView.swift
//  SaludFinanzasApp
//
//  Created by Mario Alberto Juarez Olvera on 19/02/26.
//

import SwiftUI

struct AddTransactionView: View {
    let repo: FinanceRepository
    let onSaved: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var direction: String = "expense"
    @State private var amountText: String = ""
    @State private var note: String = ""
    @State private var errorMessage: String?
    
    @State private var accounts: [FinanceAccount] = []
    @State private var categories: [FinanceCategory] = []
    @State private var selectedAccountId: String?
    @State private var selectedCategoryId: String?
    
    var body: some View {
        NavigationView {
            Form {
                Picker("Tipo", selection: $direction) {
                    Text("Gasto").tag("expense")
                    Text("Ingreso").tag("income")
                }
                .onChange(of: direction) {
                    loadCategories()
                    selectedCategoryId = categories.first?.id
                }
                
                TextField("Monto", text: $amountText).keyboardType(.decimalPad)
                
                Picker("Cuenta", selection: Binding(
                    get: { selectedAccountId ?? "" },
                    set: { selectedAccountId = $0 }
                )){
                    ForEach(accounts) {
                        a in Text(a.name).tag(a.id)
                    }
                }
                
                Picker("Categoría", selection: Binding(
                    get: { selectedCategoryId ?? "" },
                    set: { selectedCategoryId = $0 }
                )) {
                    ForEach(categories) {
                        c in Text(c.name).tag(c.id)
                    }
                }
                
                TextField("Nota (opcional)", text: $note)
                
                if let errorMessage {
                    Text(errorMessage).foregroundStyle(Color.red)
                }
            }
            
            .navigationTitle("Nuevo movimiento")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") { save() }
                }
            }
            .onAppear {
                loadInitial()
            }
        }
    }
    
    private func loadInitial() {
        do {
            // Asegura Defaults
            try repo.seedIfNeeded()
            
            accounts = try repo.fetchAccounts()
            selectedAccountId = accounts.first?.id
            
            loadCategories()
            selectedCategoryId = categories.first?.id
            
            errorMessage = nil
        } catch {
            errorMessage = "\(error)"
        }
    }
    
    private func loadCategories() {
        do {
            categories = try repo.fetchCategories(kind: direction)
        } catch {
            errorMessage = "\(error)"
        }
    }
    
    private func save() {
        guard let amount = Double(amountText.replacingOccurrences(of: ",", with: "."))
        else {
            errorMessage = "Monto Invalido"
            return
        }
        guard let accountId = selectedAccountId
        else {
            errorMessage = "Selecciona una cuenta"
            return
        }
        do {
            try repo.addTransaction(
                amount: amount,
                direction: direction,
                accountId: accountId,
                categoryId: selectedCategoryId,
                note: note.isEmpty ? nil : note
            )
            onSaved()
            dismiss()
        } catch {
            errorMessage = "\(error)"
        }
    }
}
