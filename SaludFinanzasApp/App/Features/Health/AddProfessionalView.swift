//
//  AddProfessionalView.swift
//  SaludFinanzasApp
//
//  Created by Mario Alberto Juarez Olvera on 13/04/26.
//

import SwiftUI

struct AddProfessionalsView: View {
    let onSave: (String, String, String?, String?) -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String = ""
    @State private var specialty: String = ""
    @State private var phone: String = ""
    @State private var email: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Nombre", text: $name)
                TextField("Especialidad", text: $specialty)
                TextField("Teléfono (opcional): ", text: $phone)
                    .keyboardType(.phonePad)
                TextField("Correo electrónico (opcional):", text: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
            }
            .navigationTitle("Nuevo profesional")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        onSave(
                            name.trimmingCharacters(in: .whitespacesAndNewlines),
                            specialty.trimmingCharacters(in: .whitespacesAndNewlines),
                            phone.trimmingCharacters(in: .whitespacesAndNewlines),
                            email.trimmingCharacters(in: .whitespacesAndNewlines)
                        )
                        dismiss()
                    }
                    .disabled(
                        name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                        specialty.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                    )
                }
            }
        }
    }
}
