//
//  AppDelegate.h
//  stayshons-osx
//
//  Created by Daniel Richelieu on 7/22/15.
//  Copyright (c) 2015 Daniel Richelieu. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "STKAudioPlayer.h"

@interface AppDelegate : NSObject <NSApplicationDelegate, STKAudioPlayerDelegate>
{
    NSStatusItem *systemStatusItem;
    STKAudioPlayer *audioPlayer;
    
    NSMutableArray *menuItems;
    NSArray *stations;
    NSDictionary *station;
    
    NSMenu *appMenu;
}

@end
