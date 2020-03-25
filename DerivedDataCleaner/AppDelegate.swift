//
//  AppDelegate.swift
//  DerivedDataCleaner
//
//  Created by p.nosov on 18.03.2020.
//  Copyright © 2020 p.nosov. All rights reserved.
//

import Cocoa
import ServiceManagement

extension Notification.Name {
    static let killLauncher = Notification.Name("killLauncher")
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    enum Path: String {
        case derivedData = "Library/Developer/Xcode/DerivedData/"
    }

    private let manager = FileManager.default
    private var statusBarItem: NSStatusItem!

    func applicationDidFinishLaunching(_ aNotification: Notification) {

        checkIfLauncherIsRunningAndKill()

        statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        guard let button = statusBarItem?.button else {
            print("status bar item failed. Try removing some menu bar item.")
            NSApp.terminate(nil)
            return
        }

        button.image = NSImage(named: "MenuBarButton")
        button.target = self

        let statusBarMenu = NSMenu(title: "Status Bar Menu")
        statusBarItem?.menu = statusBarMenu

        statusBarMenu.addItem(
            withTitle: "Clean DerivedData",
            action: #selector(cleanDerivedData),
            keyEquivalent: "")

        statusBarMenu.addItem(
            withTitle: "Open DerivedData",
            action: #selector(openDerivedData),
            keyEquivalent: "")

        statusBarMenu.addItem(.separator())

        statusBarMenu.addItem(
            withTitle: "Quit",
            action: #selector(terminate(_:)),
            keyEquivalent: "")
        
    }

    private func checkIfLauncherIsRunningAndKill() {
        let launcherAppId = "Itr.LauncherApplication"
        let runningApps = NSWorkspace.shared.runningApplications
        let isRunning = !runningApps.filter { $0.bundleIdentifier == launcherAppId }.isEmpty

        SMLoginItemSetEnabled(launcherAppId as CFString, true)

        if isRunning {
            DistributedNotificationCenter.default().post(name: .killLauncher, object: Bundle.main.bundleIdentifier!)
        }
    }

    private func cleanDirectory(at path: Path) {
        let home = manager.homeDirectoryForCurrentUser
        let url = home.appendingPathComponent(path.rawValue)
        try? manager.removeItem(at: url)
    }

    private func openDirectory(at path: Path) {
        let home = manager.homeDirectoryForCurrentUser
        let url = home.appendingPathComponent(path.rawValue)
        NSWorkspace.shared.open(url)
    }

    @objc
    func cleanDerivedData() {
        cleanDirectory(at: .derivedData)
    }

    @objc
    func openDerivedData() {
        openDirectory(at: .derivedData)
    }

    @objc
    func terminate(_ sender: NSMenuItem) {
        NSApp.terminate(sender)
    }

    
}

