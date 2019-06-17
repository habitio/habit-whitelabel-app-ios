//
//  MZScrollGalleryView.m
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 27/5/14.
//  Copyright (c) 2014 Muzzley. All rights reserved.
//

#import "MZScrollGalleryView.h"

#import "DDPageControl.h"
#import "MZScrollGalleryPageView.h"

@interface MZScrollGalleryView ()

@property (nonatomic, assign) NSUInteger numberOfPages;
@property (nonatomic, strong) NSMutableArray *pages;

@end


@implementation MZScrollGalleryView

- (void)dealloc
{
    self.scrollView = nil;
    self.pageControl = nil;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.pageControl.center = CGPointMake(self.bounds.size.width * 0.5,
                                          self.bounds.size.height - self.pageControl.bounds.size.height * 0.5);
    
    /*for (NSUInteger idx = 0; idx < self.pages.count; idx++) {
        
        MZScrollGalleryPageView *page = self.pages[idx];

        page.center = CGPointMake(self.bounds.size.width * idx + self.bounds.size.width * 0.5, self.bounds.size.height * 0.5);
    }*/
}

- (void)reloadData
{
    [self _configureSubviews];
}

- (void)_configureSubviews
{
    for (MZScrollGalleryPageView *page in self.pages) {
        [page removeFromSuperview];
    }
    //self.backgroundColor = [UIColor redColor];
    self.pages = [NSMutableArray new];
    
    if ([self.dataSource respondsToSelector:@selector(numberOfPagesInScrollGalleryView:)]) {
        self.numberOfPages = [self.dataSource numberOfPagesInScrollGalleryView:self];
        if (!self.numberOfPages) {
            self.numberOfPages = 0;
        }
    }
    
    // Configure a scrollView
    CGRect scrollViewBonds = CGRectMake(0, 0, self.bounds.size.width,
                                        self.bounds.size.height - 44);
    self.scrollView = [[UIScrollView alloc] initWithFrame:scrollViewBonds];
    self.scrollView.delegate = self;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    
    CGFloat contentWidth = self.scrollView.bounds.size.width * self.numberOfPages;
    CGFloat contentHeight = self.scrollView.bounds.size.height;
    
    self.scrollView.contentSize = CGSizeMake(contentWidth, contentHeight);
	[self addSubview:self.scrollView];
    
    if ([self.dataSource respondsToSelector:@selector(scrollGalleryView:pageAtIndex:)]) {
        
        for (NSUInteger idx = 0; idx < self.numberOfPages; idx++) {
        
            MZScrollGalleryPageView *page = [self.dataSource scrollGalleryView:self pageAtIndex:idx];
            page.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            page.center = CGPointMake(self.scrollView.bounds.size.width * idx + self.scrollView.bounds.size.width * 0.5, self.scrollView.bounds.size.height * 0.5);
            
            [self.pages addObject:page];
            [self.scrollView addSubview:page];
        }
    }
    
    // -------------------------
    // Configure a Page Control
    self.pageControl = [DDPageControl new];
    self.pageControl.numberOfPages = self.numberOfPages;
    self.pageControl.currentPage = 0;
    self.pageControl.defersCurrentPageDisplay = YES;
    self.pageControl.type = DDPageControlTypeOnFullOffFull;
    self.pageControl.onColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    self.pageControl.offColor = [UIColor colorWithWhite:1.0 alpha:0.4];
    self.pageControl.indicatorDiameter = 7.0f;
    self.pageControl.indicatorSpace = 8.0f;
    [self addSubview: self.pageControl];
}

#pragma mark - UIScrollView delegate methods

- (void)scrollViewDidScroll:(UIScrollView *)aScrollView
{
	CGFloat pageWidth = self.scrollView.bounds.size.width ;
    float fractionalPage = self.scrollView.contentOffset.x / pageWidth ;
	NSInteger nearestNumber = lround(fractionalPage) ;
	
	if (self.pageControl.currentPage != nearestNumber)
	{
		self.pageControl.currentPage = nearestNumber ;
		// if we are dragging, we want to update the page control directly during the drag
		if (self.scrollView.dragging)
			[self.pageControl updateCurrentPageDisplay] ;
	}
    
    if ([self.delegate respondsToSelector:@selector(scrollGalleryView:didScrollWithOffset:)]) {
        [self.delegate scrollGalleryView:self didScrollWithOffset:self.scrollView.contentOffset];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)aScrollView
{
	// if we are animating (triggered by clicking on the page control), we update the page control
	[self.pageControl updateCurrentPageDisplay];
}
@end
