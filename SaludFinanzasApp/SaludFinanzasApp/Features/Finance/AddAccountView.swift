//
//  AddAccountView.swift
//  SaludFinanzasApp
//
//  Created by Mario Alberto Juarez Olvera on 19/02/26.
//

import SwiftUI

struct AddAccountView: View {
    let onSave: (String, String) -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var type = "cash"
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Nombre", text: $name)
                
                Picker("Tipo", selection: $type) {
                    Text("Efectivo").tag("cash")
                    Text("Banco").tag("bank")
                    Text("Tarjeta").tag("card")
                }
            }
            .navigationTitle("Nueva cuenta")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        onSave(name.trimmingCharacters(in: .whitespacesAndNewlines), type)
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}
