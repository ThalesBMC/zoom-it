//
//  ZoomItApp.swift
//  ZoomIt
//
//  A simple screen zoom utility for macOS
//

import SwiftUI
import AppKit

@main
struct ZoomItApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings {
            SettingsView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var popover: NSPopover?
    private var zoomWindow: ZoomWindow?
    private var escapeMonitor: Any?
    
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        setupMenuBar()
        setupPopover()
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }
    
    func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "plus.magnifyingglass", accessibilityDescription: "ZoomIt")
            button.action = #selector(togglePopover)
            button.target = self
        }
    }
    
    func setupPopover() {
        popover = NSPopover()
        popover?.behavior = .transient
        
        if hasCompletedOnboarding {
            showMainView()
        } else {
            showOnboarding()
        }
    }
    
    func showOnboarding() {
        popover?.contentSize = NSSize(width: 300, height: 420)
        popover?.contentViewController = NSHostingController(
            rootView: OnboardingView(
                onComplete: { [weak self] in
                    self?.completeOnboarding()
                },
                onOpenSettings: { [weak self] in
                    self?.openSystemPreferences()
                }
            )
        )
    }
    
    func showMainView() {
        popover?.contentSize = NSSize(width: 280, height: 320)
        popover?.contentViewController = NSHostingController(rootView: MenuBarView(appDelegate: self))
    }
    
    func completeOnboarding() {
        hasCompletedOnboarding = true
        showMainView()
    }
    
    @objc func togglePopover() {
        guard let button = statusItem.button else { return }
        
        if popover?.isShown == true {
            popover?.performClose(nil)
        } else {
            if popover == nil {
                setupPopover()
            }
            popover?.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        }
    }
    
    func openSystemPreferences() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenCapture") {
            NSWorkspace.shared.open(url)
        }
    }
    
    func startZoom(level: CGFloat) {
        popover?.performClose(nil)
        
        // Create and start zoom
        zoomWindow = ZoomWindow()
        zoomWindow?.startZoom(level: level)
        
        // Listen for ESC key
        escapeMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            if event.keyCode == 53 { // ESC
                self?.stopZoom()
                return nil
            }
            return event
        }
    }
    
    func stopZoom() {
        // Remove ESC monitor
        if let monitor = escapeMonitor {
            NSEvent.removeMonitor(monitor)
            escapeMonitor = nil
        }
        
        // Stop zoom
        zoomWindow?.stopZoom()
        zoomWindow = nil
    }
}
