//
//  HealthSettingView.swift
//  SaludFinanzasApp
//
//  Created by Mario Alberto Juarez Olvera on 13/04/26.
//

import SwiftUI

struct HealthSettingsView: View {
    var body: some View {
        List {
            NavigationLink("Profesionales", destination: ProfessionalsView())
            NavigationLink("Citas", destination: AppointmentsView())
        }
        .navigationTitle("Ajusted Salud")
    }
}
