#ifndef GLGAME_H
#define GLGAME_H

#include "GLRect.h"
#include "GLPoint.h"
#include "GLRenderer.h"
#include "GLImage.h"
#include "GLSounds.h"
#include "GLCursor.h"
#include "GLUtils.h"
#include "GLScoreList.h"
#if _WIN32
#else
#include <pthread.h>
#endif

// Enums and Options
#if (__cplusplus && __cplusplus >= 201103L && (__has_extension(cxx_strong_enums) || __has_feature(objc_fixed_enum))) || (!__cplusplus && __has_feature(objc_fixed_enum))
#define GLYPHENUM(_type, _name) enum _name : _type _name; enum _name : _type
#if (__cplusplus)
#define GLYPHOPTIONS(_type, _name) _type _name; enum : _type
#else
#define GLYPHOPTIONS(_type, _name) enum _name : _type _name; enum _name : _type
#endif
#else
#define GLYPHENUM(_type, _name) _type _name; enum
#define GLYPHOPTIONS(_type, _name) _type _name; enum
#endif


namespace GL {

class Lock {
#if _WIN32
public:
    Lock() {
        InitializeCriticalSection(&lock_);
    }
    ~Lock() {
        DeleteCriticalSection(&lock_);
    }
    void lock() {
        EnterCriticalSection(&lock_);
    }
    void unlock() {
        LeaveCriticalSection(&lock_);
    }
private:
    CRITICAL_SECTION lock_;
#else
public:
    Lock() {
        pthread_mutex_init(&mutex_, NULL);
    }
    ~Lock() {
        pthread_mutex_destroy(&mutex_);
    }
    void lock() {
        pthread_mutex_lock(&mutex_);
    }
    void unlock() {
        pthread_mutex_unlock(&mutex_);
    }
private:
    pthread_mutex_t mutex_;
#endif
};

class Locker {
public:
    Locker(Lock& lock)
        : lock_(lock)
    {
        lock_.lock();
    }
    ~Locker() {
        lock_.unlock();
    }
private:
    Lock& lock_;
};

#define kNumLightningPts 8
#define kMaxEnemies 8

class Game {
public:
    typedef GLYPHOPTIONS(unsigned int, Key) {
        KeyNone        = (1 << 0),
        KeySpacebar    = (1 << 1),
        KeyUpArrow     = (1 << 2),
        KeyDownArrow   = (1 << 3),
        KeyLeftArrow   = (1 << 4),
        KeyRightArrow  = (1 << 5),
        KeyA           = (1 << 6),
        KeyS           = (1 << 7),
        KeyColon       = (1 << 8),
        KeyQuote       = (1 << 9),
        KeyPageUp      = (1 << 10),
        KeyPageDown    = (1 << 11),
    };
    
    enum Event {
        EventStarted = 0,
        EventEnded = 1,
    };

    typedef void (*Callback)(Event event, void *context);

    Game(Callback callback, void *context);
    ~Game();
    
    Renderer* renderer();
    
    void run();
    
    void handleMouseDownEvent(const Point& point);
    void handleKeyDownEvent(Key key);
    void handleKeyUpEvent(Key key);
    
    void newGame();
    void endGame();
    void showHelp();
    
private:
    Callback callback_;
    void *callbackContext_;
    
    Renderer *renderer_;
    Cursor cursor;
    Sounds sounds;
    Utils utils;
    Lock lock_;
    
    double now;
    double lastTime;
    double accumulator;
    void loadImages();
    bool playing, evenFrame, flapKeyDown;
    
    void update();
    void drawFrame() const;
    
    Image bgImg;
    void drawBackground() const;

    Image torchesImg;
    Rect flameDestRects[2], flameRects[4];
    void drawTorches() const;

    void handleLightning();
    void generateLightning(int h, int v);
    void drawLightning() const;
    void doLightning(const Point& point, int count);
    Point leftLightningPts[kNumLightningPts], rightLightningPts[kNumLightningPts];
    Point mousePoint;
    int lightningCount;
    double lastLightningStrike;
    Point lightningPoint;
    int newGameLightning;
    double lastNewGameLightning;
    Rect obeliskRects[4];
    Image obelisksImg;
    bool flashObelisks;
    void drawObelisks() const;
    
