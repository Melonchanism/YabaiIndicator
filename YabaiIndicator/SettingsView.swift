//
//  SettingsView.swift
//  YabaiIndicator
//
//  Created by Max Zhao on 1/1/22.
//

import SwiftUI
import Defaults

struct SettingsView : View {
	@Default(.showDisplaySeparator) var showDisplaySeparator
	@Default(.showCurrentSpaceOnly) var showCurrentSpaceOnly
	@Default(.buttonStyle) var buttonStyle
	
	private enum Tabs: Hashable {
		case general, advanced
	}
	
	var body: some View {
		TabView {
			Form {
				Toggle("Show Display Separator", isOn: $showDisplaySeparator)
				Toggle("Show Current Space Only", isOn: $showCurrentSpaceOnly)
				Picker("Button Style", selection: $buttonStyle) {
					Text("Numeric").tag(ButtonStyle.numeric)
					Text("Windows").tag(ButtonStyle.windows)
				}
			}.padding(10)
				.tabItem {
					Label("General", systemImage: "gear")
				}
				.tag(Tabs.general)
			
		}
		.frame(width: 375, height: 120)
	}
}
