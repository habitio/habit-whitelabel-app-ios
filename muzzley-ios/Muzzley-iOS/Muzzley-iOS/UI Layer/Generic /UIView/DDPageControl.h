//
//  DDPageControl.h
//  DDPageControl
//
//  Created by Damien DeVille on 1/14/11.
//  Copyright 2011 Snappy Code. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIControl.h>
#import <UIKit/UIKitDefines.h>

typedef enum
{
	DDPageControlTypeOnFullOffFull		= 0,
	DDPageControlTypeOnFullOffEmpty		= 1,
	DDPageControlTypeOnEmptyOffFull		= 2,
	DDPageControlTypeOnEmptyOffEmpty	= 3,
}
DDPageControlType ;


@interface DDPageControl : UIControl

// Replicate UIPageControl features
@property(nonatomic, assign) NSInteger numberOfPages ;
@property(nonatomic, assign) NSInteger currentPage ;

@property(nonatomic, assign) BOOL hidesForSinglePage ;

@property(nonatomic, assign) BOOL defersCurrentPageDisplay ;
- (void)updateCurrentPageDisplay ;

- (CGSize)sizeForNumberOfPages:(NSInteger)pageCount ;

/*
	DDPageControl add-ons - all these parameters are optional
	Not using any of these parameters produce a page control identical to Apple's UIPage control
 */
- (id)initWithType:(DDPageControlType)theType ;

@property (nonatomic, assign) DDPageControlType type ;

@property (nonatomic, strong) UIColor *onColor ;
@property (nonatomic, strong) UIColor *offColor ;

@property (nonatomic, assign) CGFloat indicatorDiameter ;
@property (nonatomic, assign) CGFloat indicatorSpace ;

@end

