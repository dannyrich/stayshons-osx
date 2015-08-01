//
//  AppDelegate.h
//  stayshons-osx
//
//  Created by Daniel Richelieu on 7/22/15.
//  Copyright (c) 2015 Daniel Richelieu. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Stayshons.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>
{
    NSStatusItem *systemStatusItem;
    NSMutableArray *menuItems;
    NSMenu *appMenu;
    Stayshons *stayshons;
    
}
@end
