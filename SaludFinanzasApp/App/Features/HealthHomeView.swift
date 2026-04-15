//
//  HealthHomeView.swift
//  SaludFinanzasApp
//
//  Created by Mario Alberto Juarez Olvera on 17/02/26.
//  Modified by Mario Alberto Juárez Olvera on 13/04/2026

import SwiftUI

struct HealthHomeView: View {
    @Environment(AppEnvironment.self) var env
    
    @State private var summary = HealthSummary(
        biomarkerCount: 0,
        labResultCount: 0,
        appointmentCount: 0
    )
    
    @State private var recentResults: [RecentLabResultSummary] = []
    @State private var upcomingAppointments: [UpcomingAppointmentSummary] = []
    
    @State private var showAdd = false
    @State private var errorMessage: String?
    
    private var repo: HealthRepository {
        HealthRepository(dbQueue: env.db.dbQueue)
    }
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Resumen de salud")
                            .font(.headline)
                        
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Biomarcadores")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                
                                Text("\(summary.biomarkerCount)")
                                    .font(.title3)
                                    .fontWeight(.bold)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Resultados")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                
                                Text("\(summary.labResultCount)")
                                    .font(.title3)
                                    .fontWeight(.bold)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Citas")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                
                                Text("\(summary.appointmentCount)")
                                    .font(.title3)
                                    .fontWeight(.bold)
                            }
                        }
                    }
                    
                    .padding(.vertical, 8)
                }
                
                if let errorMessage {
                    Text("Error: \(errorMessage)")
                        .foregroundStyle(.red)
                }
                
                Section("Resultados recientes") {
                    if recentResults.isEmpty {
                        Text("No hay resultados todavía")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(recentResults) {
                            result in
                            HStack(alignment: .top, spacing: 12) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(result.biomarkerName)
                                        .font(.headline)
                                    
                                    Text("\(result.value, specifier: "%.2f") \(result.unit)")
                                        .foregroundStyle(.secondary)
                                    
                                    Text(result.testedAt.formattedShortDate())
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                
                                Spacer()
                                
                                Text(result.statusLabel)
                                    .font(.caption)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(
                                        result.statusColorName == "green"
                                        ? Color.green.opacity(0.15)
                                        : result.statusColorName == "red"
                                        ? Color.red.opacity(0.15)
                                        : Color.gray.opacity(0.15)
                                    )
                                    .foregroundStyle(
                                        result.statusColorName == "green"
                                        ? Color.green
                                        : result.statusColorName == "red"
                                        ? Color.red
                                        : Color.secondary
                                    )
                                    .clipShape(Capsule())
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
                
                Section("Próximas citas") {
                    if upcomingAppointments.isEmpty {
                        Text("No hay próximas citas.")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(upcomingAppointments) {
                            appointment in
                            HStack(alignment: .top, spacing: 12) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(appointment.professionalName)
                                        .font(.headline)
                                    
                                    Text(appointment.specialty)
                                        .foregroundStyle(.secondary)
                                    
                                    Text(appointment.scheduledAt.formattedShorDate())
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    
                                    if let location = appointment.location, !location.isEmpty {
                                        Text(location)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                
                                Spacer()
                                
                                Text(appointment.status.capitalized)
                                    .font(.caption)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(Color.blue.opacity(0.15))
                                    .foregroundStyle(.blue)
                                    .clipShape(Capsule())
                            }
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Salud")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAdd = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
                
                ToolbarItem(placement: .topBarLeading) {
                    NavigationLink(destination: HealthSettingsView()) {
                        Image(systemName: "gearshape")
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
            summary = try repo.fetchHealthSummary()
            recentResults = try repo.fetchRecentLabResultSummaries()
            upcomingAppointments = try repo.fetchUpcomingAppointmentSummaries()
            errorMessage = nil
        } catch {
            errorMessage = "\(error)"
        }
    }
    
}

