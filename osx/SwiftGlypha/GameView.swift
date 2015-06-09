//
//  GameView.swift
//  Glypha
//
//  Created by C.W. Betts on 5/27/15.
//  Copyright (c) 2015 Kevin Wojniak. All rights reserved.
//

import Cocoa
import CoreVideo

class GameView: NSOpenGLView {
	private var displayLink: CVDisplayLink!
	weak var game: Game!
	
	override func drawRect(dirtyRect: NSRect) {
		render()
	}
	
	override func prepareOpenGL() {
		// Synchronize buffer swaps with vertical refresh rate
		var swapInt: GLint = 1
		openGLContext?.setValues(&swapInt, forParameter: .GLCPSwapInterval)
		
		// Create a display link capable of being used with all active displays
		var displayLink: CVDisplayLink? = nil
		CVDisplayLinkCreateWithActiveCGDisplays(&displayLink)
		if let displayLink = displayLink {
		// Set the renderer output callback function
		//CVDisplayLinkSetOutputCallback(displayLink, callback, unsafeBitCast(self, UnsafeMutablePointer<Void>.self));
		//CV_EXPORT CVReturn CVDisplayLinkSetOutputHandler( CVDisplayLinkRef CV_NONNULL displayLink, CVDisplayLinkOutputHandler CV_NONNULL handler );
		CVDisplayLinkSetOutputHandler(displayLink) { (_, _, _, _, _) -> CVReturn in
			self.render()
			return kCVReturnSuccess;
		}
		
		// Set the display link for the current renderer
		let cglContext = openGLContext!.CGLContextObj
		let cglPixelFormat: COpaquePointer = pixelFormat?.CGLPixelFormatObj ?? nil
		CVDisplayLinkSetCurrentCGDisplayFromOpenGLContext(displayLink, cglContext, cglPixelFormat);

		// Activate the display link
		CVDisplayLinkStart(displayLink)
		}
	}
	
	func render() {
		if let game = game, ctx = openGLContext {
			ctx.makeCurrentContext()
			CGLLockContext(ctx.CGLContextObj)
			game.run()
			ctx.flushBuffer()
			CGLUnlockContext(ctx.CGLContextObj)
		}
	}

	override var canBecomeKeyView: Bool {
		return true
	}
	
	private func doKey(event: NSEvent, up: Bool) {
		let chars = event.characters! as NSString
		for i in 0..<chars.length {
			let ch = chars.characterAtIndex(i)
			var key = Game.Key()
			switch ch {
				
			case 0x20:
				key = .Spacebar
				
			case unichar(NSUpArrowFunctionKey):
				key = .UpArrow
				
			case unichar(NSDownArrowFunctionKey):
				key = .DownArrow
				
			case unichar(NSLeftArrowFunctionKey):
				key = .LeftArrow

			case unichar(NSRightArrowFunctionKey):
				key = .RightArrow

			case 0x61:
				key = .A
				
			case 0x73:
				key = .S
				
			case 0x3B, 0x3A:
				key = .Colon
				
			case 0x22, 0x27:
				key = .Quote
				
			case unichar(NSPageUpFunctionKey):
				key = .PageUp
				
			case unichar(NSPageDownFunctionKey):
				key = .PageDown

			default:
				key = .None
			}
			if up {
				game.handleKeyUpEvent(key)
			} else {
				game.handleKeyDownEvent(key)
			}
		}
	}
	
	override func keyDown(theEvent: NSEvent) {
		doKey(theEvent, up: false)
	}
	
	override func keyUp(theEvent: NSEvent) {
		doKey(theEvent, up: true)
	}
	
	override var acceptsFirstResponder: Bool {
		return true
	}
}
