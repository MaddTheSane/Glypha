//
//  GLResourcesBridge.m
//  Glypha
//
//  Created by C.W. Betts on 5/27/15.
//  Copyright (c) 2015 Kevin Wojniak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLResourcesBridge.h"
#import "GLResources.h"

NSData *GlyphaDataForResource(GlyphaResourceValue val)
{
	NSData *toRet = nil;
	
#define SetToRet(dataName) toRet = [[NSData alloc] initWithBytesNoCopy: (void*)GL:: dataName length:GL::dataName ## _len freeWhenDone:NO]
	
	switch (val) {
		case GlyphaResourceBackground:
			SetToRet(background_png);
			break;
			
		case GlyphaResourceTorches:
			SetToRet(torches_png);
			break;
			
		case GlyphaResourcePlayer:
			SetToRet(player_png);
			break;
			
		case GlyphaResourcePlayerIdle:
			SetToRet(playerIdle_png);
			break;
			
		case GlyphaResourcePlatforms:
			SetToRet(platforms_png);
			break;
			
		case GlyphaResourceNumbers:
			SetToRet(numbers_png);
			break;
			
		case GlyphaResourceHand:
			SetToRet(hand_png);
			break;
			
		case GlyphaResourceObelisks:
			SetToRet(obelisks_png);
			break;
			
		case GlyphaResourceEnemyFly:
			SetToRet(enemyFly_png);
			break;
			
		case GlyphaResourceEnemyWalk:
			SetToRet(enemyWalk_png);
			break;
			
		case GlyphaResourceEgg:
			SetToRet(egg_png);
			break;
			
		case GlyphaResourceEye:
			SetToRet(eye_png);
			break;
			
		case GlyphaResourceHelp:
			SetToRet(help_png);
			break;
			
			
			//Sound
			
		case GlyphaResourceFlap:
			SetToRet(flap_aif);
			break;
			
		case GlyphaResourceFlap2:
			SetToRet(flap2_aif);
			break;
			
		case GlyphaResourceGrate:
			SetToRet(grate_aif);
			break;
			
		case GlyphaResourceWalk:
			SetToRet(walk_aif);
			break;
			
		case GlyphaResourceScreech:
			SetToRet(screech_aif);
			break;
			
		case GlyphaResourceBird:
			SetToRet(bird_aif);
			break;
			
		case GlyphaResourceLightning:
			SetToRet(lightning_aif);
			break;
			
		case GlyphaResourceScrape2:
			SetToRet(scrape2_aif);
			break;
			
		case GlyphaResourceSpawn:
			SetToRet(spawn_aif);
			break;
			
		case GlyphaResourceSplash:
			SetToRet(splash_aif);
			break;
			
		case GlyphaResourceBonus:
			SetToRet(bonus_aif);
			break;
			
		case GlyphaResourceBoom1:
			SetToRet(boom1_aif);
			break;
			
		case GlyphaResourceBoom2:
			SetToRet(boom2_aif);
			break;
			
		case GlyphaResourceMusic:
			SetToRet(music_aif);
			break;
			
		default:
			toRet = [[NSData alloc] init];
			break;
	}
	
	return toRet;
}

