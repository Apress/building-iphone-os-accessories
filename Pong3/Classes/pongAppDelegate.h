//
//  pongAppDelegate.h
//	Pong
//
//  Created by Ken Maskrey on 1/12/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@class pongViewController;

@interface pongAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    pongViewController *viewController;
	
	int	paddlePosition;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet pongViewController *viewController;

@property	int	paddlePosition;

@end

