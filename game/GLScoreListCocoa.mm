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
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *savedScores = [defaults objectForKey:kScoresKey];
    if (savedScores == nil) {
        return false;
    }
    for (NSDictionary *scoreDict in savedScores) {
        int score = ((NSNumber*)scoreDict[kScoreScoreKey]).intValue;
        int level = ((NSNumber*)scoreDict[kScoreLevelKey]).intValue;
        NSString *name = scoreDict[kScoreNameKey];
        // We may have a score of zero, but not a level of zero
        // Also a name with a nil value is also not good
        if (level <= 0 || name == nil) {
            continue;
        }
        AddHighScore(name.UTF8String, level, score);
    }
    
    return true;
}

void GL::ScoreList::saveScores()
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *mutArray = [[NSMutableArray alloc] initWithCapacity:10];
    for (std::vector<GL::ScoreList::Score>::const_iterator it = scores.begin(); it != scores.end(); it++) {
        const GL::ScoreList::Score &currentScore = *it;
        NSDictionary *scoreDict = @{kScoreNameKey: @(currentScore.getName().c_str()),
                                    kScoreScoreKey: @(currentScore.getScore()),
                                    kScoreLevelKey: @(currentScore.getLevel())};
        [mutArray addObject:scoreDict];
    }
    [defaults setObject:mutArray forKey:kScoresKey];
}
