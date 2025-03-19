//
//  ContentView.swift
//  YabaiIndicator
//
//  Created by Max Zhao on 26/12/2021.
//

import SwiftUI
import Carbon.HIToolbox
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
				Button(action: {
					switchSpace(space)
				}) {
					if space.type == .divider {
						Divider().background(Color(.systemGray)).frame(height: 14)
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
								if buttonStyle == .numeric {
									Text("\(space.index)")
										.blendMode(space.active || space.visible ? .destinationOut : .destinationOver)
								} else {
									Image(nsImage: generateImage(windows: spaceModel.windows.filter { $0.spaceIndex == space.yabaiIndex }, display: spaceModel.displays[space.display-1]))
										.resizable()
										.frame(width:16, height: 11)
										.blendMode(space.active || space.visible ? .destinationOut : .destinationOver)
								}
							} else {
								Text("F")
									.blendMode(space.active || space.visible ? .destinationOut : .destinationOver)
							}
						}
						.frame(width:20, height: 15)
						.padding(.top, -1)
					}
				}
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
					gYabaiClient.yabaiSocketCall("-m", "window", "--focus", "\(spaceModel.windows.first { $0.spaceIndex == space.yabaiIndex }!.id)")
				} else {
					print("How did you even manage to click the divider")
				}
			}
		}
	}

}
