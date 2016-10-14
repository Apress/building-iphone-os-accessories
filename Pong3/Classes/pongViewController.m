//
//  PongViewController.m
//
//

#import "pongViewController.h"

//
//	State Variables used by
//	compPlay method to determine
//  actions to take depending on
//  where we are in the game.
//
#define	NOT_STARTED			0
#define	IN_PLAY				1
#define	POINT_OVER			2
#define	GAME_OVER			3

//
//	Points to win the game
//  I use 5 here to make the game
//  go by quickly
//
#define	GAME_WON			5

//
//	Speed of the ball in both
//  the x and y directions. 
//
#define	BALL_DELTA_X		5
#define	BALL_DELTA_Y		10

//
//	Starting position of the ball.
//  Roughly the center of the table
//
#define BALL_STARTING_X		160.0
#define BALL_STARTING_Y		220.0

//
//  defines the performance
//  of the computer player.
//  higher number equals better
//  computer player
//
#define COMP_REACTION_TIME		15

//
//  COMP_SETUP_TIME is a variable
//  that also determines computer
//  performace. In general, it adjusts
//  how soon the computer reacts by
//  adding y-position info to the
//  check of where the ball is.
//
#define COMP_SETUP_TIME			40

//
//  WALL_MARGIN adds a delta distance
//  from the edges of the wall to check
//  when to "bounce" the ball. If it were
//  not added, then the ball might look like
//  it went "into" the wall before bouncing.
//
#define WALL_MARGIN				5

@implementation pongViewController

//
// Use @synthesis to create all the
// necessary getters and setters
//
@synthesize ball;
@synthesize playerPaddle;
@synthesize compPaddle;

@synthesize ballSpeed;
@synthesize	status;
@synthesize playerPaddleLeft;
@synthesize playerPaddleLeftUp;
@synthesize playerPaddleRight;
@synthesize playerPaddleRightUp;

@synthesize playerScore;
@synthesize playerScoreView;
@synthesize compScore;
@synthesize compScoreView;
@synthesize winOrLoseView;

@synthesize paddleSoundFileURLRef;
@synthesize paddleSoundObject;


//
//	INSTANCE VARIABLES
//
BOOL	redLEDOn	= NO;
BOOL	greenLEDOn	= NO;

//
//	setServePosition
//  Place the ball at approximately the center of the table
//  for the serve.
//	-- the ball's center position and speed are both structs
//     containing an X and Y value. This way, what we call
//     speed is really just the delta position added to the 
//     ball at each call of the timer expiration.
//
-(void) setServePosition {
	ball.center	= CGPointMake(BALL_STARTING_X, BALL_STARTING_Y);
	ballSpeed = CGPointMake(BALL_DELTA_X, -BALL_DELTA_Y);
}

//
//	compPlay - adjust the computer's paddle position to meet the ball
//  This is basically the only AI in the program and it's just moving
//  the comp's paddle towards the ball at a certain speed. Really,
//  if the player is very, very lucky and has gotten a good angle on his
//  return *and* the computer's paddle is at the extreme other side of the
//  table, then it might just NOT make it to the ball in time and the
//  player will score a point.
//
-(void) compPlay {

	if(ball.center.y <= self.view.center.y + COMP_SETUP_TIME)    {	// is ball on computer's side of court ?
		if(ball.center.x < compPaddle.center.x) {					// does computer need to move racquet ?
			CGPoint compLocation = CGPointMake(compPaddle.center.x - COMP_REACTION_TIME, compPaddle.center.y);
			compPaddle.center = compLocation;
		}
		if(ball.center.x > compPaddle.center.x) {
			CGPoint compLocation = CGPointMake(compPaddle.center.x + COMP_REACTION_TIME, compPaddle.center.y);
			compPaddle.center = compLocation;
		}
	}
}

