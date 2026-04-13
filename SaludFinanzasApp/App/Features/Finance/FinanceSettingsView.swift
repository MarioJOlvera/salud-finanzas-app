//
//  FinanceSettingsView.swift
//  SaludFinanzasApp
//
//  Created by Mario Alberto Juarez Olvera on 19/02/26.
//

import SwiftUI

struct FinanceSettingsView: View {
    var body: some View {
        List {
            NavigationLink("Cuentas", destination: AccountsView())
            NavigationLink("Categorías", destination: CategoriesView())
        }
        .navigationTitle("Ajustes")
    }
}
