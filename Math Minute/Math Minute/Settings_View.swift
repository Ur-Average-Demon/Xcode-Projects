//
//  Settings_View.swift
//  Math Minute
//
//  Created by Justin Gangaram on 8/8/25.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("selectedTheme") private var selectedThemeRaw: String = Theme.light.rawValue
    @AppStorage("soundEnabled") private var soundEnabled: Bool = true

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Appearance")) {
                    Picker("Theme", selection: $selectedThemeRaw) {
                        ForEach(Theme.allCases) { t in
                            Text(t.rawValue.capitalized).tag(t.rawValue)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                Section(header: Text("Sound")) {
                    Toggle("Sound Effects", isOn: $soundEnabled)
                        .onChange(of: soundEnabled) { newValue in
                            if !newValue {
                                // quick mute: stop tick
                                SoundManager.shared.stopTick()
                            }
                        }
                }
                Section {
                    Button("Reset Best Score") {
                        UserDefaults.standard.set(0, forKey: "bestScore")
                    }.foregroundColor(.red)
                }
            }
            .navigationTitle("Settings")
        }
    }
}
