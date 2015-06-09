//
//  GLScoreList.h
//  Glypha
//
//  Created by C.W. Betts on 5/28/15.
//  Copyright (c) 2015 Kevin Wojniak. All rights reserved.
//

#ifndef __Glypha__GLScoreList__
#define __Glypha__GLScoreList__

#include <string>
#include <vector>

namespace GL {
    class ScoreList {
    public:
        struct Score {
            std::string name;
            int level;
            int score;
            
            Score(std::string name, int level, int score) : name(name), level(level), score(score) {};
        };
        
        bool IsHighScore(int score);
        
        bool AddHighScore(const Score &newHighScore);
        inline bool AddHighScore(std::string name, int level, int scoreCount)
        {
            Score score = Score(name, level, scoreCount);
            return AddHighScore(score);
        }
        
        bool loadScores();
        void saveScores();
        
        const Score& scoreAtIndex(int idx);
        
    private:
        std::vector<Score> scores;
    };
}

#endif /* defined(__Glypha__GLScoreList__) */
