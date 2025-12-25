//
//  ZoomWindow.swift
//  ZoomIt
//

import SwiftUI
import AppKit
import CoreGraphics

class ZoomWindow: NSObject {
    private var window: NSWindow?
    private var zoomView: ZoomView?
    private var islandWindow: NSWindow?
    private var timer: Timer?
    private var zoomLevel: CGFloat = 2.0
    
    func startZoom(level: CGFloat) {
        self.zoomLevel = level
        
        guard let screen = NSScreen.main else { return }
        
        // Create fullscreen window
        window = NSWindow(
            contentRect: screen.frame,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        
        window?.level = .floating
        window?.isOpaque = true
        window?.backgroundColor = .black
        window?.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        window?.ignoresMouseEvents = false
        
        // Create zoom view
        zoomView = ZoomView(frame: screen.frame, zoomLevel: level)
        window?.contentView = zoomView
        
        // Show window
        window?.makeKeyAndOrderFront(nil)
        window?.makeFirstResponder(zoomView)
        
        // Create floating island
        createIsland(on: screen, zoomLevel: level)
        
        // Hide cursor
        NSCursor.hide()
        
        // Simple timer for updates (60fps)
        timer = Timer.scheduledTimer(withTimeInterval: 1.0/60.0, repeats: true) { [weak self] _ in
            self?.zoomView?.setNeedsDisplay(self?.zoomView?.bounds ?? .zero)
        }
    }
    
    private func createIsland(on screen: NSScreen, zoomLevel: CGFloat) {
        let islandWidth: CGFloat = 280
        let islandHeight: CGFloat = 44
        let islandX = (screen.frame.width - islandWidth) / 2
        let islandY = screen.frame.height - islandHeight - 20
        
        islandWindow = NSWindow(
            contentRect: NSRect(x: islandX, y: islandY, width: islandWidth, height: islandHeight),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        
        islandWindow?.level = .screenSaver
        islandWindow?.isOpaque = false
        islandWindow?.backgroundColor = .clear
        islandWindow?.ignoresMouseEvents = true
        islandWindow?.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        
        let islandView = IslandView(frame: NSRect(x: 0, y: 0, width: islandWidth, height: islandHeight), zoomLevel: zoomLevel)
        islandWindow?.contentView = islandView
        zoomView?.islandView = islandView
        
        islandWindow?.orderFront(nil)
    }
    
    func stopZoom() {
        // Stop timer
        timer?.invalidate()
        timer = nil
        
        // Show cursor
        NSCursor.unhide()
        
        // Hide and close windows
        window?.orderOut(nil)
        islandWindow?.orderOut(nil)
        
        // Clear references
        zoomView = nil
        window = nil
        islandWindow = nil
    }
}

// MARK: - Island View (Floating HUD)

class IslandView: NSView {
    private var zoomLevel: CGFloat
    
    init(frame: NSRect, zoomLevel: CGFloat) {
        self.zoomLevel = zoomLevel
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateZoomLevel(_ level: CGFloat) {
        self.zoomLevel = level
        setNeedsDisplay(bounds)
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        guard let context = NSGraphicsContext.current?.cgContext else { return }
        
        // Draw pill background
        let pillRect = bounds.insetBy(dx: 2, dy: 2)
        let pillPath = NSBezierPath(roundedRect: pillRect, xRadius: pillRect.height / 2, yRadius: pillRect.height / 2)
        
        // Dark semi-transparent background
        NSColor(white: 0.1, alpha: 0.85).setFill()
        pillPath.fill()
        
        // Subtle border
        NSColor(white: 0.3, alpha: 0.5).setStroke()
        pillPath.lineWidth = 1
        pillPath.stroke()
        
        // Draw text
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        // ESC text
        let escText = "ESC"
        let escAttributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 11, weight: .semibold),
            .foregroundColor: NSColor.white,
            .paragraphStyle: paragraphStyle
        ]
        
        let escBgRect = NSRect(x: 14, y: (bounds.height - 22) / 2, width: 36, height: 22)
        let escBgPath = NSBezierPath(roundedRect: escBgRect, xRadius: 6, yRadius: 6)
        NSColor(white: 0.25, alpha: 1.0).setFill()
        escBgPath.fill()
        
        let escTextRect = NSRect(x: 14, y: (bounds.height - 18) / 2, width: 36, height: 18)
        escText.draw(in: escTextRect, withAttributes: escAttributes)
        
        // "to exit" text
        let exitText = "to exit"
        let exitAttributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 12, weight: .regular),
            .foregroundColor: NSColor(white: 0.7, alpha: 1.0)
        ]
        let exitTextRect = NSRect(x: 56, y: (bounds.height - 16) / 2, width: 50, height: 16)
        exitText.draw(in: exitTextRect, withAttributes: exitAttributes)
        
