import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            HealthHomeView()
                .tabItem {
                    Label("Salud", systemImage: "heart")
                }
            
            FinanceHomeView()
                .tabItem {
                    Label("Finanzas", systemImage: "dollarsign.circle")
                }
            
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "chart.bar")
                }
        }
    }
}
