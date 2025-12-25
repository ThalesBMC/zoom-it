//
//  OnboardingView.swift
//  ZoomIt
//

import SwiftUI

struct OnboardingView: View {
    var onComplete: () -> Void
    var onOpenSettings: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            // Icon
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 70, height: 70)
                
                Image(systemName: "plus.magnifyingglass")
                    .font(.system(size: 32, weight: .medium))
                    .foregroundColor(.white)
            }
            .padding(.top, 20)
            
            // Title
            Text("Welcome to ZoomIt")
                .font(.system(size: 20, weight: .bold))
            
            // Explanation
            Text("To zoom your screen, ZoomIt needs\nScreen Recording permission.")
                .font(.system(size: 13))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Divider()
                .padding(.horizontal, 20)
            
            // Steps
            VStack(alignment: .leading, spacing: 12) {
                StepItem(number: 1, text: "Click \"Open Settings\" below")
                StepItem(number: 2, text: "Find ZoomIt in the list")
                StepItem(number: 3, text: "Turn ON the toggle")
            }
            .padding(.horizontal, 20)
            
            Spacer()
            
            // Buttons
            VStack(spacing: 12) {
                Button(action: onOpenSettings) {
                    HStack {
                        Image(systemName: "gear")
                        Text("Open Settings")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                
                Button(action: onComplete) {
                    Text("I've done it →")
                        .font(.system(size: 13, weight: .medium))
                }
                .buttonStyle(.plain)
                .foregroundColor(.accentColor)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
    }
}

struct StepItem: View {
    let number: Int
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.accentColor)
                    .frame(width: 24, height: 24)
                
                Text("\(number)")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
            }
            
            Text(text)
                .font(.system(size: 13))
                .foregroundColor(.primary)
        }
    }
}

#Preview {
    OnboardingView(onComplete: {}, onOpenSettings: {})
        .frame(width: 300, height: 420)
}
