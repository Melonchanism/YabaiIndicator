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
import Carbon.HIToolbox

class YabaiIndicatorAppDelegate: NSObject, NSApplicationDelegate, ObservableObject {
	@available(macOS 14.0, *)
	struct SettingsOpener {
		@Environment(\.openSettings) static var openSettings
	}
	
	var statusBarItem: NSStatusItem?
	@Published var spaceModel = SpaceModel()
	
	let statusBarHeight = 22
	let itemWidth: CGFloat = 30
	
	func switchSpace(_ space: Space) {
		if !space.active && space.yabaiIndex > 0 {
			Task {
				if space.type == .standard {
					let keyCode = switch space.index {
						case 1: kVK_ANSI_1
						case 2: kVK_ANSI_2
						case 3: kVK_ANSI_3
						case 4: kVK_ANSI_4
						case 5: kVK_ANSI_5
						case 6: kVK_ANSI_6
						case 7: kVK_ANSI_7
						case 8: kVK_ANSI_8
						case 9: kVK_ANSI_9
						case 10: kVK_ANSI_0
						case 11: kVK_ANSI_1
						case 12: kVK_ANSI_2
						case 13: kVK_ANSI_3
						case 14: kVK_ANSI_4
						case 15: kVK_ANSI_5
						case 16: kVK_ANSI_6
						default: kVK_Function
					}
					let event1 = CGEvent(keyboardEventSource: nil, virtualKey: CGKeyCode(keyCode), keyDown: true)!
					if space.yabaiIndex < 11 { event1.flags = [.maskControl, .maskAlternate] }
					else { event1.flags = [.maskControl, .maskAlternate, .maskShift] }
					event1.post(tap: .cghidEventTap);
					CGEvent(keyboardEventSource: nil, virtualKey: CGKeyCode(keyCode), keyDown: false)!.post(tap: .cghidEventTap)
				} else if space.type == .fullscreen {
					// slower method but works for fullscreen
					gYabaiClient.yabaiSocketCall("-m", "window", "--focus", "\(spaceModel.windows.first { $0.spaceIndex == space.yabaiIndex }?.id ?? 0)")
				} else {
					//					print("How did you even manage to click the divider")
				}
			}
		}
	}
	
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
		notify_register_dispatch("NextSpace", &token, DispatchQueue.global(qos: .userInteractive)) { _ in
			let currentSpaceIDX = self.spaceModel.spaces.firstIndex(where: { $0.active == true })
			if currentSpaceIDX != nil && currentSpaceIDX! < self.spaceModel.spaces.count - 1 {
				self.switchSpace(self.spaceModel.spaces[currentSpaceIDX! + 1])
			}
		}
		notify_register_dispatch("LastSpace", &token, DispatchQueue.global(qos: .userInteractive)) { _ in
			let currentSpaceIDX = self.spaceModel.spaces.firstIndex(where: { $0.active == true })
			if currentSpaceIDX != nil && currentSpaceIDX! > 0 {
				self.switchSpace(self.spaceModel.spaces[currentSpaceIDX! - 1])
			}
		}
	}
	
	func initializeMenuItem() {
		for subView in statusBarItem?.button?.subviews ?? [] {
			subView.removeFromSuperview()
		}
		let view = NSHostingView(rootView: ContentView()
			.environmentObject(self)
			.environmentObject(spaceModel)
		)
		view.setFrameSize(NSSize(width: 0, height: statusBarHeight))
		statusBarItem?.button?.addSubview(view)
		
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
		statusBarItem?.menu = statusBarMenu
		
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
		
		initializeMenuItem()
		registerObservers()
	}
}
