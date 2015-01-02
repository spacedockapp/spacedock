//
//  DockPushStartSegue.m
//  Space Dock
//
//  Created by Robert George on 12/3/14.
//  Copyright (c) 2014 Robert George. All rights reserved.
//

#import "DockPushStartSegue.h"

@implementation DockPushStartSegue

-(void)perform {
    
    UIWindow* w = [[[ UIApplication sharedApplication ] windows ] objectAtIndex: 0 ];
    if ([w.rootViewController isKindOfClass:[UISplitViewController class]]) {
        UISplitViewController*  root = (UISplitViewController*)w.rootViewController;
        UINavigationController*       detailsNavController = [ root.viewControllers objectAtIndex: 1 ];
        [detailsNavController setViewControllers:[NSArray arrayWithObjects:[self destinationViewController],nil]];
    }
    else if ([w.rootViewController isKindOfClass:[UINavigationController class]])
    {
        UINavigationController*       detailsNavController = (UINavigationController*)w.rootViewController;
        [detailsNavController pushViewController:[self destinationViewController] animated:YES];
    }
}

@end
