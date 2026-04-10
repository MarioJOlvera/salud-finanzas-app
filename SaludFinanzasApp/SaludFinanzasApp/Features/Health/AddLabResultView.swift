//
//  AddLabResultView.swift
//  SaludFinanzasApp
//
//  Created by Mario Alberto Juarez Olvera on 10/04/26.
//


import SwiftUI

struct AddLabResultView: View {
    let repo: HealthRepository
    let onSaved: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var biomarkers: [Biomarker] = []
    @State private var selectedBiomarkerId: String?
    @State private var valueText: String = ""
    @State private var unit: String = "mg/dL"
    @State private var referenceMinText: String = ""
    @State private var referenceMaxText: String = ""
    @State private var errorMessage: String?
    
    var body: some  View {
        NavigationView {
            Form {
                Picker("Biomarcador", selection: Binding(
                    get: { selectedBiomarkerId ?? "" },
                    set: { selectedBiomarkerId = $0 }
                )) {
                    ForEach(biomarkers) {
                        biomarker in Text(biomarker.name).tag(biomarker.id)
                    }
                }
                
                TextField("Valor", text: $valueText)
                    .keyboardType(.decimalPad)
                
                TextField("Unidad", text: $unit)
                
                TextField("Referencia mínima (opcional)", text: $referenceMinText)
                    .keyboardType(.decimalPad)
                
                TextField("Referencia máxima (opcional)", text: $referenceMaxText)
                    .keyboardType(.decimalPad)
                
                if let errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                }
            }
            .navigationTitle("Nuevo resultado")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        save()
                    }
                }
            }
            .onAppear {
                loadBiomarkers()
            }
        }
    }
    
    private func loadBiomarkers() {
        do {
            try repo.seedBiomarkersIfNeeded()
            biomarkers = try repo.fetchBiomarkers()
            selectedBiomarkerId = biomarkers.first?.id
        } catch {
            errorMessage = "\(error)"
        }
    }
    
    private func save() {
        guard let biomarkerId = selectedBiomarkerId else {
            errorMessage = "Selecciona un biomarcador."
            return
        }
        
        guard let value = Double(valueText.replacingOccurrences(of: ",", with: ".")) else {
            errorMessage = "Valor inválido."
            return
        }
        
        let refMin = Double(referenceMinText.replacingOccurrences(of: ",", with: "."))
        let refMax = Double(referenceMaxText.replacingOccurrences(of: ",", with: "."))
        
        do {
            try repo.addLabResult(
                biomarkerId: biomarkerId,
                value: value,
                unit: unit,
                referenceMin: refMin,
                referenceMax: refMax
            )
            
            onSaved()
            dismiss()
        } catch {
            errorMessage = "\(error)"
        }
    }
}
