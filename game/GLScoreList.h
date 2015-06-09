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
        };
        
        bool addScore() {
            return false;
        }
        
    private:
        std::vector<Score> scores;
    };
}

#endif /* defined(__Glypha__GLScoreList__) */
