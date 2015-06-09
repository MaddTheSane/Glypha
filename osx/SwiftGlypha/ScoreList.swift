//
//  ScoreList.swift
//  Glypha
//
//  Created by C.W. Betts on 6/9/15.
//  Copyright © 2015 Kevin Wojniak. All rights reserved.
//

import Foundation

func >(lhs: ScoreList.Score, rhs: ScoreList.Score) -> Bool {
	return lhs.score > rhs.score
}

final class ScoreList {
	struct Score {
		var name: String
		var score: Int32
		var level: Int32
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
	
	private var scores = [Score]()
}
