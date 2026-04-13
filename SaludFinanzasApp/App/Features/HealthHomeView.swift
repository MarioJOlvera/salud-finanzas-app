//
//  HealthHomeView.swift
//  SaludFinanzasApp
//
//  Created by Mario Alberto Juarez Olvera on 17/02/26.
//

import SwiftUI

struct HealthHomeView: View {
    @Environment(AppEnvironment.self) var env
    
    @State private var biomarkers: [Biomarker] = []
    @State private var results: [LabResult] = []
    @State private var showAdd = false
    @State private var errorMessage: String?
    
    private var repo: HealthRepository {
        HealthRepository(dbQueue: env.db.dbQueue)
    }
    
    var body: some View {
        NavigationView {
            List {
                if let errorMessage {
                    Text("Error: \(errorMessage)")
                        .foregroundStyle(.red)
                }
                
                Section("Biomarcadores") {
                    if biomarkers.isEmpty {
                        Text("No hay biomarcadores")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(biomarkers) {
                            biomarker in Text(biomarker.name)
                        }
                    }
                }
                
                Section("Resultados recientes") {
                    if results.isEmpty {
                        Text("No hay resultados todavía")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(results) {
                            result in
                            VStack(alignment: .leading, spacing: 4) {
                                Text("\(result.value, specifier: "%.2f") \(result.unit)")
                                    .font(.headline)
                                
                                Text(result.testedAt.formattedShorDate())
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Salud")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button{
                        showAdd = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAdd) {
                AddLabResultView(repo: repo) {
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
            try repo.seedBiomarkersIfNeeded()
            biomarkers = try repo.fetchBiomarkers()
            results = try repo.fetchLabResults()
            errorMessage = nil
        } catch {
            errorMessage = "\(error)"
        }
    }
}
