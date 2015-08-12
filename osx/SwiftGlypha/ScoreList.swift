//
//  ScoreList.swift
//  Glypha
//
//  Created by C.W. Betts on 6/9/15.
//  Copyright © 2015 Kevin Wojniak. All rights reserved.
//

import Foundation

private let kScoresKey = "scores"
private let kScoreNameKey = "name"
private let kScoreScoreKey = "score"
private let kScoreLevelKey = "level"


func >(lhs: ScoreList.Score, rhs: ScoreList.Score) -> Bool {
	return lhs.score > rhs.score
}

func <(lhs: ScoreList.Score, rhs: ScoreList.Score) -> Bool {
	return lhs.score < rhs.score
}

func ==(lhs: ScoreList.Score, rhs: ScoreList.Score) -> Bool {
	return lhs.score == rhs.score
}

final class ScoreList {
	struct Score: Comparable {
		var name: String
		var score: Int32 = 0
		var level: Int32 = 0
		
		init() {
			name = ""
		}
		
		init(name: String, score: Int32, level: Int32) {
			self.name = name
			self.score = score
			self.level = level
		}
	}
	
	private var scores = [Score]()
	
	init() {
		for i in 0..<Int32(10) {
			scores.append(Score(name: "Anonymous", score: i * 100, level: i))
		}
		scores.sortInPlace(>)
	}
	
	func highScore(score: Int32) -> Bool {
		let lastScore = scores.last!
		return score > lastScore.score
	}
	
	subscript(idx: Int) -> Score {
		return scores[idx]
	}
	
	func addScore(newScore: Score) {
		scores.append(newScore)
		scores.sortInPlace(>)
		scores.removeLast()
	}
	
	func loadScores() -> Bool {
		let defaults = NSUserDefaults.standardUserDefaults()
		if let scoreArray = defaults.arrayForKey(kScoresKey) as? [[String: NSObject]] {
			var tmpScores = scores
			for scoreDict in scoreArray {
				var score = Score()
				if let name = scoreDict[kScoreNameKey] as? String {
					score.name = name
				} else {
					continue
				}
				
				if let pscore = scoreDict[kScoreScoreKey] as? Int {
					score.score = Int32(pscore)
				} else {
					continue
				}
				
				if let level = scoreDict[kScoreLevelKey] as? Int {
					score.level = Int32(level)
				} else {
					continue
				}
				
				tmpScores.append(score)
			}
			
			tmpScores.sortInPlace(>)
			
			while tmpScores.count > 10 {
				tmpScores.removeLast()
			}
			if tmpScores.count != 10 {
				return false
			} else {
				scores = tmpScores
				return true
			}
		}
		return false
	}
	
	func saveScores() {
		let defaults = NSUserDefaults.standardUserDefaults()
		var array = [[String: NSObject]]()
		for score in scores {
			let scoreDict: [String: NSObject] = [
				kScoreNameKey: score.name,
				kScoreScoreKey: Int(score.score),
				kScoreLevelKey: Int(score.level)]
			array.append(scoreDict)
		}
		
		defaults.setObject(array, forKey: kScoresKey)
	}
}
