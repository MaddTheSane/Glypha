//
//  Game.swift
//  Glypha
//
//  Created by C.W. Betts on 5/27/15.
//  Copyright (c) 2015 Kevin Wojniak. All rights reserved.
//

import Foundation

private var numOwls: Int32 = 1

private let kNumLightningPts: Int32 = 8
private let kMaxEnemies: Int32 = 8


protocol FlyingEnemy {
	var maxHorizVelocity: Int32 {get}
	var maxVertVelocity: Int32 {get}
	var heightSmell: Int32 {get}
	var flapImpulse: Int32 {get}
}

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
	
	private enum Mode: Int16 {
		/// enemy & player mode
		case Idle = -1
		
		/// enemy & player mode
		case Flying
		
		/// enemy & player mode
		case Walking
		
		/// player mode
		case Sinking
		
		/// enemy mode
		case Spawning
		
		/// enemy mode & player mode
		case Falling
		
		/// enemy mode
		case EggTimer
		
		/// enemy mode
		case DeadAndGone
		
		/// player mode
		case Bones
		
		/// hand mode
		case Lurking = 10
		
		/// hand mode
		case OutGrabeth
		
		/// hand mode
		case Clutching
		
		/// eye mode
		case Waiting = 15
		
		/// eye mode
		case Stalking
	};

	private enum HelpState {
		case Closed
		case Opening
		case Open
	}
	
	private var keys = Key.None
	private var helpState = HelpState.Closed
	var renderer = Renderer()
	private var lock = Lock()
	private let sounds = Sounds()
	
	//var eyeImg = Image()
	private final class Eye {
		var destination = Rect()
		var mode = Mode.Idle
		var opening: Int32 = 0
		var srcNum: Int32 = 0
		var frame: Int32 = 0
		var killed = false
		var entering = false
		var eyeImg = Image()
		var rects = [Rect](count: 4, repeatedValue: Rect())
		init() {
			eyeImg.load(GlyphaDataForResource(.Eye))
			for i in 0..<4 {
				rects[i] = Rect(left: 0, top: 0, right: 48, bottom: 31);
				rects[i].offsetBy(horizontal: 0, vertical: Int32(i) * 31);
			}
		}
		
		func start() {
			destination = Rect(left: 0, top: 0, right: 48, bottom: 31);
			destination.offsetBy(horizontal: 296, vertical: 97);
			mode = .Waiting;
			frame = (numOwls + 2) * 720;
			srcNum = 0;
			opening = 1;
			killed = false;
			entering = false;
		}
		
		func kill() {
			
		}
		
		func handle() {
			
		}
		
		func draw() {
			
		}
	}
	
		/*
#define kOwlMaxHVel				96
#define kOwlMaxVVel				320
#define kOwlHeightSmell			96
#define kOwlFlapImpulse			32

#define kWolfMaxHVel			128
#define kWolfMaxVVel			400
#define kWolfHeightSmell		160
#define kWolfFlapImpulse		48

#define kJackalMaxHVel			192
#define kJackalMaxVVel			512
#define kJackalHeightSmell		240
#define kJackalFlapImpulse		72
*/
	
	func run() {
		
	}

	func newGame() {
		
	}
	
	func endGame() {
		
	}
	
	func showHelp() {
		
	}
	
	func handleKeyUpEvent(theKey: Key) {

	}

	func handleKeyDownEvent(theKey: Key) {
		
	}
}