//
//	gameLoop - the heart of the game
//	
//	This is called at every expiration of the NSTimer interval that we set at startup time
//	Typically, in this type of design, the first thing to do is check all the boundary conditions:
//  has the ball hit an edge of something (the room), has a point been scored, is the game over,
//  has the ball connected with the player's or computer's paddle.
//  Note that all the code in the entire function is contigent on the game status being IN_PLAY. This
//  should be obvious that we only want the automatic part of the system to update if we're in the
//  middle of play. In any other state (NOT STARTED, GAME WON, POINT OVER) the player should determine
//  things (SERVE or not).
//	
//	Note also that this method also sets the game's status:
//  (1) If the ball is past the player's end, the computer has scored and we set POINT_OVER
//  (2) Similarly, if the ball is past the computer's end, the player scored and POINT_OVER as well.
//  (3) If the point total of a player is equal to the constant GAME_WON, we set status = GAME_OVER
//  (4) NOT_STARTED is set at startup in the viewDidLoad method.
//
-(void)gameLoop {
	
	if(status == IN_PLAY) {
		ball.center = CGPointMake(ball.center.x + ballSpeed.x, ball.center.y + ballSpeed.y); // move the ball
		
		//
		//	If we turned on an LED in the last loop, then turn it off now
		//
		if (redLEDOn) {
			[self	turnOffRedLED];
			redLEDOn	= NO;
		}
		if (greenLEDOn) {
			[self	turnOffGreenLED];
			greenLEDOn	= NO;
		}
		
		// Has the ball hit the edge of the room ?
		if (ball.center.x > (self.view.bounds.size.width - WALL_MARGIN) || ball.center.x < (0 + WALL_MARGIN)) {
			ballSpeed.x  = - ballSpeed.x;
		}
		
		if (ball.center.y > self.view.bounds.size.height || ball.center.y < 0) {
			ballSpeed.y = - ballSpeed.y;
		}
		
		// player scored against computer
		if (ball.center.y < 0) {
			// set status to hold
			status = POINT_OVER;
			playerScore++;
			playerScoreView.text = [NSString stringWithFormat:@"%d",playerScore];
			if (playerScore == GAME_WON)
			{
				winOrLoseView.text = @"YOU WIN";
				playerScore = 0;
				compScore   = 0;
				status		= GAME_OVER;
			}
			[self	setServePosition];

		} else 
		// if player didn't score, did the computer score?
			
			if (ball.center.y > self.view.bounds.size.height) {
				// set status to hold
				status = POINT_OVER;
				compScore++;
				compScoreView.text = [NSString stringWithFormat:@"%d",compScore];
				if (compScore == GAME_WON)
				{
					winOrLoseView.text = @"YOU LOSE";
					playerScore = 0;
					compScore   = 0;
					status		= GAME_OVER;
				}
				[self	setServePosition];
			}			
			
		
		// Did the player's paddle make contact with the ball
		if(CGRectIntersectsRect(ball.frame, playerPaddle.frame)) {
			
			
			
			AudioServicesPlaySystemSound (self.paddleSoundObject);
			
			// Reverse front-to-back direction
			if(ball.center.y < playerPaddle.center.y) {
				ballSpeed.y = -ballSpeed.y;
			}
			
			// Reverse the X direction if we're off to one side of the table
			if  ( (ball.center.x > (self.view.bounds.size.width /2)+100) ||
				 (ball.center.x < (self.view.bounds.size.width /2)-100) )
			{
				// if we just reverse the delta-x, then we might get hung in a loop
				// so add a little offset from where the ball is to the center of the paddle
				
				ballSpeed.x = -ballSpeed.x + (ball.center.x - playerPaddle.center.x)/5;
			}
			//[self	turnOnRedLED];
		}
	

		// Did the computer's paddle make contact withthe ball
		if(CGRectIntersectsRect(ball.frame,	compPaddle.frame)) {
			
			
			AudioServicesPlaySystemSound (self.paddleSoundObject);
			
			// Reverse front-to-back direction
			if(ball.center.y > compPaddle.center.y) {
				ballSpeed.y = -ballSpeed.y;
				// each time the computer hits the ball, speed it up
				ballSpeed.y++;
			}
			
			
			// Let's change the X (side-to-side) direction if we're near the edge of the table
			if  ( (ball.center.x > (self.view.bounds.size.width /2)+100) ||
				 (ball.center.x < (self.view.bounds.size.width /2)-100) )
				ballSpeed.x = -ballSpeed.x;
			//[self	turnOnGreenLED];
		}
		//
		//	Move the player's paddle
		//
		int i = appDelegate.paddlePosition;
		NSLog(@"Position Received = %d",i);
		
		i = (-i + 256);
		
		float j = (float)i * (320.0/246.0);
		
		CGPoint xLocation = CGPointMake(j,playerPaddle.center.y);
		playerPaddle.center = xLocation;
		if (playerPaddle.center.x > (self.view.bounds.size.width /2))
			if (playerPaddle.center.x > (self.view.bounds.size.width /2)+101)
				playerPaddle.image = playerPaddleRightUp;
			else 
				playerPaddle.image = playerPaddleRight;
			else 
				if (playerPaddle.center.x < (self.view.bounds.size.width /2)-101)
					playerPaddle.image = playerPaddleLeftUp;
				else 
					playerPaddle.image = playerPaddleLeft;
		//
		//
		//	Here is the only real action that this method does.
		//	If none of the above conditions are met, then call
		//  the AI method that moves the computer's paddle towards
		//  the ball.
		//
		[self compPlay];
	} // end if
}

