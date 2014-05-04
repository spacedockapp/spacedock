//
//  DockBoxView.m
//  Space Dock
//
//  Created by Rob Tsuk on 5/4/14.
//  Copyright (c) 2014 Rob Tsuk. All rights reserved.
//

#import "DockBoxView.h"

@implementation DockBoxView

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    [[NSColor blackColor] set];
    NSRect f = NSInsetRect(self.bounds, 0, 0);
    [NSBezierPath strokeRect: f];
}

@end
