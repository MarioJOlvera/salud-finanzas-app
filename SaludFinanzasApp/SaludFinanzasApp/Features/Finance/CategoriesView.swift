//
//  CategoriesView.swift
//  SaludFinanzasApp
//
//  Created by Mario Alberto Juarez Olvera on 20/02/26.
//

import SwiftUI

struct CategoriesView: View {
    @Environment(AppEnvironment.self) var env
    
    @State private var kind: String = "expense"
    @State private var categories: [FinanceCategory] = []
    @State private var showAdd = false
    @State private var errorMessage: String?
    
    private var repo: FinanceRepository {
        FinanceRepository(dbQueue: env.db.dbQueue)
    }
    
    var body: some View {
        List {
            Picker("Tipo", selection: $kind) {
                Text("Gastos").tag("expense")
                Text("Ingresos").tag("income")
            }
            .pickerStyle(.segmented)
            .listRowInsets(EdgeInsets())
            
            if let errorMessage {
                Text("Error: \(errorMessage)").foregroundStyle(Color.red)
            }
            
            ForEach(categories) {
                c in Text(c.name)
            }
            .onDelete(perform: delete)
        }
        .navigationTitle("Categorías")
        .toolbar {
            Button { showAdd = true } label: { Image(systemName: "plus") }
        }
        .sheet(isPresented: $showAdd) {
            AddCategoryView(kind: kind){
                name in create(name: name)
            }
        }
        .onAppear{ load() }
        .onChange(of: kind) { load() }
    }
    
    private func load() {
        do {
            try repo.seedIfNeeded()
            categories = try repo.fetchCategories(kind: kind)
            errorMessage = nil
        } catch { errorMessage = "\(error)"}
    }
    
    private func create(name: String) {
        do {
            try repo.addCategory(name: name, kind: kind)
            load()
        } catch { errorMessage = "\(error)"}
    }
    
    private func delete(at offsets: IndexSet) {
        do {
            for i in offsets {
                try repo.deleteCategory(id: categories[i].id)
            }
            load()
        } catch { errorMessage = "\(error)"}
    }
}
