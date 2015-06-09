//
//  AppDelegate.swift
//  SwiftGlypha
//
//  Created by C.W. Betts on 5/27/15.
//  Copyright (c) 2015 Kevin Wojniak. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, GameDelegate {
	@IBOutlet weak var window: NSWindow!
	@IBOutlet weak var gameView: GameView!
	@IBOutlet weak var newGame: NSMenuItem!
	@IBOutlet weak var endGame: NSMenuItem!
	@IBOutlet weak var helpMenuItem: NSMenuItem!

	private let game: Game = Game()

	func applicationDidFinishLaunching(aNotification: NSNotification) {
		// Insert code here to initialize your application
		game.delegate = self
	}

	func applicationWillTerminate(aNotification: NSNotification) {
		// Insert code here to tear down your application
	}

	@IBAction func newGame(sender: AnyObject?) {
		game.newGame()
	}
	
	@IBAction func endGame(sender: AnyObject?) {
		game.endGame()
	}

	@IBAction func showHelp(sender: AnyObject?) {
		game.showHelp()
	}
	
	func handleGameEvent(event: Game.Event) {
		switch event {
		case .Started:
			newGame.enabled = false
			endGame.enabled = true
			helpMenuItem.enabled = false
			
		case .Ended:
			newGame.enabled = true
			endGame.enabled = false
			helpMenuItem.enabled = true
		}
	}
	
	func requestName(callBack: (String?) -> ()) {
		let alert = NSAlert()
		alert.addButtonWithTitle("OK")
		alert.addButtonWithTitle("Cancel")
		alert.messageText = "New high score!"
		alert.informativeText = "Please enter your name"
		let input = NSTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 24))
		input.stringValue = NSFullUserName()
		alert.accessoryView = input
		
		alert.beginSheetModalForWindow(window) { (retVal) -> Void in
			switch retVal {
			case NSAlertFirstButtonReturn:
				let inputStr = input.stringValue
				if inputStr.characters.count == 0 {
					NSBeep()
				} else {
					callBack(inputStr)
					return
				}
				
			default:
				break
			}
			callBack(nil)
		}
	}
}

