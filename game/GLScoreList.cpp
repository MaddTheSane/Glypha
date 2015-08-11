//
//  GLScoreList.cpp
//  Glypha
//
//  Created by C.W. Betts on 5/28/15.
//  Copyright (c) 2015 Kevin Wojniak. All rights reserved.
//

#include "GLScoreList.h"
#include <algorithm>


static bool compare_as_ints (GL::ScoreList::Score i, GL::ScoreList::Score j)
{
    return i.getScore() > j.getScore();
}

const int GL::ScoreList::maxScores = 10;

bool GL::ScoreList::IsHighScore(int score)
{
    return score > scores.back().getScore();
}

bool GL::ScoreList::AddHighScore(const GL::ScoreList::Score &newHighScore)
{
    if (!IsHighScore(newHighScore.getScore())) {
        return false;
    }
    
    scores.push_back(newHighScore);
    
    std::stable_sort(scores.begin(), scores.end(), compare_as_ints);
    while (scores.capacity() > maxScores) {
        scores.pop_back();
    }
    
    return true;
}

const GL::ScoreList::Score& GL::ScoreList::scoreAtIndex(int idx)
{
    return scores[idx];
}
