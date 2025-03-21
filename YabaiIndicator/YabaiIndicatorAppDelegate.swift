//
//  YabaiAppDelegate.swift
//  YabaiIndicator
//
//  Created by Max Zhao on 26/12/2021.
//

import SwiftUI
import Combine
import Defaults
import notify

class YabaiIndicatorAppDelegate: NSObject, NSApplicationDelegate, ObservableObject {
	@available(macOS 14.0, *)
	struct SettingsOpener {
		@Environment(\.openSettings) static var openSettings
	}
	
	var statusBarItem: NSStatusItem?
	@Published var spaceModel = SpaceModel()
	
	let statusBarHeight = 22
	let itemWidth: CGFloat = 30
	
	@objc func refreshData(_ notification: Notification?) {
//		print("refreshing data")
		DispatchQueue.main.async {
			self.spaceModel.displays = gNativeClient.queryDisplays()
			self.spaceModel.spaces = gNativeClient.querySpaces()
			self.spaceModel.windows = gYabaiClient.queryWindows()
		}
	}
	
	@objc func settings() {
		if #available(macOS 14, *) {
			SettingsOpener.openSettings()
		} else if #available(macOS 13, *) {
			NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
		} else {
			NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
		}
		NSApp.activate(ignoringOtherApps: true)
	}
	@objc func quit() { NSApp.terminate(self) }
	
	func createMenu() -> NSMenu {
		let statusBarMenu = NSMenu()
		statusBarMenu.addItem(
			withTitle: "Preferences",
			action: #selector(settings),
			keyEquivalent: ",")
		statusBarMenu.addItem(NSMenuItem.separator())
		
		statusBarMenu.addItem(
			withTitle: "Quit",
			action: #selector(quit),
			keyEquivalent: "q")
		return statusBarMenu
	}
	
	func registerObservers() {
		NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(self.refreshData(_:)), name: NSWorkspace.activeSpaceDidChangeNotification, object: nil)
		NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(self.refreshData(_:)), name: Notification.Name("NSWorkspaceActiveDisplayDidChangeNotification"), object: nil)
		var token: Int32 = 0
		notify_register_dispatch("ExposeEnd", &token, DispatchQueue.main) { _ in self.refreshData(nil) }
		notify_register_dispatch("WindowChange", &token, DispatchQueue.main) { _ in self.refreshData(nil) }
	}
	
	func refreshButtonStyle() {
		for subView in statusBarItem?.button?.subviews ?? [] {
			subView.removeFromSuperview()
		}
		let view = NSHostingView(rootView: ContentView()
			.environmentObject(self)
			.environmentObject(spaceModel)
		)
		view.setFrameSize(NSSize(width: 0, height: statusBarHeight))
		
		statusBarItem?.button?.addSubview(view)
		refreshData(nil)
	}
	
	func applicationDidFinishLaunching(_ notification: Notification) {
		if let prefs = Bundle.main.path(forResource: "defaults", ofType: "plist"),
			 let dict = NSDictionary(contentsOfFile: prefs) as? [String : Any] {
			UserDefaults.standard.register(defaults: dict)
		}
		
		let options: NSDictionary = [(kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String): true]
		AXIsProcessTrustedWithOptions(options)
		
		statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
		
		statusBarItem?.menu = createMenu()
		
		refreshButtonStyle()
		registerObservers()
	}
}
