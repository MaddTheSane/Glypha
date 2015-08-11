//
//  Sounds.swift
//  Glypha
//
//  Created by C.W. Betts on 5/27/15.
//  Copyright (c) 2015 Kevin Wojniak. All rights reserved.
//

import Foundation
import AVFoundation

final class Sounds {
	private var sounds: [[AVAudioPlayer]]
	enum SoundID: Int {
		case Bird = 0
		case Bonus
		case Boom1
		case Boom2
		case Splash
		case Flap1
		case Grate
		case Lightning
		case Music
		case Screech
		case Spawn
		case Walk
		case Flap2
		case Scrape2
		
		var preloadCount: Int {
			switch (self) {
			case .Bonus, .Flap1, .Grate, .Lightning, .Spawn, .Walk:
				return 3;
			case .Flap2, .Scrape2, .Screech:
				return 8;
			default:
				return 1;
			}
		}
	}
	
	static let kMaxSounds = 14
	
	init() {
		sounds = [[AVAudioPlayer]]()
		
		for _ in 0 ..< Sounds.kMaxSounds {
			sounds.append([AVAudioPlayer]())
		}
		
		load(.Bird, data: GlyphaDataForResource(.Bird))
		load(.Bonus, data: GlyphaDataForResource(.Bonus));
		load(.Boom1, data: GlyphaDataForResource(.Boom1));
		load(.Boom2, data: GlyphaDataForResource(.Boom2));
		load(.Splash, data: GlyphaDataForResource(.Splash));
		load(.Flap1, data: GlyphaDataForResource(.Flap));
		load(.Flap2, data: GlyphaDataForResource(.Flap2));
		load(.Grate, data: GlyphaDataForResource(.Grate));
		load(.Lightning, data: GlyphaDataForResource(.Lightning));
		load(.Music, data: GlyphaDataForResource(.Music));
		load(.Screech, data: GlyphaDataForResource(.Screech));
		load(.Spawn, data: GlyphaDataForResource(.Spawn));
		load(.Walk, data: GlyphaDataForResource(.Walk));
		load(.Scrape2, data: GlyphaDataForResource(.Scrape2));
	}
	
	func load(which: SoundID, data: NSData) {
		let count = which.preloadCount
		for _ in 0 ..< count {
			let player: AVAudioPlayer?
			do {
				player = try AVAudioPlayer(data: data)
			} catch _ {
				player = nil
			}
			if let player = player {
				player.prepareToPlay()
				
				sounds[which.rawValue].append(player)
			}
		}
	}

	func play(which: SoundID) {
		var found = false
		let anArray = sounds[which.rawValue]
		for player in anArray {
			if !player.playing {
				player.play()
				found = true
				break;
			}
		}
		
		if !found {
			print("Preloaded sound not available for \(which), \(which.rawValue)")
			if let audioData = anArray.first!.data {
				let player: AVAudioPlayer!
				do {
					player = try AVAudioPlayer(data: audioData)
				} catch _ {
					player = nil
				}
				sounds[which.rawValue].append(player)
				player.play()
			} else if let urlPath = anArray.first!.url {
				let player: AVAudioPlayer!
				do {
					player = try AVAudioPlayer(contentsOfURL: urlPath)
				} catch _ {
					player = nil
				}
				sounds[which.rawValue].append(player)
				player.play()
			}
		}
	}
}
