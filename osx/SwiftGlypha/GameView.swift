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
	
	@objc private class func displayLinkCallback(CVDisplayLink!, UnsafePointer<CVTimeStamp>, UnsafePointer<CVTimeStamp>, CVOptionFlags, UnsafeMutablePointer<CVOptionFlags>, displayLinkContext: UnsafeMutablePointer<Void>) -> CVReturn {
		unsafeBitCast(displayLinkContext, GameView.self).render()
		return kCVReturnSuccess.value;

	}
	
	override func prepareOpenGL() {
		let ohai = CVDisplayLinkSetOutputCallback
		
		//hacky-hacky!
		let myImp = imp_implementationWithBlock(unsafeBitCast(GameView.displayLinkCallback, AnyObject.self))
		let callback = unsafeBitCast(myImp, CVDisplayLinkOutputCallback.self)
		
		// Synchronize buffer swaps with vertical refresh rate
		var swapInt: GLint = 1
		openGLContext.setValues(&swapInt, forParameter: .GLCPSwapInterval)
		
		// Create a display link capable of being used with all active displays
		var aWake: Unmanaged<CVDisplayLink>? = nil
		CVDisplayLinkCreateWithActiveCGDisplays(&aWake)
		displayLink = aWake?.takeRetainedValue()
		
		// Set the renderer output callback function
		CVDisplayLinkSetOutputCallback(displayLink, callback, unsafeBitCast(self, UnsafeMutablePointer<Void>.self));

		// Set the display link for the current renderer
		let cglContext = openGLContext.CGLContextObj
		let cglPixelFormat: COpaquePointer = pixelFormat?.CGLPixelFormatObj ?? nil
		CVDisplayLinkSetCurrentCGDisplayFromOpenGLContext(displayLink, cglContext, cglPixelFormat);

		// Activate the display link
		CVDisplayLinkStart(displayLink);

	}
	
	func render() {
		
	}
	
	override var canBecomeKeyView: Bool {
		return true
	}
	
	func doKey(event: NSEvent, up: Bool) {
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
		}
		
	}
	
	/*
- (void)doKey:(NSEvent *)event up:(BOOL)up
{
NSString *chars = [event characters];
for (NSUInteger i = 0; i < [chars length]; ++i) {
unichar ch = [chars characterAtIndex:i];
GL::Game::Key key;
switch (ch) {
case ' ':
key = GL::Game::KeySpacebar;
break;
case NSUpArrowFunctionKey:
key = GL::Game::KeyUpArrow;
break;
case NSDownArrowFunctionKey:
key = GL::Game::KeyDownArrow;
break;
case NSLeftArrowFunctionKey:
key = GL::Game::KeyLeftArrow;
break;
case NSRightArrowFunctionKey:
key = GL::Game::KeyRightArrow;
break;
case 'a':
key = GL::Game::KeyA;
break;
case 's':
key = GL::Game::KeyS;
break;
case ';':
key = GL::Game::KeyColon;
break;
case '"':
key = GL::Game::KeyQuote;
break;
case NSPageUpFunctionKey:
key = GL::Game::KeyPageUp;
break;
case NSPageDownFunctionKey:
key = GL::Game::KeyPageDown;
break;
default:
key = GL::Game::KeyNone;
break;
}
if (up) {
_game->handleKeyUpEvent(key);
} else {
_game->handleKeyDownEvent(key);
}
}
}
*/
}
