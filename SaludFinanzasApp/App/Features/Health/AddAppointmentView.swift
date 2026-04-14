//
//  AddAppointmentView.swift
//  SaludFinanzasApp
//
//  Created by Mario Alberto Juarez Olvera on 13/04/26.
//

import SwiftUI

struct AddAppointmentView: View {
    let repo: HealthRepository
    let onSaved: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var professionals: [Professional] = []
    @State private var selectedProfessionalId: String?
    @State private var scheduledAt: Date = Date()
    @State private var location: String = ""
    @State private var note: String = ""
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            Form {
                Picker("Profesional", selection: Binding(
                    get: { selectedProfessionalId ?? "" },
                    set: { selectedProfessionalId = $0 }
                )) {
                    ForEach(professionals) {
                        professional in
                        Text("\(professional.name) - \(professional.specialty)")
                            .tag(professional.id)
                    }
                }
                
                DatePicker("Fecha y hora", selection: $scheduledAt)
                
                TextField("Lugar (opcional)", text: $location)
                TextField("Nota (opcional)", text: $note)
                
                if let errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                }
            }
            .navigationTitle("Nueva cita")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") { save() }
                }
            }
            .onAppear {
                loadProfessionals()
            }
        }
    }
    
    private func loadProfessionals() {
        do {
            professionals = try repo.fetchProfessionals()
            selectedProfessionalId = professionals.first?.id
        } catch {
            errorMessage = "\(error)"
        }
    }
    
    private func save() {
        guard let professionalId = selectedProfessionalId else {
            errorMessage = "Primero crea un profesional"
            return
        }
        
        do {
            try repo.addAppointment(
                professionalId: professionalId,
                scheduledAt: scheduledAt.toISO8601UTCString(),
                location: location,
                note: note
            )
            onSaved()
            dismiss()
        } catch {
            errorMessage = "\(error)"
        }
    }
}
