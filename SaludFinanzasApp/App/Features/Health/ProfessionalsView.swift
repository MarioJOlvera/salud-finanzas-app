//
//  ProfessionalsView.swift
//  SaludFinanzasApp
//
//  Created by Mario Alberto Juarez Olvera on 13/04/26.
//

import SwiftUI

struct ProfessionalsView: View {
    @Environment(AppEnvironment.self) var env
    
    @State private var professionals: [Professional] = []
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
            
            if professionals.isEmpty {
                Text("No hay profesionales registrados")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(professionals) {
                    professional in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(professional.name)
                            .font(.headline)
                        
                        Text(professional.specialty)
                            .foregroundStyle(.secondary)
                        
                        if let phone = professional.phone, !phone.isEmpty {
                            Text(phone)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        if let email = professional.email, !email.isEmpty {
                            Text(email)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
                .onDelete(perform: delete)
            }
        }
        .navigationTitle("Profesionales")
        .toolbar {
            Button{
                showAdd = true
            } label: {
                Image(systemName: "plus")
            }
        }
        .sheet(isPresented: $showAdd) {
            AddProfessionalsView {
                name, specialty, phone, email in
                create(name: name, specialty: specialty, phone: phone, email: email)
            }
        }
        .onAppear{
            load()
        }
    }
    
    private func load() {
        do {
            professionals = try repo.fetchProfessionals()
            errorMessage = nil
        } catch {
            errorMessage = "\(error)"
        }
    }
    
    private func create(
        name: String,
        specialty: String,
        phone: String?,
        email: String?
    ) {
        do {
            try repo.addProfessional(
                name: name,
                specialty: specialty,
                phone: phone,
                email: email
            )
            load()
        } catch {
            errorMessage = "\(error)"
        }
    }
    
    private func delete(at offsets: IndexSet) {
        do {
            for i in offsets {
                try repo.deleteProfessional(id: professionals[i].id)
            }
            load()
        } catch {
            errorMessage = "\(error)"
        }
    }
}