//
//	touchesBegan is the method that gets called when the player
//  interacts with the game (touches the screen to move his paddle).
//  this iis just the method called by the system, and if the game
//  status is IN_PLAY, then our routine touchesMoved is called to
//  intercept and move the player's paddle.
//  REALLY, this is just a gateway that only allows the player
//  to move the paddle if the game is in play.
//
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	if (status == IN_PLAY) {
		[self touchesMoved:touches withEvent:event];
	}
}

//
//	serveAction - Basically, this starts the game.
//  (1) Clear any startup text in the game window
//  (2) Initialize the scores
//  (3) change game status
//  (4) make a serve sound
//
//	Note that this method really doesn't "serve" the ball. It
//  merely changes game status so that the next time the NSTimer
//  "fires", the gameLoop actually runs.
//
-(void)serveAction {
	winOrLoseView.text = @"";

	if (status == GAME_OVER) {
		compScoreView.text	= [NSString stringWithFormat:@"%d",0];
		playerScoreView.text	= [NSString stringWithFormat:@"%d",0];
	}
	status = IN_PLAY;

	AudioServicesPlaySystemSound (self.paddleSoundObject);


}
	
//
//	touchesMoved:withEvent:
//	This routine moves the player's paddle to the point on the
//  playing surface that he has placed his finger. NOTE that this
//  has the unnatural effect of instantly positioning his paddle
//  which is generally not how you want to play the game.
//  Also, depending on where the paddle is positioned (left or right)
//  or at the edges of the table, we change the image used by the player's
//  paddle to simulate forehand-backhand or to an angled shot back
//  into the game. We do not do this for the computer's paddle
//
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [[event allTouches] anyObject];	// returns one of the obects in the set of all touches
	CGPoint location = [touch locationInView:touch.view];
	CGPoint xLocation = CGPointMake(location.x,playerPaddle.center.y);
	//playerPaddle.center = xLocation;
	if (playerPaddle.center.x > (self.view.bounds.size.width /2))
		if (playerPaddle.center.x > (self.view.bounds.size.width /2)+101)
			playerPaddle.image = playerPaddleRightUp;
		else 
			playerPaddle.image = playerPaddleRight;
	else 
		if (playerPaddle.center.x < (self.view.bounds.size.width /2)-101)
			playerPaddle.image = playerPaddleLeftUp;
		else 
			playerPaddle.image = playerPaddleLeft;
}


// 
//	viewDidLoad - we use this to initalize our sytem.
//	(1) Loads the images from the bundle to use for our variable player's paddle
//  (2) Displays the game name on the playing field
//  (3) Gets the sound file for the ball
//  (4) initializes the score to 0-0
//  (5) sets the game status to NOT_STARTED -- note that this is the only time
//      the game is in this condition
//  (6) set the serve position of the ball
//  (7) setup and start the timer
//
//	Note that for the game to actually start, the status must change to IN_PLAY
//  and that is only done by the serveAction method which fires when the player
//  taps the SERVE button --**** AND ***--- soon when the game controller's
//  serve button is pressed.
//
- (void)viewDidLoad {
	
	[[UIApplication sharedApplication] setIdleTimerDisabled:YES];			// disable sleep dimming
	//
	// get appDelegate (pongAppDelegate) so we can reference its properties
	//
	appDelegate = (pongAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accessoryConnected:) name:EAAccessoryDidConnectNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accessoryDisconnected:) name:EAAccessoryDidDisconnectNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pbPressed:) name:@"PBPRESSED" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(potTurned:) name:@"POTTURNED" object:nil];
	[[EAAccessoryManager sharedAccessoryManager] registerForLocalNotifications];

	if ([[[EAAccessoryManager	sharedAccessoryManager]	connectedAccessories] count] > 0) {
		NSLog(@"Connected accessories");
	} else {
		NSLog(@"NO Connected accessories");
	}
	
	
	_accessoryController = [GameController sharedController];
	_accessoryList	= [[NSMutableArray alloc] initWithArray:[[EAAccessoryManager sharedAccessoryManager] connectedAccessories]];
	

	

	playerPaddleLeft	= [UIImage imageNamed:@"playerPaddleLeft.png"];
	playerPaddleLeftUp	= [UIImage imageNamed:@"playerPaddleLeftUp.png"];
	playerPaddleRight	= [UIImage imageNamed:@"playerPaddleRight.png"];
	playerPaddleRightUp = [UIImage	imageNamed:@"playerPaddleRightUp.png"];
	
	winOrLoseView.text = @"PONG!";

	
	// SET UP SOUNDS
    CFBundleRef mainBundle;
    mainBundle = CFBundleGetMainBundle ();
    
    // Get the URL to the sound file to play
    paddleSoundFileURLRef  =    CFBundleCopyResourceURL (
												  mainBundle,
												  CFSTR ("paddleSound"),
												  CFSTR ("aif"),
												  NULL
												  );
    AudioServicesCreateSystemSoundID (
									  paddleSoundFileURLRef,
									  &paddleSoundObject
									  );

	playerScore	= 0;
	compScore	= 0;
	
	status = NOT_STARTED;
	[self setServePosition];
	[NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(gameLoop) userInfo:nil repeats: YES];
    [super viewDidLoad];
}



