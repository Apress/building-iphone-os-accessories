//
//  PongViewController.h
//
//


#import <UIKit/UIKit.h>
#include <AudioToolbox/AudioToolbox.h>
#import <ExternalAccessory/ExternalAccessory.h>
#import "GameController.h"
#import "pongAppDelegate.h"


@interface pongViewController : UIViewController {
	
	pongAppDelegate	*appDelegate;

	
	EAAccessory *_accessory;
    NSMutableArray *_accessoryList;
	
    EAAccessory *_selectedAccessory;
    GameController *_accessoryController;
	

	//
	//	Define the outlets that will be updated
	//  as the game progresses
	//
	IBOutlet UIImageView *ball;
	IBOutlet UIImageView *playerPaddle;
	IBOutlet UIImageView *compPaddle;
	IBOutlet UILabel	*playerScoreView;
	IBOutlet UILabel	*compScoreView;
	IBOutlet UILabel	*winOrLoseView;
	
	
	//******************************************************
	//
	//   GENERAL NOTES ON THE PROPERTIES AND METHODS BELOW
	//
	//   Most, if not all, of the stuff below could be
	//   defined as simple instance variables within the 
	//   the pongViewController and does not need to be
	//   defined here, in the interface section. While
	//   this would create slimmer (and probably better)
	//   code, I chose to put it here to force the condition
	//   that all properties be defined as accessable.
	//   Remeber, this portion of the book describes a self-
	//   contained, touch-activated game, but we are planning
	//   to incorporate an additional controller to access
	//   the game controller accessory. So we want to make
	//   the pongViewController more open to expansion and
	//   by putting things here, in the interface, we are 
	//   acting in a more foreward-looking manner.
	//******************************************************
	
	//
	//	ballSpeed - the X and Y velocity of the ball.
	//	-- we use a CGPoint which is just a struct with two
	//     floats (x and y) as its elements. We then just set
	//     the x and y values to the speed.
	//     Y is defined as movement along the vertical axis between
	//     the player and the computer.
	//     X is defined as the side-to-side movement
	//
	CGPoint ballSpeed;
	
	
	
	//
	//  These are the images we're going to use for the player's paddle.
	//  In a very simple game, we would just use a rectangle, but here we
	//  do a couple of unique things. We flip the paddle (left-right) as
	//  it moves to either side of the centerline...to simulate forehand-
	//  backhand action (playerPaddleLeft and playerPaddleRight). Also.
	//  if we're at either edge of the table, in a real game we would angle
	//  the paddle more to bring it back into play. In this case, we "tilt"
	//  the image of the paddle a bit to simulate this (playerPaddleLeftUp and
	//  playerPaddleRightUp).
	//
	UIImage		*playerPaddleLeft;
	UIImage		*playerPaddleLeftUp;
	UIImage		*playerPaddleRight;
	UIImage		*playerPaddleRightUp;
	
	//
	// Thse are some basic variables to keep track of things.
	//
	NSUInteger	playerScore;
	NSUInteger	compScore;
	NSUInteger	status;

	//
	//	We need these for handling the sound that the program generates
	//
	CFURLRef			paddleSoundFileURLRef;
	SystemSoundID		paddleSoundObject;
}
@property (readwrite)    CFURLRef        paddleSoundFileURLRef;
@property (readonly)    SystemSoundID    paddleSoundObject;

@property (nonatomic,retain) IBOutlet UIImageView *ball;
@property (nonatomic,retain) IBOutlet UIImageView *playerPaddle;
@property (nonatomic,retain) IBOutlet UIImageView *compPaddle;
@property (nonatomic,retain) UILabel	*playerScoreView;
@property (nonatomic,retain) UILabel	*compScoreView;
@property (nonatomic,retain) UILabel	*winOrLoseView;


@property(nonatomic) CGPoint ballSpeed;
@property(nonatomic) NSUInteger	status;

@property	(nonatomic,retain) UIImage	*playerPaddleLeft;
@property	(nonatomic,retain) UIImage	*playerPaddleLeftUp;
@property	(nonatomic,retain) UIImage	*playerPaddleRight;
@property	(nonatomic,retain) UIImage	*playerPaddleRightUp;



@property NSUInteger	playerScore;
@property NSUInteger	compScore;

//
//  The object's method calls 
//  serveAction is initated by a user action (pressing the button)
//  
-(IBAction) serveAction;

//
//	LED Control Routines
//
- (void)turnOnRedLED;
- (void)turnOffRedLED;
- (void)turnOnGreenLED;
- (void)turnOffGreenLED;
@end

