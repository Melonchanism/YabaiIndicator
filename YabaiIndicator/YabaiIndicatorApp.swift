//
//  YabaiIndicatorApp.swift
//  YabaiIndicator
//
//  Created by Max Zhao on 26/12/2021.
//

import SwiftUI

@main struct YabaiIndicatorApp: App {
	@NSApplicationDelegateAdaptor(YabaiIndicatorAppDelegate.self) var delegate
	
	var body: some Scene {
		Settings {
			SettingsView()
		}
	}
}