    int numLedges, levelOn, livesLeft;
    
    struct Player {
        Rect dest, wasDest, wrap;
        int h, v;
        int wasH, wasV;
        int hVel, vVel;
        int srcNum, mode;
        int frame;
        bool facingRight, flapping;
        bool walking, wrapping;
        bool clutched;
    } thePlayer;
    Rect playerRects[11];
    void resetPlayer(bool initialPlace);
    void offAMortal();
    Image playerImg;
    Image playerIdleImg;
    void drawPlayer() const;
    void movePlayer();
    void handlePlayerIdle();
    void handlePlayerWalking();
    void handlePlayerFlying();
    void handlePlayerSinking();
    void handlePlayerFalling();
    void handlePlayerBones();
    void setAndCheckPlayerDest();
    void checkTouchDownCollision();
    void checkPlatformCollision();
    void setUpLevel();
    void checkLavaRoofCollision();
    void checkPlayerWrapAround();
    void keepPlayerOnPlatform();
    
    void getPlayerInput();
    int keys_;
    Rect platformRects[6], touchDownRects[6], enemyRects[24];
    
    Rect platformCopyRects[9];
    void drawPlatforms() const;
    Image platformImg;
    
    long score_;
    Image numbersImg;
    Rect numbersSrc[11], numbersDest[11];
    void drawLivesNumbers() const;
    void drawScoreNumbers() const;
    void drawLevelNumbers() const;
    void addToScore(int value);
    
    struct Hand {
        Rect dest;
        int mode;
    } theHand;
    Image handImg;
    Rect grabZone;
    Rect handRects[2];
    void initHandLocation();
    void handleHand();
    
    int countDownTimer;
    void handleCountDownTimer();
    
    int numEnemies;
    int numEnemiesThisLevel;
    int deadEnemies;
    int numOwls;
    int spawnedEnemies;
    struct Enemy {
        Rect dest, wasDest;
        int h, v;
        int wasH, wasV;
        int hVel, vVel;
        int srcNum, mode;
        int kind, frame;
        int heightSmell, targetAlt;
        int flapImpulse, pass;
        int maxHVel, maxVVel;
        bool facingRight;
    } theEnemies[kMaxEnemies];
    Rect enemyInitRects[5];
    Rect eggSrcRect;
    bool doEnemyFlapSound;
	bool doEnemyScrapeSound;
    Image enemyFly;
    Image enemyWalk;
    Image egg;
    void moveEnemies();
    void checkEnemyWrapAround(int who) const;
    void drawHand() const;
    void drawEnemies() const;
    void generateEnemies();
    bool setEnemyInitialLocation(Rect& theRect);
    void initEnemy(int i, bool reincarnated);
    void setEnemyAttributes(int i);
    int assignNewAltitude();
    void checkEnemyPlatformHit(int h);
    void checkEnemyRoofCollision(int i);
    void handleIdleEnemies(int i);
    void handleFlyingEnemies(int i);
    void handleWalkingEnemy(int i);
    void handleSpawningEnemy(int i);
    void handleFallingEnemy(int i);
    void handleEggEnemy(int i);
    void resolveEnemyPlayerHit(int i);
    void checkPlayerEnemyCollision();
    
    struct eyeInfo {
        Rect dest;
        int mode, opening;
        int srcNum, frame;
        bool killed, entering;
    } theEye;
    Image eyeImg;
    Rect eyeRects[4];
    void initEye();
    void killOffEye();
    void handleEye();
    void drawEye() const;
    
    Rect helpSrcRect;
    Rect helpSrc;
    Rect helpDest;
    Rect wallSrc;
    Rect wallDest;
    Image helpImg;
    enum HelpState {
        kHelpClosed = 0,
        kHelpOpening = 1,
        kHelpOpen = 2,
    };
    HelpState helpState;
    int helpPos;
    void openHelp();
    void handleHelp();
    void drawHelp() const;
    void scrollHelp(short scrollDown);
    
    ScoreList scores;
    HelpState scoreState;
    void openScores();
    void handleScores();
    void drawScores() const;
};

}

#endif
