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

protocol GameDelegate: class {
	func handleGameEvent(Game.Event)
	func requestName(callBack: (String?) -> ())
}

class Game {
	struct Key : OptionSetType, NilLiteralConvertible {
		typealias RawValue = UInt
		private var value: UInt = 0
		init() {
			value = 0
		}
		private init(_ value: UInt) { self.value = value }
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
	weak var delegate: GameDelegate?
	
	private let bgImg = Image()
	private let torchesImg = Image()
	private let platformImg = Image()
	private let helpImg = Image()
	private let playerImg = Image()
	private let playerIdleImg = Image()
	private let numbersImg = Image()
	
	private var platformRects = [Rect](count: 6, repeatedValue: Rect())
	private var touchDownRects = [Rect](count: 6, repeatedValue: Rect())
	private var enemyRects = [Rect](count: 24, repeatedValue: Rect())
	private var playerRects = [Rect](count: 11, repeatedValue: Rect())
	private var platformCopyRects = [Rect](count: 9, repeatedValue: Rect())
	
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
	
	private final class Owl: FlyingEnemy {
		let maxHorizVelocity: Int32 = 96
		let maxVertVelocity: Int32 = 320
		let heightSmell: Int32 = 96
		let flapImpulse: Int32 = 32
	}
	
	private final class Parrot: FlyingEnemy {
		let maxHorizVelocity: Int32 = 128
		let maxVertVelocity: Int32 = 400
		let heightSmell: Int32 = 160
		let flapImpulse: Int32 = 48
	}
	
	private final class Jackal: FlyingEnemy {
		let maxHorizVelocity: Int32 = 192
		let maxVertVelocity: Int32 = 512
		let heightSmell: Int32 = 240
		let flapImpulse: Int32 = 72
	}
	
	init() {
		playerRects[0].size = (48, 37)
		playerRects[0].offsetBy(horizontal: 0, vertical: 0)
		playerRects[1].size = (48, 37);
		playerRects[1].offsetBy(horizontal: 0, vertical: 37);
		playerRects[2].size = (48, 37);
		playerRects[2].offsetBy(horizontal: 0, vertical: 74);
		playerRects[3].size = (48, 37);
		playerRects[3].offsetBy(horizontal: 0, vertical: 111);
		playerRects[4].size = (48, 48);
		playerRects[4].offsetBy(horizontal: 0, vertical: 148);
		playerRects[5].size = (48, 48);
		playerRects[5].offsetBy(horizontal: 0, vertical: 196);
		playerRects[6].size = (48, 48);
		playerRects[6].offsetBy(horizontal: 0, vertical: 244);
		playerRects[7].size = (48, 48);
		playerRects[7].offsetBy(horizontal: 0, vertical: 292);
		playerRects[8].size = (48, 37);		// falling bones rt.
		playerRects[8].offsetBy(horizontal: 0, vertical: 340);
		playerRects[9].size = (48, 37);		// falling bones lf.
		playerRects[9].offsetBy(horizontal: 0, vertical: 377);
		playerRects[10].size = (48, 22);	// pile of bones
		playerRects[10].offsetBy(horizontal: 0, vertical: 414);
		
		platformRects[0] = Rect(left: 206, top: 424, right: 433, bottom: 438)	//_______________
		platformRects[1] = Rect(left: -256, top: 284, right: 149, bottom: 298)	//
		platformRects[2] = Rect(left: 490, top: 284, right: 896, bottom: 298)	//--3--     --4--
		platformRects[3] = Rect(left: -256, top: 105, right: 149, bottom: 119)	//     --5--
		platformRects[4] = Rect(left: 490, top: 105, right: 896, bottom: 119)	//--1--     --2--
		platformRects[5] = Rect(left: 233, top: 190, right: 407, bottom: 204)	//_____--0--_____
		
		for i in 0..<6 {
			platformCopyRects[i].size = (191, 32)
			platformCopyRects[i].offsetBy(horizontal: 0, vertical: 32 * Int32(i))
		}
		platformCopyRects[6] = Rect(left: 233, top: 190, right: 424, bottom: 222)
		platformCopyRects[7] = Rect(left: 0, top: 105, right: 191, bottom: 137)
		platformCopyRects[8] = Rect(left: 449, top: 105, right: 640, bottom: 137)

		
		for i in 0..<6 {
			touchDownRects[i] = platformRects[i]
			touchDownRects[i].left += 23
			touchDownRects[i].right -= 23
			touchDownRects[i].bottom = touchDownRects[i].top
			touchDownRects[i].top = touchDownRects[i].bottom - 11
		}
	}
	
	private func loadImages() {
		bgImg.load(GlyphaDataForResource(.Background))
		torchesImg.load(GlyphaDataForResource(.Torches))
		platformImg.load(GlyphaDataForResource(.Platforms))
		playerImg.load(GlyphaDataForResource(.Player))
		playerIdleImg.load(GlyphaDataForResource(.PlayerIdle))
		numbersImg.load(GlyphaDataForResource(.Numbers))
		helpImg.load(GlyphaDataForResource(.Help))
	}
	
	func run() {
		if !bgImg.loaded {
			loadImages()
		}
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
