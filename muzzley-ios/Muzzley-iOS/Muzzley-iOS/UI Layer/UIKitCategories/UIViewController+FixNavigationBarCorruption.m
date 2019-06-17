//
//  UIViewController+FixNavigationBarCorruption.m
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 12/11/14.
//  Copyright (c) 2014 Muzzley. All rights reserved.
//

#import "UIViewController+FixNavigationBarCorruption.h"

@implementation UIViewController (FixNavigationBarCorruption)

/**
 * Fixes a problem where the navigation bar sometimes becomes corrupt
 * when transitioning using an interactive transition.
 *
 * Call this method in your view controller's viewWillAppear: method
 */
- (void)fixNavigationBarCorruption
{
    // Get our transition coordinator
    id<UIViewControllerTransitionCoordinator> coordinator = self.transitionCoordinator;
    
    // If we have a transition coordinator and it was initially interactive when it started,
    // we can attempt to fix the issue with the nav bar corruption.
    if ([coordinator initiallyInteractive]) {
        
        // Use a map table so we can map from each view to its animations
        NSMapTable *mapTable = [[NSMapTable alloc] initWithKeyOptions:NSMapTableStrongMemory
                                                         valueOptions:NSMapTableStrongMemory
                                                             capacity:0];
        
        // This gets run when your finger lifts up while dragging with the interactivePopGestureRecognizer
        [coordinator notifyWhenInteractionEndsUsingBlock:^(id<UIViewControllerTransitionCoordinatorContext> context) {
            
            // Loop through our nav controller's nav bar's subviews
            for (UIView *view in self.navigationController.navigationBar.subviews) {
                
                NSArray *animationKeys = view.layer.animationKeys;
                NSMutableArray *anims = [NSMutableArray array];
                
                // Gather this view's animations
                for (NSString *animationKey in animationKeys) {
                    CABasicAnimation *anim = (id)[view.layer animationForKey:animationKey];
                    
                    // In case any other kind of animation somehow gets added to this view, don't bother with it
                    if ([anim isKindOfClass:[CABasicAnimation class]]) {
                        
                        // Make a pseudo-hard copy of each animation.
                        // We have to make a copy because we cannot modify an existing animation.
                        CABasicAnimation *animCopy = [CABasicAnimation animationWithKeyPath:anim.keyPath];
                        
                        // CABasicAnimation properties
                        // Make sure fromValue and toValue are the same, and that they are equal to the layer's final resting value
                        animCopy.fromValue = [view.layer valueForKeyPath:anim.keyPath];
                        animCopy.toValue = [view.layer valueForKeyPath:anim.keyPath];
                        animCopy.byValue = anim.byValue;
                        
                        // CAPropertyAnimation properties
                        animCopy.additive = anim.additive;
                        animCopy.cumulative = anim.cumulative;
                        animCopy.valueFunction = anim.valueFunction;
                        
                        // CAAnimation properties
                        animCopy.timingFunction = anim.timingFunction;
                        animCopy.delegate = anim.delegate;
                        animCopy.removedOnCompletion = anim.removedOnCompletion;
                        
                        // CAMediaTiming properties
                        animCopy.speed = anim.speed;
                        animCopy.repeatCount = anim.repeatCount;
                        animCopy.repeatDuration = anim.repeatDuration;
                        animCopy.autoreverses = anim.autoreverses;
                        animCopy.fillMode = anim.fillMode;
                        
                        // We want our new animations to be instantaneous, so set the duration to zero.
                        // Also set both the begin time and time offset to 0.
                        animCopy.duration = 0;
                        animCopy.beginTime = 0;
                        animCopy.timeOffset = 0;
                        
                        [anims addObject:animCopy];
                    }
                }
                
                // Associate the gathered animations with each respective view
                [mapTable setObject:anims forKey:view];
            }
        }];
        
        // The completion block here gets run after the view controller transition animation completes (or fails)
        [coordinator animateAlongsideTransition:nil completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
            
            // Iterate over the mapTable's keys (views)
            for (UIView *view in mapTable.keyEnumerator) {
                
                // Get the modified animations for this view that we made when the interactive portion of the transition finished
                NSArray *anims = [mapTable objectForKey:view];
                
                // ... and add them back to the view's layer
                for (CABasicAnimation *anim in anims) {
                    [view.layer addAnimation:anim forKey:anim.keyPath];
                }
            }
        }];
    }
}


@end
