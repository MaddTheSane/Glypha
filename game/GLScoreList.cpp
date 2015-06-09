//
//  GLScoreList.cpp
//  Glypha
//
//  Created by C.W. Betts on 5/28/15.
//  Copyright (c) 2015 Kevin Wojniak. All rights reserved.
//

#include "GLScoreList.h"

bool GL::ScoreList::IsHighScore(int score)
{
    return score > 100;
}

bool GL::ScoreList::AddHighScore(const GL::ScoreList::Score &newHighScore)
{
    scores.push_back(newHighScore);
    
    return true;
}