//
//	The rest of the code is generated by Xcode and should
//  be setup in a "real" production level game.
//
- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	[[UIApplication sharedApplication] setIdleTimerDisabled:NO];			// enable sleep dimming

	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];

}

#pragma mark -
#pragma mark Accessory Methods

-(void) pbPressed:(NSNotification *)notification {
	NSLog(@"Pushbutton Pressed");
	[self	serveAction];
}

-(void) potTurned:(NSNotification *)notification {
	NSLog(@"Pot Turned");
	//NSNumber	 *position = [[notification userInfo] objectForKey:@"parameter"];
	
	//int i = [position intValue];
	int i = appDelegate.paddlePosition;
	NSLog(@"Position Received = %d",i);

	i = (-i + 256);
	
	float j = (float)i * (320.0/246.0);
	
	CGPoint xLocation = CGPointMake(j,playerPaddle.center.y);
	playerPaddle.center = xLocation;
	if (playerPaddle.center.x > (self.view.bounds.size.width /2))
		if (playerPaddle.center.x > (self.view.bounds.size.width /2)+101)
			playerPaddle.image = playerPaddleRightUp;
		else 
			playerPaddle.image = playerPaddleRight;
		else 
			if (playerPaddle.center.x < (self.view.bounds.size.width /2)-101)
				playerPaddle.image = playerPaddleLeftUp;
			else 
				playerPaddle.image = playerPaddleLeft;
	
}

#pragma mark -
#pragma mark LED Routines


- (void)turnOnRedLED
{
    const uint8_t buf[2] = {0x98, 0x01};
    [[GameController sharedController] writeData:[NSData dataWithBytes:buf length:2]];
	redLEDOn = YES;
}

- (void)turnOffRedLED
{
    const uint8_t buf[2] = {0x98, 0x02};
    [[GameController sharedController] writeData:[NSData dataWithBytes:buf length:2]];
}
- (void)turnOnGreenLED
{
    const uint8_t buf[2] = {0x98, 0x03};
    [[GameController sharedController] writeData:[NSData dataWithBytes:buf length:2]];
	greenLEDOn = YES;
}

- (void)turnOffGreenLED
{
    const uint8_t buf[2] = {0x98, 0x04};
    [[GameController sharedController] writeData:[NSData dataWithBytes:buf length:2]];
}

- (void)accessoryConnected:(NSNotification *)notification {
	
	NSLog(@"Game Controller Connected");
	
    EAAccessory *connectedAccessory = [[notification userInfo] objectForKey:EAAccessoryKey];
    [_accessoryList addObject:connectedAccessory];
	_selectedAccessory = [[_accessoryList objectAtIndex:0] retain];			// select the accessory from the "list" which is only one element
	
	[_accessoryController setupControllerForAccessory:_selectedAccessory withProtocolString:[[_selectedAccessory protocolStrings] objectAtIndex:0]];
	[_accessoryController openSession];
	
}

- (void)accessoryDisconnected:(NSNotification *)notification {
	
	NSLog(@"Game Controller Disconnected");
	
    EAAccessory *disconnectedAccessory = [[notification userInfo] objectForKey:EAAccessoryKey];
	
    int disconnectedAccessoryIndex = 0;
    for(EAAccessory *accessory in _accessoryList) {
        if ([disconnectedAccessory connectionID] == [accessory connectionID]) {
            break;
        }
        disconnectedAccessoryIndex++;
    }
	
    if (disconnectedAccessoryIndex < [_accessoryList count]) {
        [_accessoryList removeObjectAtIndex:disconnectedAccessoryIndex];
    } else {
        NSLog(@"could not find disconnected accessory in accessory list");
    }
}


@end
