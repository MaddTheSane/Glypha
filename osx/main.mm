#import <Cocoa/Cocoa.h>
#import <CoreVideo/CoreVideo.h>
#include "GLGame.h"
#include "GLRenderer.h"
#include "GLResources.h"

@interface GameView : NSOpenGLView

- (void)setGame:(GL::Game *)game;
- (void)render;

@end

@interface AppController : NSObject <NSApplicationDelegate>

- (IBAction)newGame:(id)sender;
- (void)handleGameEvent:(GL::Game::Event)event;

@end

static void callback(GL::Game::Event event, void *context)
{
    [(__bridge AppController*)context handleGameEvent:event];
}

@implementation AppController
{
	GL::Game *_game;
	NSWindow *window_;
	NSMenuItem *_newGame;
	NSMenuItem *_endGame;
	NSMenuItem *_helpMenuItem;
	GameView *_gameView;
}

- (void)setupMenuBar:(NSString *)appName
{
    NSMenu *menubar = [[NSMenu alloc] init];
    [NSApp setMainMenu:menubar];
    NSMenuItem *item;
    
    NSMenu *appMenu = [[NSMenu alloc] initWithTitle:appName];
    NSMenuItem *appMenuItem = [[NSMenuItem alloc] init];
    NSMenu *gameMenu = [[NSMenu alloc] initWithTitle:@"Game"];
    [gameMenu setAutoenablesItems:NO];
    NSMenuItem *gameMenuItem = [[NSMenuItem alloc] init];
    NSMenu *helpMenu = [[NSMenu alloc] initWithTitle:@"Help"];
    [helpMenu setAutoenablesItems:NO];
    NSMenuItem *helpMenuItem = [[NSMenuItem alloc] init];
    [appMenuItem setSubmenu:appMenu];
    [gameMenuItem setSubmenu:gameMenu];
    [helpMenuItem setSubmenu:helpMenu];
    [menubar addItem:appMenuItem];
    [menubar addItem:gameMenuItem];
    [menubar addItem:helpMenuItem];
    
    item = [appMenu addItemWithTitle:[NSString stringWithFormat:@"About %@", appName] action:@selector(orderFrontStandardAboutPanel:) keyEquivalent:@""];
    [item setTarget:NSApp];
    [appMenu addItem:[NSMenuItem separatorItem]];
    NSString *quitText = [NSString stringWithFormat:@"Quit %@", appName];
    item = [appMenu addItemWithTitle:quitText action:@selector(terminate:) keyEquivalent:@"q"];
    [item setTarget:NSApp];
    _newGame = [gameMenu addItemWithTitle:@"New Game" action:@selector(newGame:) keyEquivalent:@"n"];
    [_newGame setTarget:self];
    _endGame = [gameMenu addItemWithTitle:@"End Game" action:@selector(endGame:) keyEquivalent:@"e"];
    [_endGame setTarget:self];
    [_endGame setEnabled:NO];
    _helpMenuItem = [helpMenu addItemWithTitle:@"Help" action:@selector(showHelp:) keyEquivalent:@"h"];
    [_helpMenuItem setTarget:self];
}

- (id)init
{
    self = [super init];
    if (self != nil) {
        NSString *appName = @(GL::kGameName.c_str());
        NSUInteger style = NSTitledWindowMask | NSClosableWindowMask | NSMiniaturizableWindowMask;
        window_ = [[NSWindow alloc] initWithContentRect:NSMakeRect(0, 0, 640, 460) styleMask:style backing:NSBackingStoreBuffered defer:NO];
        [window_ setTitle:appName];
        _gameView = [[GameView alloc] initWithFrame:[[window_ contentView] frame]];
        [[window_ contentView] addSubview:_gameView];
        [self setupMenuBar:appName];
        _game = new GL::Game(callback, (__bridge void*)self);
        [_gameView setGame:_game];
    }
    return self;
}

- (void)applicationDidFinishLaunching:(__unused NSNotification*)note
{
    // Center the window, then set the autosave name. If the frame already has been saved, it'll override the centering.
    [window_ center];
    [window_ setFrameAutosaveName:@"MainWindow"];
    
    // Show the window only after its frame has been adjusted.
    [window_ makeKeyAndOrderFront:nil];
}

- (IBAction)newGame:(__unused id)sender
{
    _game->newGame();
}

- (IBAction)endGame:(__unused id)sender
{
    _game->endGame();
}

- (IBAction)showHelp:(__unused id)sender
{
    _game->showHelp();
}

- (void)handleGameEvent:(GL::Game::Event)event
{
    switch (event) {
        case GL::Game::EventStarted:
            _newGame.enabled = NO;
            _endGame.enabled = YES;
            _helpMenuItem.enabled = NO;
            break;
        case GL::Game::EventEnded:
            _newGame.enabled = YES;
            _endGame.enabled = NO;
            _helpMenuItem.enabled = YES;
            break;
    }
}

@end

