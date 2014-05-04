//
//  DockPaginatedTableView.m
//  Space Dock
//
//  Created by Rob Tsuk on 5/4/14.
//  Copyright (c) 2014 Rob Tsuk. All rights reserved.
//

#import "DockPaginatedTableView.h"

@implementation DockPaginatedTableView

// Taken from here: http://lists.apple.com/archives/cocoa-dev/2002/Nov/msg01710.html
// Ensures rows in the table aren't cut off when printing
- (void)adjustPageHeightNew:(CGFloat *)newBottom top:(CGFloat)oldTop bottom:(CGFloat)oldBottom limit:(CGFloat)bottomLimit
{
    NSInteger cutoffRow = [self rowAtPoint:NSMakePoint(0, oldBottom)];
    NSRect rowBounds;
    
    *newBottom = oldBottom;
    if (cutoffRow != -1) {
        rowBounds = [self rectOfRow:cutoffRow];
        if (oldBottom < NSMaxY(rowBounds)) {
            *newBottom = NSMinY(rowBounds);
        }
    }
}

// Taken from here: http://lists.apple.com/archives/cocoa-dev/2002/Nov/msg01710.html
// Ensures rows in the table aren't cut off when printing
- (void)xadjustPageHeightNew:(CGFloat *)newBottom top:(CGFloat)oldTop bottom:(CGFloat)oldBottom limit:(CGFloat)bottomLimit
{
    if (!_topBorderRows) {
        _topBorderRows = [NSMutableArray array];
        _bottomBorderRows = [NSMutableArray array];
    }
    
    NSInteger cutoffRow = [self rowAtPoint:NSMakePoint(0, oldBottom)];
    NSRect rowBounds;
    
    *newBottom = oldBottom;
    if (cutoffRow != -1) {
        rowBounds = [self rectOfRow:cutoffRow];
        if (oldBottom < NSMaxY(rowBounds)) {
            *newBottom = NSMinY(rowBounds);
            
            NSNumber *row = [NSNumber numberWithInteger:cutoffRow];
            NSNumber *previousRow = [NSNumber numberWithInteger:cutoffRow - 1];
            
            // Mark which rows need which border, ignore ones we've already seen, and adjust ones that need different borders
            if (![[_topBorderRows lastObject] isEqual:row]) {
                if ([[_bottomBorderRows lastObject] isEqual:row]) {
                    [_topBorderRows removeLastObject];
                    [_bottomBorderRows removeLastObject];
                }
                
                [_topBorderRows addObject:row];
                [_bottomBorderRows addObject:previousRow];
            }
        }
    }
}

// Draw the row as normal, and add any borders to cells that were pushed down due to pagination
- (void)xdrawRow:(NSInteger)rowIndex clipRect:(NSRect)clipRect {
    [super drawRow:rowIndex clipRect:clipRect];
    
    if ([_topBorderRows count] == 0) return;
    
    NSRect rowRect = [self rectOfRow:rowIndex];
    NSBezierPath *gridPath = [NSBezierPath bezierPath];
    NSColor *color = [NSColor darkGrayColor];
    
    for (int i=0; i<[_topBorderRows count]; i++) {
        NSInteger rowNeedingTopBorder = [(NSNumber *)[_topBorderRows objectAtIndex:i] integerValue];
        if (rowNeedingTopBorder == rowIndex) {
            [gridPath moveToPoint:rowRect.origin];
            [gridPath lineToPoint:NSMakePoint(rowRect.origin.x + rowRect.size.width, rowRect.origin.y)];
            
            [color setStroke];
            [gridPath stroke];
        }
        
        NSInteger rowNeedingBottomBorder = [(NSNumber *)[_bottomBorderRows objectAtIndex:i] integerValue];
        if (rowNeedingBottomBorder == rowIndex) {
            [gridPath moveToPoint:NSMakePoint(rowRect.origin.x, rowRect.origin.y + rowRect.size.height)];
            [gridPath lineToPoint:NSMakePoint(rowRect.origin.x + rowRect.size.width, rowRect.origin.y + rowRect.size.height)];
            
            [color setStroke];
            [gridPath stroke];
        }
    }
}

@end
