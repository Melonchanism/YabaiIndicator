//
//  YabaiAppDelegate.swift
//  YabaiIndicator
//
//  Created by Max Zhao on 26/12/2021.
//

import SwiftUI
import Socket
import Combine
import Defaults


class YabaiIndicatorAppDelegate: NSObject, NSApplicationDelegate, ObservableObject {
	@Environment(\.openSettings) var openSettings
	
	var statusBarItem: NSStatusItem?
	@Published var spaceModel = SpaceModel()
	
	let statusBarHeight = 22
	let itemWidth: CGFloat = 30
	var receiverQueue = DispatchQueue(label: "yabai-indicator.socket.receiver")
	
	@objc func onSpaceChanged(_ notification: Notification) {
		onSpaceRefresh()
	}
	
	@objc func onDisplayChanged(_ notification: Notification) {
		onSpaceRefresh()
	}
	
	func refreshData() {
		// NSLog("Refreshing")
		receiverQueue.async {
			self.onSpaceRefresh()
			self.onWindowRefresh()
		}
	}
	
	func onSpaceRefresh() {
		let displays = gNativeClient.queryDisplays()
		let spaceElems = gNativeClient.querySpaces()
		
		DispatchQueue.main.async {
			self.spaceModel.displays = displays
			self.spaceModel.spaces = spaceElems
		}
	}
	
	func onWindowRefresh() {
		if Defaults[.buttonStyle] == .windows {
			let windows = gYabaiClient.queryWindows()
			DispatchQueue.main.async {
				self.spaceModel.windows = windows
			}
		}
	}
	
	func socketServer() async {
		do {
			let socket = try Socket.create(family: .unix, type: .stream, proto: .unix)
			try socket.listen(on: "/tmp/yabai-indicator.socket")
			while true {
				let conn = try socket.acceptClientConnection()
				let msg = try conn.readString()?.trimmingCharacters(in: .whitespacesAndNewlines)
				conn.close()
				// NSLog("Received message: \(msg!).")
				if msg == "refresh" {
					self.refreshData()
				} else if msg == "refresh spaces" {
					receiverQueue.async {
						// NSLog("Refreshing on main thread")
						self.onSpaceRefresh()
					}
				} else if msg == "refresh windows" {
					receiverQueue.async {
						// NSLog("Refreshing on main thread")
						self.onWindowRefresh()
					}
				}
			}
		} catch {
			NSLog("SocketServer Error: \(error)")
		}
		NSLog("SocketServer Ended")
	}
	
	@objc func settings() { openSettings() }
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
		NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(self.onSpaceChanged(_:)), name: NSWorkspace.activeSpaceDidChangeNotification, object: nil)
		NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(self.onDisplayChanged(_:)), name: Notification.Name("NSWorkspaceActiveDisplayDidChangeNotification"), object: nil)
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
		refreshData()
	}
	
	func applicationDidFinishLaunching(_ notification: Notification) {
		if let prefs = Bundle.main.path(forResource: "defaults", ofType: "plist"),
			 let dict = NSDictionary(contentsOfFile: prefs) as? [String : Any] {
			UserDefaults.standard.register(defaults: dict)
		}
		
		
		let options: NSDictionary = [(kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String): true]
		AXIsProcessTrustedWithOptions(options)
		
		Task {
			await self.socketServer()
		}
		statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
		
		statusBarItem?.menu = createMenu()
		
		refreshButtonStyle()
		registerObservers()
	}
}