static CVReturn displayLinkCallback(CVDisplayLinkRef displayLink __unused, const CVTimeStamp* now __unused, const CVTimeStamp* outputTime __unused, CVOptionFlags flagsIn __unused, CVOptionFlags* flagsOut __unused, void* displayLinkContext)
{
    [(__bridge GameView*)displayLinkContext render];
    return kCVReturnSuccess;
}

@implementation GameView
{
    CVDisplayLinkRef _displayLink;
    GL::Game *_game;
}

- (id)initWithFrame:(NSRect)frameRect
{
    NSOpenGLPixelFormatAttribute attr[] = {NSOpenGLPFAAccelerated, NSOpenGLPFADoubleBuffer, NSOpenGLPFADepthSize, 24, 0};
    NSOpenGLPixelFormat *format = [[NSOpenGLPixelFormat alloc] initWithAttributes:attr];
    return [super initWithFrame:frameRect pixelFormat:format];
}

- (void)dealloc
{
    CVDisplayLinkRelease(_displayLink);
}

- (void)setGame:(GL::Game *)game
{
    _game = game;
}

- (void)prepareOpenGL
{
    // Synchronize buffer swaps with vertical refresh rate
    GLint swapInt = 1;
    [[self openGLContext] setValues:&swapInt forParameter:NSOpenGLCPSwapInterval]; 

    // Create a display link capable of being used with all active displays
    CVDisplayLinkCreateWithActiveCGDisplays(&_displayLink);
    
    // Set the renderer output callback function
    ::CVDisplayLinkSetOutputCallback(_displayLink, &displayLinkCallback, (__bridge void*)self);
    
    // Set the display link for the current renderer
    CGLContextObj cglContext = (CGLContextObj)[[self openGLContext] CGLContextObj];
    CGLPixelFormatObj cglPixelFormat = (CGLPixelFormatObj)[[self pixelFormat] CGLPixelFormatObj];
    CVDisplayLinkSetCurrentCGDisplayFromOpenGLContext(_displayLink, cglContext, cglPixelFormat);
    
    // Activate the display link
    CVDisplayLinkStart(_displayLink);
}

- (void)reshape
{
	NSRect bounds = [self bounds];
    _game->renderer()->resize(bounds.size.width, bounds.size.height);
	[[self openGLContext] update];
}

- (void)render
{
    if (_game) {
        NSOpenGLContext *ctx = [self openGLContext];
        [ctx makeCurrentContext];
        CGLLockContext((CGLContextObj)[ctx CGLContextObj]);
        _game->run();
        [ctx flushBuffer];
        CGLUnlockContext((CGLContextObj)[ctx CGLContextObj]);;
    }
}

- (void)drawRect:(__unused NSRect)rect
{
    [self render];
}

- (void)mouseDown:(NSEvent *)event
{
    NSPoint mouseLoc = [self convertPoint:[event locationInWindow] fromView:nil];
    GL::Point point(mouseLoc.x, _game->renderer()->bounds().height() - mouseLoc.y);
    _game->handleMouseDownEvent(point);
}

- (void)doKey:(NSEvent *)event up:(BOOL)up
{
    NSString *chars = [event characters];
    for (NSUInteger i = 0; i < [chars length]; ++i) {
        unichar ch = [chars characterAtIndex:i];
        GL::Game::Key key;
        switch (ch) {
            case ' ':
                key = GL::Game::KeySpacebar;
                break;
            case NSUpArrowFunctionKey:
                key = GL::Game::KeyUpArrow;
                break;
            case NSDownArrowFunctionKey:
                key = GL::Game::KeyDownArrow;
                break;
            case NSLeftArrowFunctionKey:
                key = GL::Game::KeyLeftArrow;
                break;
            case NSRightArrowFunctionKey:
                key = GL::Game::KeyRightArrow;
                break;
            case 'a':
                key = GL::Game::KeyA;
                break;
            case 's':
                key = GL::Game::KeyS;
                break;
            case ';':
                key = GL::Game::KeyColon;
                break;
            case '"':
                key = GL::Game::KeyQuote;
                break;
            case NSPageUpFunctionKey:
                key = GL::Game::KeyPageUp;
                break;
            case NSPageDownFunctionKey:
                key = GL::Game::KeyPageDown;
                break;
            default:
                key = GL::Game::KeyNone;
                break;
        }
        if (up) {
            _game->handleKeyUpEvent(key);
        } else {
            _game->handleKeyDownEvent(key);
        }
    }
}

- (void)keyDown:(NSEvent *)event
{
    [self doKey:event up:NO];
}

- (void)keyUp:(NSEvent *)event
{
    [self doKey:event up:YES];
}

- (BOOL)canBecomeKeyView
{
    return YES;
}

- (BOOL)acceptsFirstResponder
{
    return YES;
}

@end

int main(int argc, char *argv[])
{
    NSApplication *app = [NSApplication sharedApplication];
    AppController *controller = [[AppController alloc] init];
    app.delegate = controller;
    return NSApplicationMain(argc, (const char **)argv);
}
