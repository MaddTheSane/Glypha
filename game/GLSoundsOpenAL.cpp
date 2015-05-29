//
//  GLSoundsOpenAL.cpp
//  Glypha
//
//  Created by C.W. Betts on 5/28/15.
//  Copyright (c) 2015 Kevin Wojniak. All rights reserved.
//

#include "GLSounds.h"
#include <OpenAL/al.h>
#include <OpenAL/alc.h>
#include <ALUT/alut.h>

struct Context {
    ALuint buffers[GL::kMaxSounds];
    
    Context() {
        // Init openAL
        alutInit(0, NULL);
        // Clear Error Code (so we can catch any new errors)
        alGetError();
        //alGenBuffers(GL::kMaxSounds, buffers);
    }
};

void GL::Sounds::initContext()
{
    context = new Context;
}

void GL::Sounds::load(GL::SoundID which, const unsigned char *buf, unsigned bufLen)
{
    Context *ctx = static_cast<Context*>(context);
    ctx->buffers[which] = alutCreateBufferFromFileImage(buf, bufLen);
}

void GL::Sounds::play(GL::SoundID which)
{
    
}

