//
//  GLScoreListCocoa.mm
//  Glypha
//
//  Created by C.W. Betts on 6/09/15.
//  Copyright (c) 2015 Kevin Wojniak. All rights reserved.
//

#include "GLScoreList.h"
#import <Foundation/Foundation.h>

#define kScoresKey @"scores"
#define kScoreNameKey @"name"
#define kScoreScoreKey @"score"
#define kScoreLevelKey @"level"

bool GL::ScoreList::loadScores()
{
    //NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    
    return true;
}

void GL::ScoreList::saveScores()
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *mutArray = [[NSMutableArray alloc] initWithCapacity:10];
    for (std::vector<GL::ScoreList::Score>::const_iterator it = scores.begin(); it != scores.end(); it++) {
        const GL::ScoreList::Score &currentScore = *it;
        NSDictionary *scoreDict = @{kScoreNameKey: @(currentScore.name.c_str()),
                                    kScoreScoreKey: @(currentScore.score),
                                    kScoreLevelKey: @(currentScore.level)};
        [mutArray addObject:scoreDict];
    }
    [defaults setObject:mutArray forKey:kScoresKey];
}