        // Divider
        context.setStrokeColor(NSColor(white: 0.3, alpha: 0.8).cgColor)
        context.setLineWidth(1)
        context.move(to: CGPoint(x: 115, y: 10))
        context.addLine(to: CGPoint(x: 115, y: bounds.height - 10))
        context.strokePath()
        
        // Zoom level
        let zoomText = String(format: "%.1fx", zoomLevel)
        let zoomAttributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.monospacedDigitSystemFont(ofSize: 14, weight: .semibold),
            .foregroundColor: NSColor.white
        ]
        let zoomTextRect = NSRect(x: 125, y: (bounds.height - 18) / 2, width: 45, height: 18)
        zoomText.draw(in: zoomTextRect, withAttributes: zoomAttributes)
        
        // Scroll hint
        let hintText = "scroll ↕"
        let hintAttributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 10, weight: .regular),
            .foregroundColor: NSColor(white: 0.5, alpha: 1.0)
        ]
        let hintTextRect = NSRect(x: 175, y: (bounds.height - 14) / 2, width: 70, height: 14)
        hintText.draw(in: hintTextRect, withAttributes: hintAttributes)
    }
}

// MARK: - Zoom View

class ZoomView: NSView {
    private var zoomLevel: CGFloat
    private let minZoom: CGFloat = 1.5
    private let maxZoom: CGFloat = 10.0
    weak var islandView: IslandView?
    
    init(frame: NSRect, zoomLevel: CGFloat) {
        self.zoomLevel = zoomLevel
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Scroll to zoom
    override func scrollWheel(with event: NSEvent) {
        let delta = event.scrollingDeltaY * 0.03
        let newZoom = max(minZoom, min(maxZoom, zoomLevel + delta))
        
        if newZoom != zoomLevel {
            zoomLevel = newZoom
            islandView?.updateZoomLevel(zoomLevel)
        }
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        guard let context = NSGraphicsContext.current?.cgContext else { return }
        guard let screen = NSScreen.main else { return }
        
        // Get mouse location
        let mouseLocation = NSEvent.mouseLocation
        
        // Calculate capture area
        let captureWidth = bounds.width / zoomLevel
        let captureHeight = bounds.height / zoomLevel
        let captureX = mouseLocation.x - captureWidth / 2
        
        // Create capture rect (flip Y for CoreGraphics)
        var captureRect = CGRect(
            x: captureX,
            y: screen.frame.height - mouseLocation.y - captureHeight / 2,
            width: captureWidth,
            height: captureHeight
        )
        
        // Clamp to screen
        captureRect.origin.x = max(0, min(captureRect.origin.x, screen.frame.width - captureWidth))
        captureRect.origin.y = max(0, min(captureRect.origin.y, screen.frame.height - captureHeight))
        
        // Capture screen
        let windowID = CGWindowID(self.window?.windowNumber ?? 0)
        
        if let image = CGWindowListCreateImage(
            captureRect,
            .optionOnScreenBelowWindow,
            windowID,
            [.bestResolution]
        ) {
            context.interpolationQuality = .high
            context.draw(image, in: bounds)
            drawCrosshair(in: context)
        }
    }
    
    private func drawCrosshair(in context: CGContext) {
        let centerX = bounds.midX
        let centerY = bounds.midY
        let size: CGFloat = 20
        
        // Black outline
        context.setStrokeColor(NSColor.black.withAlphaComponent(0.6).cgColor)
        context.setLineWidth(4)
        context.move(to: CGPoint(x: centerX - size, y: centerY))
        context.addLine(to: CGPoint(x: centerX + size, y: centerY))
        context.move(to: CGPoint(x: centerX, y: centerY - size))
        context.addLine(to: CGPoint(x: centerX, y: centerY + size))
        context.strokePath()
        
        // White crosshair
        context.setStrokeColor(NSColor.white.cgColor)
        context.setLineWidth(2)
        context.move(to: CGPoint(x: centerX - size, y: centerY))
        context.addLine(to: CGPoint(x: centerX + size, y: centerY))
        context.move(to: CGPoint(x: centerX, y: centerY - size))
        context.addLine(to: CGPoint(x: centerX, y: centerY + size))
        context.strokePath()
    }
}
