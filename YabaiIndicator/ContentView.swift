//
//  ContentView.swift
//  YabaiIndicator
//
//  Created by Max Zhao on 26/12/2021.
//

import SwiftUI
import Defaults

struct ContentView: View {
	@EnvironmentObject var appDelegate: YabaiIndicatorAppDelegate
	@EnvironmentObject var spaceModel: SpaceModel
	@Default(.showDisplaySeparator) var showDisplaySeparator
	@Default(.showCurrentSpaceOnly) var showCurrentSpaceOnly
	@Default(.buttonStyle) var buttonStyle
	
	private func generateSpaces() -> [Space] {
		var shownSpaces:[Space] = []
		var lastDisplay = 0
		for space in spaceModel.spaces {
			if lastDisplay > 0 && space.display != lastDisplay {
				if showDisplaySeparator {
					shownSpaces.append(Space(spaceid: 0, id: "", visible: true, active: false, display: 0, index: 0, yabaiIndex: 0, type: .divider))
				}
			}
			if space.visible || !showCurrentSpaceOnly{
				shownSpaces.append(space)
			}
			lastDisplay = space.display
		}
		return shownSpaces
	}
	
	var body: some View {
		HStack (spacing: 4) {
			ForEach(generateSpaces()) { space in
				Group {
					if space.type == .divider {
						Divider().background(.secondary).frame(height: 14)
					} else {
						ZStack {
							if #available(macOS 14, *) {
								RoundedRectangle(cornerRadius: 3)
									.fill(space.active ? Color.primary : space.visible ? Color.secondary : .clear)
									.strokeBorder(Color.primary, lineWidth: 1)
							} else {
								(space.active ? Color.primary : space.visible ? Color.secondary : Color.clear)
									.border(.primary)
									.cornerRadius(3)
							}
							if space.type != .fullscreen {
								// Use spaces around text to fix hitbox
								if buttonStyle == .numeric {
									Text(" \(space.index) ")
										.blendMode(space.active || space.visible ? .destinationOut : .destinationOver)
								} else {
									Image(nsImage: generateImage(windows: spaceModel.windows.filter { $0.spaceIndex == space.yabaiIndex }, display: spaceModel.displays[space.display-1]))
										.resizable()
										.frame(width:16, height: 11)
										.blendMode(space.active || space.visible ? .destinationOut : .destinationOver)
								}
							} else {
								Text(" F ")
									.blendMode(space.active || space.visible ? .destinationOut : .destinationOver)
							}
						}
						.frame(width:20, height: 15)
						.padding(.top, -1)
					}
				}
				.onTapGesture { appDelegate.switchSpace(space) }
				.buttonStyle(.borderless)
			}
		}
		.overlay {
			GeometryReader { geometry in
				EmptyView()
					.frame(maxWidth: .infinity)
					.onChange(of: generateSpaces()) { _ in
						appDelegate.statusBarItem?.button?.frame.size.width = geometry.size.width + 20
						appDelegate.statusBarItem?.button?.subviews[0].frame.size.width = geometry.size.width + 20
					}
			}
		}
	}
}
