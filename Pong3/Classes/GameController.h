/*

GameController.h

*/

#import <Foundation/Foundation.h>
#import "pongAppDelegate.h"
#import <ExternalAccessory/ExternalAccessory.h>

@interface GameController : NSObject <EAAccessoryDelegate> {
    EAAccessory *_accessory;
    EASession *_session;
    NSString *_protocolString;

    NSMutableData *_writeData;
	
	pongAppDelegate	*appDelegate;
}

+ (GameController *)sharedController;

- (void)setupControllerForAccessory:(EAAccessory *)accessory withProtocolString:(NSString *)protocolString;

- (BOOL)openSession;
- (void)closeSession;

- (void)writeData:(NSData *)data;
- (void)_writeData;

// from EAAccessoryDelegate
- (void)accessoryDidDisconnect:(EAAccessory *)accessory;

@property (nonatomic, readonly) EAAccessory *accessory;
@property (nonatomic, readonly) NSString *protocolString;

@end
