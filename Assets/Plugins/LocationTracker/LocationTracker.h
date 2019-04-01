#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface LocationTracker : NSObject <CLLocationManagerDelegate>
    {
        NSMutableArray *history;
    }
+(instancetype) I;
-(NSString*) debugLocation;
-(CLLocationSpeed) debugSpeed;

-(void) setUnityCallback: (NSString*)gameObject: (NSString*)methodSetStatus: (NSString*)methodLocationUpdate;
-(void) startTracking: (float)minDistance;
-(void) stopTracking;

-(void) setBackgroundUpdateMode:(bool)inBackground;

-(char*) getHistoryFilePath;

-(void) reqAlwaysPermission;

@end
