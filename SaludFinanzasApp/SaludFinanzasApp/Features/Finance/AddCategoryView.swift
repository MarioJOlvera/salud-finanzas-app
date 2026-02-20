//
//  AddCategoryView.swift
//  SaludFinanzasApp
//
//  Created by Mario Alberto Juarez Olvera on 20/02/26.
//

import SwiftUI

struct AddCategoryView: View {
    let kind: String
    let onSave: (String) -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Nombre", text: $name)
                Text(kind == "expense" ? "Tipo: Gasto" : "Tipo: Ingreso")
                    .foregroundStyle(Color.secondary)
            }
            .navigationTitle("Nueva Categoría")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        onSave(name.trimmingCharacters(in: .whitespacesAndNewlines))
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}
