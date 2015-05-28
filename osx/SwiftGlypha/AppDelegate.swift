//
//  AppDelegate.swift
//  SwiftGlypha
//
//  Created by C.W. Betts on 5/27/15.
//  Copyright (c) 2015 Kevin Wojniak. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
	@IBOutlet weak var window: NSWindow!
	@IBOutlet weak var gameView: GameView!
	private var game: Game! = nil

	func applicationDidFinishLaunching(aNotification: NSNotification) {
		// Insert code here to initialize your application
		 game = Game()
	}

	func applicationWillTerminate(aNotification: NSNotification) {
		// Insert code here to tear down your application
	}

	@IBAction func newGame(sender: AnyObject?) {
		
	}
	
	@IBAction func endGame(sender: AnyObject?) {
		
	}

	@IBAction func showHelp(sender: AnyObject?) {
		
	}

}

