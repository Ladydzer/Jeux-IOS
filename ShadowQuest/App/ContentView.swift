// ContentView.swift
// ShadowQuest
//
// Vue racine — gere la navigation principale

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            MainMenuView()
        }
    }
}

#Preview {
    ContentView()
}
