//
//  GLResourcesBridge.h
//  Glypha
//
//  Created by C.W. Betts on 5/27/15.
//  Copyright (c) 2015 Kevin Wojniak. All rights reserved.
//

#ifndef Glypha_GLResourcesBridge_h
#define Glypha_GLResourcesBridge_h

#import <Foundation/Foundation.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef NS_ENUM(NSInteger, GlyphaResourceValue) {
	GlyphaResourceBackground,
	GlyphaResourceTorches,
	GlyphaResourcePlayer,
	GlyphaResourcePlayerIdle,
	GlyphaResourcePlatforms,
	GlyphaResourceNumbers,
	GlyphaResourceHand,
	GlyphaResourceObelisks,
	GlyphaResourceEnemyFly,
	GlyphaResourceEnemyWalk,
	GlyphaResourceEgg,
	GlyphaResourceEye,
	GlyphaResourceHelp,
	
	//Sound values
	GlyphaResourceFlap,
	GlyphaResourceGrate,
	GlyphaResourceWalk,
	GlyphaResourceScreech,
	GlyphaResourceBird,
	GlyphaResourceLightning,
	GlyphaResourceFlap2,
	GlyphaResourceScrape2,
	GlyphaResourceSpawn,
	GlyphaResourceSplash,
	GlyphaResourceBonus,
	GlyphaResourceBoom1,
	GlyphaResourceBoom2,
	GlyphaResourceMusic
};
	
NSData *__nonnull GlyphaDataForResource(GlyphaResourceValue val);
	
#ifdef __cplusplus
}
#endif

#endif
