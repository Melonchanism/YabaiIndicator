//
//  ContentView.swift
//  YabaiIndicator
//
//  Created by Max Zhao on 26/12/2021.
//

import SwiftUI
import Carbon.HIToolbox
import Defaults

struct WindowSpaceButton : View {
	var space: Space
	var windows: [Window]
	var displays: [Display]
	
	var body : some View {
		switch space.type {
			case .standard:
				Image(nsImage: generateImage(active: space.active, visible: space.visible, windows: windows, display: displays[space.display-1])).onTapGesture {
					switchSpace(space)
				}.frame(width:20, height: 16)
			case .fullscreen:
				Image(nsImage: generateImage(symbol: "F" as NSString, active: space.active, visible: space.visible)).onTapGesture {
					switchSpace(space)
				}
			case .divider:
				Divider().background(Color(.systemGray)).frame(height: 14)
		}
	}
}

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
				if space.type == .divider {
					Divider().background(Color(.systemGray)).frame(height: 14)
				} else {
					ZStack {
						RoundedRectangle(cornerRadius: 3)
							.fill(space.active ? Color.primary : space.visible ? Color.secondary : .clear)
							.stroke(.primary)
						Text("\(space.index != 0 ? String(space.index) : "F")")
							.blendMode(space.active || space.visible ? .destinationOut : .destinationOver)
					}
					.frame(width:20, height: 16)
					.onTapGesture { switchSpace(space) }
				}
//					WindowSpaceButton(space: space, windows: spaceModel.windows.filter{$0.spaceIndex == space.yabaiIndex}, displays: spaceModel.displays)
			}
		}
		.overlay {
			GeometryReader { geometry in
				EmptyView()
					.frame(maxWidth: .infinity)
					.onChange(of: generateSpaces()) {
						appDelegate.statusBarItem?.button?.frame.size.width = geometry.size.width + 20
						appDelegate.statusBarItem?.button?.subviews[0].frame.size.width = geometry.size.width + 20
					}
			}
		}
	}
}

func switchSpace(_ space: Space) {
	if !space.active && space.yabaiIndex > 0 {
		Task {
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
		}
	}
}
