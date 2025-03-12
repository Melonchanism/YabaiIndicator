//
//  ImageGenerator.swift
//  YabaiIndicator
//
//  Created by Max Zhao on 29/12/2021.
//
import Foundation
import Cocoa
import SwiftUI

func generateImage(windows: [Window], display: Display) -> NSImage {
	let aspectRatio = (display.frame.width / display.frame.height) / 1.25
	let canvasSize = NSSize(width: 20 * aspectRatio, height: 16)
	let canvas = NSRect(origin: CGPoint.zero, size: canvasSize)
	
	let image = NSImage(size: canvasSize)
	let strokeColor = NSColor.black
	
	image.lockFocus()
	strokeColor.setStroke()
	let contentOrigin = canvas.origin
	let displaySize = display.frame.size
	let displayOrigin = display.frame.origin
	
	let scaling = displaySize.height > displaySize.width ? displaySize.height / canvas.size.height : displaySize.width / canvas.size.width
	let xoffset = (displaySize.height > displaySize.width ? (canvasSize.width - displaySize.width / scaling) / 2 : 0) + contentOrigin.x
	let yoffset = (displaySize.height > displaySize.width ? 0 : (canvas.size.height - displaySize.height / scaling) / 2) + contentOrigin.y
	
	let scalingFactor = 1 / scaling
	let transform = NSAffineTransform()
	transform.scale(by: scalingFactor)
	transform.translateX(by: xoffset / scalingFactor, yBy: yoffset / scalingFactor)
	// plot single windows
	for window in windows.reversed() {
		let windowOrigin = window.frame.origin
		let windowSize = window.frame.size
		let windowPath = NSBezierPath(
			roundedRect: NSRect(
				origin: transform.transform(NSPoint(x: windowOrigin.x - displayOrigin.x, y: displaySize.height - (windowOrigin.y - displayOrigin.y + windowSize.height))),
				size: transform.transform(windowSize)
			),
			xRadius: 1.5,
			yRadius: 1.5
		)
		windowPath.fill()
		NSGraphicsContext.saveGraphicsState()
		NSGraphicsContext.current?.compositingOperation = .destinationOut
		windowPath.lineWidth = 1
		windowPath.stroke()
		NSGraphicsContext.restoreGraphicsState()
	}
	image.unlockFocus()
	image.isTemplate = true
	return image
}
