//
//  Game.swift
//  Glypha
//
//  Created by C.W. Betts on 5/27/15.
//  Copyright (c) 2015 Kevin Wojniak. All rights reserved.
//

import Foundation

class Game {
	struct Key : RawOptionSetType {
		typealias RawValue = UInt
		private var value: UInt = 0
		init() {
			value = 0
		}
		init(_ value: UInt) { self.value = value }
		init(rawValue value: UInt) { self.value = value }
		init(nilLiteral: ()) { self.value = 0 }
		static var allZeros: Key { return self(0) }
		static func fromMask(raw: UInt) -> Key { return self(raw) }
		var rawValue: UInt { return self.value }
		
		static var None: Key { return Key(1 << 0) }
		static var Spacebar: Key { return Key(1 << 1) }
		static var UpArrow: Key { return Key(1 << 2) }
		static var DownArrow: Key { return Key(1 << 3) }
		static var LeftArrow: Key { return Key(1 << 4) }
		static var RightArrow: Key { return Key(1 << 5) }
		static var A: Key { return Key(1 << 6) }
		static var S: Key { return Key(1 << 7) }
		static var Colon: Key { return Key(1 << 8) }
		static var Quote: Key { return Key(1 << 9) }
		static var PageUp: Key { return Key(1 << 10) }
		static var PageDown: Key { return Key(1 << 11) }
	}
	
	enum Event {
		case Started
		case Ended
	}
	
	func handleKeyUpEvent(theKey: Key) {
	
	}
	
	func handleKeyDownEvent(theKey: Key) {
		
	}
}
