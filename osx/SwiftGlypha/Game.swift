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

private let kLightningDelay: Double = (1.0 / 25.0)
private let kNumLightningStrikes: Int32 = 5


protocol FlyingEnemy {
	var maxHorizVelocity: Int32 {get}
	var maxVertVelocity: Int32 {get}
	var heightSmell: Int32 {get}
	var flapImpulse: Int32 {get}
}

protocol GameDelegate: class {
	func handleGameEvent(_: Game.Event)
	func requestName(callBack: (String?) -> ())
}

class Game {
	struct Key : OptionSetType {
		typealias RawValue = UInt
		private var value: UInt = 0
		init() {
			value = 0
		}
		private init(_ value: UInt) { self.value = value }
		init(rawValue value: UInt) { self.value = value }
		var rawValue: UInt { return self.value }
		
		static let None = Key(1 << 0)
		static let Spacebar = Key(1 << 1)
		static let UpArrow = Key(1 << 2)
		static let DownArrow = Key(1 << 3)
		static let LeftArrow = Key(1 << 4)
		static let RightArrow = Key(1 << 5)
		static let A = Key(1 << 6)
		static let S = Key(1 << 7)
		static let Colon = Key(1 << 8)
		static let Quote = Key(1 << 9)
		static let PageUp = Key(1 << 10)
		static let PageDown = Key(1 << 11) 
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
	
	private class Player {
		var dest = Rect()
		var wasDest = Rect()
		var wrap = Rect()
		var h: Int32 = 0
		var v: Int32 = 0
		var wasH: Int32 = 0
		var wasV: Int32 = 0
		var hVel: Int32 = 0
		var vVel: Int32 = 0
		var srcNum = 0
		var mode = Mode.Idle
		var frame: Int32 = 0
		var facingRight = false
		var flapping = false
		var walking = false
		var wrapping = false
		var clutched = false
		weak var gameClass: Game!

		init() {
			
		}
		
		func draw() {
			
		}
	}
	private var thePlayer = Player()
	
	private let utils = Utilities()
	
	private var playing = false
	private var keys = Key.None
	private var helpPos: Int32 = 0
	private var helpState = HelpState.Closed
	var renderer = Renderer()
	private var lock = Lock()
	private let sounds = Sounds()
	weak var delegate: GameDelegate?
	private var levelOn: Int32 = 0
	private var now: Double {
		return utils.now
	}
	
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
	
	private var helpSrc = Rect()
	private var helpDest = Rect()
	private var wallSrc = Rect()
	private var wallDest = Rect()

	private let eye = Eye()
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
		weak var gameClass: Game!
		
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
			if (mode == .Stalking) {
				killed = true
				opening = 1
				entering = false
				if (srcNum == 0) {
					srcNum = 1
				}
			} else {
				reset()
			}
		}
		
		func reset() {
			destination = Rect(left: 0, top: 0, right: 48, bottom: 31)
			destination.offsetBy(horizontal: 296, vertical: 97);
			mode = .Waiting;
			frame = (numOwls + 2) * 720;
			srcNum = 0;
			opening = 1;
			killed = false;
			entering = false;
		}
		
		func handle() {
			var diffH: Int32 = 0
			var diffV: Int32 = 0
			var speed: Int32 = 0
			
			if (mode == .Stalking) {		// eye is about
				speed = (gameClass.levelOn >> 4) + 1;
				if (speed > 3) {
					speed = 3;
				}
				
				if (killed || entering) {
					speed = 0;
				} else if ((gameClass.thePlayer.mode != .Flying) && (gameClass.thePlayer.mode != .Walking)) {
					diffH = destination.left - 296;
					diffV = destination.bottom - 128;
				} else {
					diffH = destination.left - gameClass.thePlayer.dest.left;
					diffV = destination.bottom - gameClass.thePlayer.dest.bottom;
				}
				
				if (diffH > 0) {
					if (diffH < speed) {
						destination.left -= diffH;
					} else {
						destination.left -= speed;
					}
					destination.right = destination.left + 48;
				} else if (diffH < 0) {
					if (-diffH < speed) {
						destination.left -= diffH;
					} else {
						destination.left += speed;
					}
					destination.right = destination.left + 48;
				}
				if (diffV > 0) {
					if (diffV < speed) {
						destination.bottom -= diffV;
					} else {
						destination.bottom -= speed;
					}
					destination.top = destination.bottom - 31;
				} else if (diffV < 0) {
					if (-diffV < speed) {
						destination.bottom -= diffV;
					} else {
						destination.bottom += speed;
					}
					destination.top = destination.bottom - 31;
				}
				
				frame++;
				
				if (srcNum != 0) {
					if (frame > 3) {		// eye-closing frame holds for 3 frames
						frame = 0;
						srcNum += opening;
						if (srcNum > 3) {
							srcNum = 3;
							opening = -1;
							if (killed) {
								reset();
							}
						} else if (srcNum <= 0) {
							srcNum = 0;
							opening = 1;
							frame = 0;
							entering = false;
						}
					}
				} else if (frame > 256) {
					srcNum = 1;
					opening = 1;
					frame = 0;
				}
				
				diffH = destination.left - gameClass.thePlayer.dest.left;
				diffV = destination.bottom - gameClass.thePlayer.dest.bottom;
				if (diffH < 0) {
					diffH = -diffH;
				}
				if (diffV < 0) {
					diffV = -diffV;
				}
				
				if ((diffH < 16) && (diffV < 16) && (!entering) &&
					(!killed)) {			// close enough to call it a kill
						if (srcNum == 0)	{		// if eye open, player is killed
							if (gameClass.lightningCount == 0) {
								gameClass.doLightning(Point(gameClass.thePlayer.dest.left + 24, gameClass.thePlayer.dest.bottom - 24), count: 6);
							}
							gameClass.thePlayer.mode = .Falling;
							if (gameClass.thePlayer.facingRight) {
								gameClass.thePlayer.srcNum = 8;
							} else {
								gameClass.thePlayer.srcNum = 9;
							}
							gameClass.thePlayer.dest.bottom = gameClass.thePlayer.dest.top + 37;
							gameClass.sounds.play(.Boom2);
						} else { // wow, player killed the eye
							if (gameClass.lightningCount == 0) {
								gameClass.doLightning(Point(destination.left + 24, destination.top + 16), count: 15);
							}
							gameClass.addToScore(2000);
							gameClass.sounds.play(.Bonus);
							
							kill();
						}
				}
			} else if (frame > 0) {
				frame--;
				if (frame == 0) {		// eye appears
					mode = .Stalking;
					if (gameClass.lightningCount == 0) {
						gameClass.doLightning(Point(destination.left + 24, destination.top + 16), count: 6);
					}
					srcNum = 3;
					opening = 1;
					entering = true;
				}
			}
		}
		
