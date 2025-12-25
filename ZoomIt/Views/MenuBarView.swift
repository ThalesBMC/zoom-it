//
//  MenuBarView.swift
//  ZoomIt
//

import SwiftUI

struct MenuBarView: View {
    weak var appDelegate: AppDelegate?
    @State private var zoomLevel: Double = 2.0
    @AppStorage("defaultZoomLevel") private var defaultZoomLevel: Double = 2.0
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                Image(systemName: "plus.magnifyingglass")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(.accentColor)
                
                Text("ZoomIt")
                    .font(.system(size: 20, weight: .bold))
            }
            .padding(.top, 8)
            
            Divider()
            
            // Zoom Level Slider
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Zoom Level")
                        .font(.headline)
                    Spacer()
                    Text("\(zoomLevel, specifier: "%.1f")x")
                        .font(.system(.body, design: .monospaced))
                        .foregroundColor(.secondary)
                }
                
                HStack(spacing: 12) {
                    Image(systemName: "minus.magnifyingglass")
                        .foregroundColor(.secondary)
                    
                    Slider(value: $zoomLevel, in: 1.0...6.0, step: 0.5)
                        .tint(.accentColor)
                    
                    Image(systemName: "plus.magnifyingglass")
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 4)
            
            // Quick Zoom Buttons
            VStack(spacing: 8) {
                Text("Quick Zoom")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 8) {
                    QuickZoomButton(level: 2.0, currentLevel: $zoomLevel)
                    QuickZoomButton(level: 3.0, currentLevel: $zoomLevel)
                    QuickZoomButton(level: 4.0, currentLevel: $zoomLevel)
                    QuickZoomButton(level: 5.0, currentLevel: $zoomLevel)
                }
            }
            
            Divider()
            
            // Start Zoom Button
            Button(action: {
                defaultZoomLevel = zoomLevel
                appDelegate?.startZoom(level: CGFloat(zoomLevel))
            }) {
                HStack {
                    Image(systemName: "viewfinder")
                    Text("Start Zoom")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            
            // Instructions
            VStack(spacing: 6) {
                HStack(spacing: 4) {
                    Text("ESC")
                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.secondary.opacity(0.2))
                        .cornerRadius(4)
                    Text("exit")
                        .foregroundColor(.secondary)
                    
                    Text("•")
                        .foregroundColor(.secondary.opacity(0.5))
                    
                    Text("Scroll to adjust zoom")
                        .foregroundColor(.secondary)
                }
                .font(.caption)
                
                // Permission hint (small, non-intrusive)
                Button(action: {
                    appDelegate?.openSystemPreferences()
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "gear")
                        Text("Screen not visible? Grant permission")
                    }
                    .font(.caption2)
                    .foregroundColor(.secondary.opacity(0.7))
                }
                .buttonStyle(.plain)
            }
            .padding(.bottom, 8)
        }
        .padding(16)
        .onAppear {
            zoomLevel = defaultZoomLevel
        }
    }
}

struct QuickZoomButton: View {
    let level: Double
    @Binding var currentLevel: Double
    
    var isSelected: Bool {
        abs(currentLevel - level) < 0.1
    }
    
    var body: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.15)) {
                currentLevel = level
            }
        }) {
            Text("\(Int(level))x")
                .font(.system(.callout, design: .rounded, weight: .medium))
                .frame(width: 44, height: 32)
        }
        .buttonStyle(.bordered)
        .tint(isSelected ? .accentColor : .secondary)
    }
}

#Preview {
    MenuBarView(appDelegate: nil)
        .frame(width: 280, height: 320)
}
