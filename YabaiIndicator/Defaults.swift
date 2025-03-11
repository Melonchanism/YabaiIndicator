//
//  Defaults.swift
//  YabaiIndicator
//
//  Created by Joshua Chan on 3/9/25.
//

import Defaults

extension Defaults.Keys {
	static let showDisplaySeparator = Key("showDisplaySeparator", default: true)
	static let showCurrentSpaceOnly = Key("showCurrentSpaceOnly", default: false)
	static let buttonStyle = Key<ButtonStyle>("buttonStyle", default: .numeric)
	static let spaceSwitchModifier = Key<[UInt64]>("spaceSwitchModifier", default: [CGEventFlags.maskControl.rawValue])
	static let spaceSwitchShiftModifier = Key<[UInt64]>("spaceSwitchModifier", default: [CGEventFlags.maskShift.rawValue])
}
