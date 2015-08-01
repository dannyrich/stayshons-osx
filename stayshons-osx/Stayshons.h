//
//  Stayshons.h
//  Stayshons
//
//  Created by Danny Richelieu on 7/31/15.
//  Copyright (c) 2015 Daniel Richelieu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STKAudioPlayer.h"
#import "DataFromUrl.h"

@interface Stayshons : NSObject <STKAudioPlayerDelegate>

extern NSString * const NOTIFICATION_PLAYING_STATION;

-(NSArray*) loadFromServer;
-(NSArray*) stations;
-(NSDictionary*) station;
-(NSInteger) currentIndex;
-(NSDictionary*) getSongMeta;
-(void) playStationAtIndex:(NSInteger)index;
-(void) stop;
-(BOOL) canGetSongMeta;

@end
