//
//  AppDelegate.m
//  stayshons-osx
//
//  Created by Daniel Richelieu on 7/22/15.
//  Copyright (c) 2015 Daniel Richelieu. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (id) init
{
    self = [super init];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    
    [center addObserver:self selector:@selector(stationIsPlaying) name:NOTIFICATION_PLAYING_STATION object:stayshons];
    
    stayshons = [[Stayshons alloc] init];
    menuItems = [[NSMutableArray alloc] init];
    
    [self createMenu:[stayshons loadFromServer]];
    
    return self;
}

- (void) createMenu:(NSArray*)stations
{
    
    NSStatusBar *bar = [NSStatusBar systemStatusBar];
    systemStatusItem = [bar statusItemWithLength:NSVariableStatusItemLength];
    [systemStatusItem setTitle:@"Stayshons"];
    [systemStatusItem setHighlightMode:YES];

    appMenu = [[NSMenu alloc] init];
    
    [appMenu addItem:[NSMenuItem separatorItem]];
    
    for (NSDictionary *station in stations) {
        NSMenuItem *mi = [[NSMenuItem alloc] initWithTitle:[station valueForKey:@"title"]                                                   action:@selector(play:) keyEquivalent:@""];
        [mi setTag:[menuItems count]];
        [menuItems addObject:mi];
        [appMenu addItem:mi];
    }
    
    [appMenu addItem:[NSMenuItem separatorItem]];
    [appMenu addItemWithTitle:@"Quit" action:@selector(quit) keyEquivalent:@""];
    [systemStatusItem setMenu:appMenu];
    
}

-(void) play:(NSMenuItem*) menuItem
{
    [stayshons playStationAtIndex:menuItem.tag];
}

- (void) stopStation:(NSMenuItem*) menuItem {
    
    [self setTitle:@"Stayshons"];
    [self clearMenuChecks];
    [stayshons stop];
    
    NSMenuItem *micheck = [appMenu itemWithTag: -1];
    NSMenuItem *michecktwo = [appMenu itemWithTag: -2];
    
    if (micheck) {
        [appMenu removeItem: micheck];
    }
    if (michecktwo) {
        [appMenu removeItem: michecktwo];
    }
}

- (void) stationIsPlaying
{
    NSInteger index = [stayshons currentIndex];

    if (index < [menuItems count]) {
        [self clearMenuChecks];
        
        NSMenuItem *menuItem = menuItems[index];
        
        [menuItem setState:NSOnState];
        
        NSDictionary *station = [stayshons station];
        
        NSString *name = [station valueForKey:@"title"];
        [self setTitle:name];
        
        NSMenuItem *micheck = [appMenu itemWithTag: -1];

        if (micheck == NULL) {
            NSMenuItem *mi = [[NSMenuItem alloc] initWithTitle:@"Stop" action:@selector(stopStation:) keyEquivalent:@""];
            [mi setTag:-1];
            
            if ([stayshons canGetSongMeta]) {
                NSMenuItem *mitwo = [[NSMenuItem alloc] initWithTitle:@"What's Playing?" action:@selector(showSongMeta) keyEquivalent:@""];
                [mitwo setTag:-2];
                
                [appMenu insertItem:mitwo atIndex:0];
            }
            
            [appMenu insertItem:mi atIndex:0];
        }
    }
}

- (void) showSongMeta
{
    NSDictionary* meta = [stayshons getSongMeta];
    
    if (meta) {
        NSString *message = @"";
        
        NSString *title = [meta valueForKey:@"title"];
        NSString *band = [meta valueForKey:@"band"];
        
        if (title || band) {
            if (band) {
                message = [message stringByAppendingString:
                           [NSString stringWithFormat:@"Band: %@\n", band]];
            }
            
            if (title) {
                message = [message stringByAppendingString:
                           [NSString stringWithFormat:@"Song: %@\n", title]];
            }
            
        } else {
            message = @"Song information could not be found.";
        }

        ProcessSerialNumber psn = {0, kCurrentProcess};
        TransformProcessType(&psn, kProcessTransformToForegroundApplication);
        
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"Thanks"];
        [alert setMessageText:@"Now Playing:"];
        [alert setInformativeText:message];
        [alert setAlertStyle:NSInformationalAlertStyle];
        
        [[NSRunningApplication currentApplication] activateWithOptions:NSApplicationActivateIgnoringOtherApps];
        
        [alert runModal];
        
        TransformProcessType(&psn, kProcessTransformToBackgroundApplication);
    }
}

- (void)setTitle:(NSString*)title
{
    [systemStatusItem setTitle:title];
}

- (void)clearMenuChecks
{
    for(NSMenuItem *i in menuItems) {
        [i setState:NSOffState];
    }
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    
    
}

- (void) applicationWillTerminate:(NSNotification *)notification
{
    [stayshons stop];
}

- (void) quit {
    [NSApp terminate:NULL];
}
@end

