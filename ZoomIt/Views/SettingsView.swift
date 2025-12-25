//
//  SettingsView.swift
//  ZoomIt
//

import SwiftUI
import ServiceManagement

struct SettingsView: View {
    @AppStorage("defaultZoomLevel") private var defaultZoomLevel: Double = 2.0
    @AppStorage("showCrosshair") private var showCrosshair: Bool = true
    @AppStorage("launchAtLogin") private var launchAtLogin: Bool = false
    
    var body: some View {
        TabView {
            GeneralSettingsView(
                defaultZoomLevel: $defaultZoomLevel,
                showCrosshair: $showCrosshair,
                launchAtLogin: $launchAtLogin
            )
            .tabItem {
                Label("General", systemImage: "gear")
            }
            
            AboutView()
                .tabItem {
                    Label("About", systemImage: "info.circle")
                }
        }
        .frame(width: 400, height: 280)
    }
}

struct GeneralSettingsView: View {
    @Binding var defaultZoomLevel: Double
    @Binding var showCrosshair: Bool
    @Binding var launchAtLogin: Bool
    
    var body: some View {
        Form {
            Section {
                HStack {
                    Text("Default Zoom Level")
                    Spacer()
                    Picker("", selection: $defaultZoomLevel) {
                        Text("1.0x").tag(1.0)
                        Text("1.5x").tag(1.5)
                        Text("2x").tag(2.0)
                        Text("2.5x").tag(2.5)
                        Text("3x").tag(3.0)
                        Text("4x").tag(4.0)
                        Text("5x").tag(5.0)
                        Text("6x").tag(6.0)
                    }
                    .frame(width: 100)
                }
                
                Toggle("Show Crosshair", isOn: $showCrosshair)
                
                Toggle("Launch at Login", isOn: $launchAtLogin)
                    .onChange(of: launchAtLogin) { newValue in
                        setLaunchAtLogin(newValue)
                    }
            }
            
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Keyboard Shortcuts")
                        .font(.headline)
                    
                    HStack {
                        Text("Exit Zoom")
                        Spacer()
                        KeyboardShortcutBadge(key: "ESC")
                    }
                    .foregroundColor(.secondary)
                }
            }
        }
        .formStyle(.grouped)
        .padding()
    }
    
    private func setLaunchAtLogin(_ enabled: Bool) {
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            print("Failed to set launch at login: \(error)")
        }
    }
}

struct KeyboardShortcutBadge: View {
    let key: String
    
    var body: some View {
        Text(key)
            .font(.system(.caption, design: .monospaced, weight: .medium))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.secondary.opacity(0.2))
            .cornerRadius(4)
    }
}

struct AboutView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "plus.magnifyingglass")
                .font(.system(size: 64))
                .foregroundColor(.accentColor)
            
            Text("ZoomIt")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Version 1.0.0")
                .foregroundColor(.secondary)
            
            Text("A simple screen zoom utility for macOS")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text("© 2024 Your Company")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    SettingsView()
}

