//
//  AppointmentsView.swift
//  SaludFinanzasApp
//
//  Created by Mario Alberto Juarez Olvera on 13/04/26.
//

import SwiftUI

struct AppointmentsView: View {
    @Environment(AppEnvironment.self) var env
    
    @State private var appointments: [Appointment] = []
    @State private var showAdd = false
    @State private var errorMessage: String?
    
    private var repo: HealthRepository {
        HealthRepository(dbQueue: env.db.dbQueue)
    }
    
    var body: some View {
        List {
            if let errorMessage {
                Text("Error: \(errorMessage)")
                    .foregroundStyle(.red)
            }
            
            if appointments.isEmpty {
                Text("No hay citas registradas")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(appointments) {
                    appointment in
                    VStack(alignment: .leading, spacing:4) {
                        Text(appointment.status.capitalized)
                            .font(.headline)
                        
                        Text(appointment.scheduledAt.formattedShorDate())
                            .foregroundStyle(.secondary)
                        
                        if let location = appointment.location, !location.isEmpty {
                            Text(location)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        if let note = appointment.note, !note.isEmpty {
                            Text(note)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
                .onDelete(perform: delete)
            }
        }
        .navigationTitle("Citas")
        .toolbar {
            Button {
                showAdd = true
            } label: {
                Image(systemName: "plus")
            }
        }
        .sheet(isPresented: $showAdd) {
            AddAppointmentView(repo: repo) {
                load()
            }
        }
        .onAppear{
            load()
        }
    }
    
    private func load() {
        do {
            appointments = try repo.fetchAppointments()
            errorMessage = nil
        } catch {
            errorMessage = "\(error)"
        }
    }
    
    private func delete(at offsets: IndexSet) {
        do {
            for i in offsets{
                try repo.deleteAppointment(id: appointments[i].id)
            }
            load()
        } catch {
            errorMessage = "\(error)"
        }
    }
}
