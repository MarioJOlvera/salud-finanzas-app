//
//  AccountsView.swift
//  SaludFinanzasApp
//
//  Created by Mario Alberto Juarez Olvera on 19/02/26.
//

import SwiftUI

struct AccountsView: View {
    @Environment(AppEnvironment.self) var env
    @State private var accounts: [FinanceAccount] = []
    @State private var showAdd = false
    @State private var errorMessage: String?
    
    private var repo: FinanceRepository {
        FinanceRepository(dbQueue: env.db.dbQueue)
    }
    
    var body: some View {
        List {
            if let errorMessage {
                Text("Error: \(errorMessage)").foregroundStyle(Color.red)
            }
            
            ForEach(accounts) {
                a in VStack(alignment: .leading) {
                    Text(a.name).font(.headline)
                    Text(a.type).foregroundStyle(.secondary)
                }
            }
            .onDelete(perform: delete)
        }
        .navigationTitle("Cuentas")
        .toolbar{
            Button { showAdd = true } label: { Image(systemName: "plus") }
        }
        .sheet(isPresented: $showAdd) {
            AddAccountView {
                name, type in create(name: name, type: type)
            }
        }
        .onAppear { load() }
    }
    
    private func load() {
        do {
            try repo.seedIfNeeded()
            accounts = try repo.fetchAccounts()
            errorMessage = nil
        } catch { errorMessage = "\(error)"}
    }
    
    private func create(name: String, type: String) {
        do {
            try repo.addAccount(name: name, type: type)
            load()
        } catch { errorMessage = "\(error)" }
    }
    
    private func delete(at offsets: IndexSet) {
        do {
            for i in offsets {
                try repo.deleteAccount(id: accounts[i].id)
            }
            load()
        } catch { errorMessage = "\(error)"}
    }
}
