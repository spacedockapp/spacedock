//
//  DockMoveGrid.m
//  Space Dock
//
//  Created by Rob Tsuk on 11/24/13.
//  Copyright (c) 2013 Rob Tsuk. All rights reserved.
//

#import "DockMoveGrid.h"

@implementation DockMoveGrid

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
	[super drawRect:dirtyRect];
    
    NSRect bounds = self.bounds;
    NSSize availableSize = bounds.size;
    CGFloat availableSpace = availableSize.height < availableSize.width ? availableSize.height : availableSize.width;
    CGFloat lineWidth = availableSpace / 100.0;
    CGFloat offsetX = (bounds.size.width - availableSpace)/2;
    CGFloat offsetY = (bounds.size.height - availableSpace)/2;

    NSRect blackBox = NSMakeRect(offsetX, offsetY, availableSpace, availableSpace);
    
    
    [[NSColor blackColor] set];
    [NSBezierPath setDefaultLineWidth: lineWidth];
    [NSBezierPath fillRect: blackBox];
    [[NSColor whiteColor] set];
    CGFloat inset = lineWidth * 5;
    NSRect gridBox = NSInsetRect(blackBox, inset, inset);
    [NSBezierPath strokeRect: gridBox];
    CGFloat rowSize = gridBox.size.width / 7.0;
    CGFloat fontSize = rowSize;
    
    CGFloat x = gridBox.origin.x + rowSize - 1;
    for (int i = 0; i < 6; ++i) {
        NSRect lineRect = NSMakeRect(x, gridBox.origin.y, lineWidth, gridBox.size.height);
        NSBezierPath* line = [NSBezierPath bezierPathWithRect: lineRect];
        [line fill];
        x += rowSize;
    }

    CGFloat y = gridBox.origin.y + rowSize - 1;
    for (int i = 0; i < 6; ++i) {
        NSRect lineRect = NSMakeRect(gridBox.origin.x, y, gridBox.size.width, lineWidth);
        NSBezierPath* line = [NSBezierPath bezierPathWithRect: lineRect];
        [line fill];
        y += rowSize;
    }
    
    int moveValues[] = {5,4,3,2,1,1,2};
    y = gridBox.origin.y - 1;
    NSFont* font = [NSFont fontWithName: @"Helvetica" size: fontSize];
    NSDictionary* attr = @{
        NSForegroundColorAttributeName: [NSColor whiteColor],
        NSFontAttributeName: font
    };
    for (int i = 6; i >= 0; --i) {
        NSString* move = [NSString stringWithFormat: @"%d", moveValues[i]];
        NSSize moveStringSize = [move sizeWithAttributes: attr];
        CGFloat deltaX = (rowSize - moveStringSize.width)/2.0;
        CGFloat deltaY = (rowSize - moveStringSize.height)/2.0;
        NSRect moveRect = NSMakeRect(gridBox.origin.x + deltaX, y + deltaY + lineWidth, moveStringSize.width, moveStringSize.height);
        [move drawInRect: moveRect withAttributes: attr];
        y += rowSize;
    }
}

@end
