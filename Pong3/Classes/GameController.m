/*

GameController.m
*/

#import "GameController.h"

@implementation GameController

@synthesize accessory = _accessory, protocolString = _protocolString;


#pragma mark -
#pragma mark Externally Accessed writeData Method 

- (void)writeData:(NSData *)data
{
    if (_writeData == nil) {
        _writeData = [[NSMutableData alloc] init];
    }
	
    [_writeData appendData:data];
    [self _writeData];
}

#pragma mark Instance Methods

- (void)_writeData {
    while (([[_session outputStream] hasSpaceAvailable]) && ([_writeData length] > 0))
    {
        NSInteger bytesWritten = [[_session outputStream] write:[_writeData bytes] maxLength:[_writeData length]];
        if (bytesWritten == -1)
        {
            NSLog(@"write error");
            break;
        }
        else if (bytesWritten > 0)
        {
             [_writeData replaceBytesInRange:NSMakeRange(0, bytesWritten) withBytes:NULL length:0];
        }
    }
}

#define EAD_INPUT_BUFFER_SIZE 128

- (void)_readData {
	
	//
	// get appDelegate (pongAppDelegate) so we can reference its properties
	//
	appDelegate = (pongAppDelegate *)[[UIApplication sharedApplication] delegate];
	
    uint8_t buf[EAD_INPUT_BUFFER_SIZE];

    while ([[_session inputStream] hasBytesAvailable])
    {
        NSInteger bytesRead = [[_session inputStream] read:buf maxLength:EAD_INPUT_BUFFER_SIZE];
       NSLog(@"read %d bytes (%d) from input stream", bytesRead,buf[0]);
		
		// for now, we only expect two different command bytes from the accesssory
		// 0x10 - means that the pushbutton was pressed and no additional data follows
		// 0x20 - means that the knob (potentiometer) has changed position and an
		//        additional  byte follows which represents the knob's position
		if (buf[0] == 0x10) {
			[[NSNotificationCenter	defaultCenter] postNotificationName:@"PBPRESSED" object:self];	// no user data

		}
		if (buf[0] == 0x20) {
			//NSData *data = [[NSData alloc] initWithBytes:buf	length:bytesRead];
			
			//NSLog(@"Data = %@",data);	
			unsigned char i = buf[1];
		//	NSNumber *posInt = [[NSNumber alloc] initWithUnsignedChar:i];
		//	NSLog(@"_readData position = %d",[posInt intValue]);
			appDelegate.paddlePosition = i;
			
		//	NSMutableDictionary *dict = [[ NSMutableDictionary alloc]		// we use a dictionary to send it via notification center
		//								 init];
		//	[ dict	setObject:posInt forKey:@"parameter"];
		//	[[NSNotificationCenter	defaultCenter] postNotificationName:@"POTTURNED" object:self userInfo:dict];
			[[NSNotificationCenter	defaultCenter] postNotificationName:@"POTTURNED" object:self ];

		//	[dict release];	
		//	[posInt	release];
		}				
    }
}

#define EAD_INPUT_BUFFER_SIZE 128


+ (GameController *)sharedController
{
    static GameController *accessoryController = nil;
    if (accessoryController == nil) {
        accessoryController = [[GameController alloc] init];
    }
	
    return accessoryController;
}


#pragma mark -
#pragma mark Internal Methods

- (void)setupControllerForAccessory:(EAAccessory *)accessory withProtocolString:(NSString *)protocolString
{
    [_accessory release];
    _accessory = [accessory retain];
    [_protocolString release];
    _protocolString = [protocolString copy];
}

- (BOOL)openSession
{
    [_accessory setDelegate:self];
    _session = [[EASession alloc] initWithAccessory:_accessory forProtocol:_protocolString];
    //_session = [[EASession alloc] initWithAccessory:_accessory forProtocol:@"COM.MACMEDX.P1"];

    if (_session)
    {
        [[_session inputStream] setDelegate:self];
        [[_session inputStream] scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [[_session inputStream] open];

        [[_session outputStream] setDelegate:self];
        [[_session outputStream] scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [[_session outputStream] open];
    }
    else
    {
        NSLog(@"creating session failed");
    }

    return (_session != nil);
}

- (void)closeSession
{
    [[_session inputStream] close];
    [[_session inputStream] removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [[_session inputStream] setDelegate:nil];
    [[_session outputStream] close];
    [[_session outputStream] removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [[_session outputStream] setDelegate:nil];
	
	_session = nil;
    [_session release];
    
}



- (void)accessoryDidDisconnect:(EAAccessory *)accessory
{
	NSLog(@"Controller Removed");
}

#pragma mark NSStreamDelegateEventExtensions

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
{
    switch (eventCode) {
        case NSStreamEventNone:
            NSLog(@"stream %@ event none", aStream);
            break;
        case NSStreamEventOpenCompleted:
            NSLog(@"stream %@ event open completed", aStream);
            break;
        case NSStreamEventHasBytesAvailable:
            NSLog(@"stream %@ event bytes available", aStream);
            [self _readData];
            break;
        case NSStreamEventHasSpaceAvailable:
            NSLog(@"stream %@ event space available", aStream);
            [self _writeData];
            break;
        case NSStreamEventErrorOccurred:
            NSLog(@"stream %@ event error", aStream);
            break;
        case NSStreamEventEndEncountered:
            NSLog(@"stream %@ event end encountered", aStream);
            break;
        default:
            break;
    }
}

#pragma mark -
#pragma mark Basic Object Methods

- (void)dealloc
{
    [self closeSession];
    [self setupControllerForAccessory:nil withProtocolString:nil];
    _writeData = nil;
	[_writeData release];
    
    
    [super dealloc];
}


@end
