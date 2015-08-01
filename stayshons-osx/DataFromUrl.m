//
//  DataFromUrl.m
//  Stayshons
//
//  Created by Danny Richelieu on 7/31/15.
//  Copyright (c) 2015 Daniel Richelieu. All rights reserved.
//

#import "DataFromUrl.h"

@implementation DataFromUrl

+ (NSData*)getDataFromUrl:(NSString*)url
{
    NSURL *stationsPath = [[NSURL alloc] initWithString:url];
    
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:stationsPath                                              cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:30];
    
    NSData *urlData;
    NSURLResponse *response;
    NSError *error;
    
    urlData = [NSURLConnection sendSynchronousRequest:urlRequest                                     returningResponse:&response error:&error];
    
    return urlData;
}

@end