		func draw() {
			if (mode == .Stalking) {
				eyeImg.draw(destination: destination, source: rects[Int(srcNum)]);
			}
		}
	}
	
	private var score: Int32 = 0
	private var livesLeft: Int32 = 0
	func addToScore(value: Int32) {
		let oldDigit = score / 10000
		score += value
		let newDigit = score / 10000
		livesLeft += newDigit - oldDigit
	}
	
	//MARK: Lightning
	private var newGameLightning: Int32 = 0
	private var lightningCount: Int32 = 0
	private var lightningPoint: Point = (0, 0)
	private var lastLightningStrike: Double = 0
	private var lastNewGameLightning: Double = 0
	private var leftLightningPts = [Point](count: Int(kNumLightningPts), repeatedValue: (0, 0))
	private var rightLightningPts = [Point](count: Int(kNumLightningPts), repeatedValue: (0, 0))
	
	func doLightning(point: Point, count: Int32) {
		flashObelisks = true;
		sounds.play(.Lightning);
		lightningCount = count;
		lightningPoint = point;
		generateLightning(point)
		lastLightningStrike = now;
	}
	
	private func generateLightning(pt: Point) {
		generateLightning(h: pt.h, v: pt.v)
	}
	
	private func generateLightning(h h: Int32, v: Int32) {
		let kLeftObeliskH: Int32 = 172;
		let kLeftObeliskV: Int32 = 250;
		let kRightObeliskH: Int32 = 468;
		let kRightObeliskV: Int32 = 250;
		let kWander: Int32 = 16;
		
		let leftDeltaH = h - kLeftObeliskH				// determine the h and v distances between
		let rightDeltaH = h - kRightObeliskH;			// obelisks and the target point
		let leftDeltaV = v - kLeftObeliskV;
		let rightDeltaV = v - kRightObeliskV;
		
		for i in 0..<kNumLightningPts {// calculate an even spread of points between
			// obelisk tips and the target point
			leftLightningPts[Int(i)].h = (leftDeltaH * i) / (kNumLightningPts - 1) + kLeftObeliskH;
			leftLightningPts[Int(i)].v = (leftDeltaV * i) / (kNumLightningPts - 1) + kLeftObeliskV;
			rightLightningPts[Int(i)].h = (rightDeltaH * i) / (kNumLightningPts - 1) + kRightObeliskH;
			rightLightningPts[Int(i)].v = (rightDeltaV * i) / (kNumLightningPts - 1) + kRightObeliskV;
		}
		
		let range = kWander * 2 + 1;					// randomly scatter the points vertically
		for i in 0 ..< Int(kNumLightningPts - 1) { // but NOT the 1st or last points
			leftLightningPts[i].v += utils.randomInt32(range) - kWander;
			rightLightningPts[i].v += utils.randomInt32(range) - kWander;
		}
	}
	
	private func drawLightning() {
		if (lightningCount <= 0 && newGameLightning < 0) {
			return;
		}

		let r = renderer
		r.setFillColor(red: 255, green: 255, blue: 0)
		r.beginLines(2)
		r.moveTo(h: leftLightningPts[0].h, v: leftLightningPts[0].v)
		
		for i in 0 ..< Int(kNumLightningPts - 1) {
			r.moveTo(h: leftLightningPts[i].h, v: leftLightningPts[i].v)
			r.lineTo(h: leftLightningPts[i + 1].h, v: leftLightningPts[i + 1].v)
		}
		r.moveTo(h: rightLightningPts[0].h, v: rightLightningPts[0].v);
		for i in 0 ..< Int(kNumLightningPts - 1) {
			r.moveTo(h: rightLightningPts[i].h, v: rightLightningPts[i].v);
			r.lineTo(h: rightLightningPts[i + 1].h - 1, v: rightLightningPts[i + 1].v);
		}
		r.endLines()
	}
	
	private func handleLightning() {
		if ((lightningCount > 0) && ((now - lastLightningStrike) >= kLightningDelay)) {
			generateLightning(lightningPoint);
			lastLightningStrike = now;
			--lightningCount;
		}
		if (lightningCount <= 0) {
			flashObelisks = false;
		}
		
		if (newGameLightning >= 0) {
			if ((now - lastNewGameLightning) >= kLightningDelay) {
				lastNewGameLightning = now;
				switch (newGameLightning) {
				case 6:
					generateLightning(h: 320, v: 429)	// platform 0

				case 5:
					generateLightning(h: 95, v: 289)	// platform 1
					
				case 4:
					generateLightning(h: 95, v: 110)	// platform 3
					
				case 3:
					generateLightning(h: 320, v: 195)	// platform 5
					
				case 2:
					generateLightning(h: 545, v: 110)	// platform 4
					
				case 1:
					generateLightning(h: 545, v: 289)	// platform 2

					
				default:
					break
				}
				--newGameLightning;
				if (newGameLightning == -1) {
					doLightning(Point(thePlayer.dest.left + 24, thePlayer.dest.bottom - 24), count: kNumLightningStrikes);
				}
			}
		}
	}

	private func drawBackground() {

	}

	private func drawTorches() {

	}

	//MARK: Obelisks
	private var flashObelisks = false


	private func drawObelisks() {

	}

	private func drawPlatforms() {

	}

	private func drawHand() {

	}

	private func drawEnemies() {

	}
	private func drawLivesNumbers() {

	}
	private func drawScoreNumbers() {

	}
	private func drawLevelNumbers() {

	}

	private func drawFrame() {
		let r = renderer
		r.clear()
		drawBackground()
		drawTorches()
		if playing {
			drawPlatforms();
			drawHand();
			eye.draw()
			thePlayer.draw()
			drawEnemies();
			drawObelisks();
			drawLivesNumbers();
			drawScoreNumbers();
			drawLevelNumbers();
		}
		drawHelp()
		drawObelisks();
		drawLightning();
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
		
		eye.gameClass = self
		thePlayer.gameClass = self
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

	//MARK: help handling
	func openHelp() {
		helpSrc = Rect(left: 0, top: 0, right: 231, bottom: 0)
		helpDest = helpSrc
		helpDest.offsetBy(horizontal: 204, vertical: 171)
		
		wallSrc = Rect(left: 0, top: 0, right: 231, bottom: 199)
		wallSrc.offsetBy(horizontal: 204, vertical: 171)
		wallDest = wallSrc
		
		helpPos = 0
		helpState = .Opening
	}
	
	private func handleHelp() {
		if helpState == .Opening && helpPos >= 199 {
			helpState = .Open
			return
		}
		
		if helpState == .Opening {
			let offsetBy: Int32 = 3
			helpSrc.bottom += offsetBy;
			helpDest.bottom += offsetBy;
			wallSrc.bottom -= offsetBy;
			wallDest.top += offsetBy;
			helpPos += offsetBy;

			if (helpPos > 199) {
				helpSrc.bottom = 199;
				wallSrc.bottom = 171;
				helpDest.bottom = 370
				wallDest.top = 370;
			}
		}
	}
	
	private func drawHelp() {
		if (helpState != .Closed) {
			helpImg.draw(destination: helpDest, source: helpSrc);
			bgImg.draw(destination: wallDest, source: wallSrc);
		}
	}
	
	func showHelp() {
		if !playing {
			openHelp();
		}
	}

	func scrollHelp(scrollDown: Int32) {
		helpSrc.offsetBy(horizontal: 0, vertical: scrollDown);
		
		if (helpSrc.bottom > 398) {
			helpSrc.bottom = 398;
			helpSrc.top = helpSrc.bottom - 199;
		} else if (helpSrc.top < 0) {
			helpSrc.top = 0;
			helpSrc.bottom = helpSrc.top + 199;
		}
	}
	
	func newGame() {
		
	}
	
	func endGame() {
		
	}
	
	func handleKeyUpEvent(theKey: Key) {
		lockWithin(lock, block: { () -> () in
			self.keys.remove(theKey)
		})
	}

	func handleKeyDownEvent(theKey: Key) {
		lockWithin(lock, block: { [unowned self] () -> ()  in
			self.keys.insert(theKey)
			
			if self.helpState == .Open {
				if theKey == .UpArrow {
					self.scrollHelp(-3);
				} else if theKey == .DownArrow {
					self.scrollHelp(3);
				} else if theKey == .PageDown {
					self.scrollHelp(199);
				} else if theKey == .PageUp {
					self.scrollHelp(-199);
				}
			}
			
			return
		})
	}
}
