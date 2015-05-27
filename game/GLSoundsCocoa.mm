#include "GLSounds.h"
#include <AVFoundation/AVFoundation.h>
#include <list>

struct Context {
    std::list<AVAudioPlayer*> sounds[GL::kMaxSounds];
};

void GL::Sounds::initContext()
{
    context = new Context;
}

void GL::Sounds::play(SoundID which)
{
    Context *ctx = static_cast<Context*>(context);
    bool found = false;
    for (std::list<AVAudioPlayer*>::const_iterator it = ctx->sounds[which].begin(); it != ctx->sounds[which].end(); ++it) {
        AVAudioPlayer *player = *it;
        if (!player.isPlaying) {
            [player play];
            found = true;
            break;
        }
    }
    if (!found) {
        NSLog(@"Preloaded sound not available for %d", which);
        AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithData:ctx->sounds[which].front().data error:nil];
        ctx->sounds[which].push_back(player);
        [player play];
    }
}

void GL::Sounds::load(SoundID which, const unsigned char *buf, unsigned bufLen)
{
    Context *ctx = static_cast<Context*>(context);
    NSData *data = [NSData dataWithBytesNoCopy:(void*)buf length:bufLen freeWhenDone:NO];
    int count = preloadCount(which);
    for (int i = 0; i < count; ++i) {
        AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithData:data error:nil];
        [player prepareToPlay];
        ctx->sounds[which].push_back(player);
    }
}
