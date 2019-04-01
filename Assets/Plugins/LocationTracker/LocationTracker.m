#import "LocationTracker.h"

@implementation LocationTracker {
    CLLocationManager* locationManager;
    CLLocation* previousLocation;
    CLLocation* currentLocation;
    NSString* gameObject;
    NSString* methodSetStatus;
    NSString* methodLocationUpdate;
    bool backgroundUpdateMode;
    float liveDistanceFilter;
    // debugging
    CLLocationSpeed debugSpeed;
    NSString* debugLocation;
}
-(NSString*) debugLocation { return debugLocation; }
-(CLLocationSpeed) debugSpeed { return debugSpeed; }
#pragma mark Singleton
+ (instancetype) I
    {
        static LocationTracker *sharedInstance = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            sharedInstance = [[LocationTracker alloc] init];
        });
        return sharedInstance;
    }
    
+(NSString*) getHistoryFilePathStr
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *docDir = [paths objectAtIndex:0];
        
        NSString *filePath = [docDir stringByAppendingPathComponent:@"history.json"];
        
        return filePath;
    }
    
-(void) setUnityCallback: (NSString*)gameObject: (NSString*)methodSetStatus: (NSString*)methodLocationUpdate
    {
        NSLog(@"########## %@", gameObject);
        self->gameObject = gameObject;
        self->methodSetStatus = methodSetStatus;
        self->methodLocationUpdate = methodLocationUpdate;
    }
    
-(void) setStatus: (NSString*)status
    {
        UnitySendMessage(
                         [self NSStringToUnityString: gameObject],
                         [self NSStringToUnityString: methodSetStatus],
                         [self NSStringToUnityString: status]
                         );
    }
    
-(void) sendLocation: (NSString*)locationString speed: (double)speed
    {
        // debugging
        debugLocation = [NSString stringWithFormat: @"%@\n%@", debugLocation, locationString];
        debugSpeed = speed;
        NSLog(@"# New coordinates %f, %f, %f, speed: %f", currentLocation.coordinate.latitude, currentLocation.coordinate.longitude, currentLocation.altitude, speed);
        
        UnitySendMessage(
                         [self NSStringToUnityString: gameObject],
                         [self NSStringToUnityString: methodLocationUpdate],
                         [self NSStringToUnityString: locationString]
                         );
    }
    
    ///  live location tracking  ///
    
-(void) startTracking: (float)minDistance
    {
        [self setStatus: @"Initializing"];
        liveDistanceFilter = minDistance;
        
        locationManager = [CLLocationManager new];
        locationManager.delegate = self;
        locationManager.distanceFilter = backgroundUpdateMode ? 8 : liveDistanceFilter; // meters
        locationManager.desiredAccuracy = kCLLocationAccuracyBest; // this is the second best possible accuracy
        locationManager.allowsBackgroundLocationUpdates = backgroundUpdateMode;
        locationManager.pausesLocationUpdatesAutomatically = NO;
        
        [locationManager startUpdatingLocation];
        [self setStatus: @"Running"];
        
        NSLog(@"Started tracking location with min distance %f meters", locationManager.distanceFilter);
    }
    
-(void) stopTracking
    {
        [locationManager stopUpdatingLocation];
        if (backgroundUpdateMode) {
            [self saveJson];
        }
        [self setStatus: @"Stopped"];
    }
    
    ///  bg location tracking  ///
    
-(void) setBackgroundUpdateMode: (bool)inBackground
    {
        backgroundUpdateMode = inBackground;
        if (locationManager == nil) {
            [self startTracking: liveDistanceFilter];
        } else {
            locationManager.allowsBackgroundLocationUpdates = inBackground;
            locationManager.distanceFilter = backgroundUpdateMode ? 8 : liveDistanceFilter;
            [locationManager startUpdatingLocation];
        }
        
        NSLog(@"Switched tracking location mode. Min distance is now %f meters", locationManager.distanceFilter);
        
        if (inBackground) {
            history = [[NSMutableArray alloc] init];
        } else {
            [self saveJson];
        }
    }
    
-(char*) getHistoryFilePath
    {
        NSString *path = [LocationTracker getHistoryFilePathStr];
        
        return [self NSStringToUnityString: path];
    }
    
-(NSString*) saveJson
    {
        NSString *path = [LocationTracker getHistoryFilePathStr];
        
        if (history == nil) {
            printf("Not saving json - history is null\n");
            return path;
        }
        
        NSError *error = nil;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject: history
                                                           options: NSJSONWritingPrettyPrinted
                                                             error:&error];
        if (error != nil) {
            NSLog(@"Serialize error: %@ %@", error, [error userInfo]);
        }
        
        NSString *jsonString = [[NSString alloc] initWithData: jsonData
                                                     encoding: NSUTF8StringEncoding];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
            NSLog(@"\ncreating history.json file at %@\n", path);
            [[NSFileManager defaultManager] createFileAtPath: path contents:nil attributes:nil];
        }
        
        [jsonString writeToFile: path
                     atomically: NO
                       encoding: NSUTF8StringEncoding
                          error:&error];
        if (error != nil) {
            NSLog(@"Saving error: %@ %@", error, [error userInfo]);
        }
        
        return path;
    }
    
    
    ///  location update callback  ///
    
-(void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
    {
        if (previousLocation == nil) {
            previousLocation = currentLocation;
        }
        
        currentLocation = [locations objectAtIndex:0];
        // calculate speed
        double distance = [currentLocation distanceFromLocation: previousLocation];
        double timeDelta = currentLocation.timestamp.timeIntervalSince1970 - previousLocation.timestamp.timeIntervalSince1970;
        double speed = distance / timeDelta;
        
        NSNumber* timestamp = [NSNumber numberWithDouble: [[NSDate date] timeIntervalSince1970] ];
        NSString* locationString = [NSString stringWithFormat:
                                    @"%f;%f;%.1f;%.5f;%d",
                                    currentLocation.coordinate.latitude, currentLocation.coordinate.longitude, currentLocation.altitude, speed, [timestamp intValue]
                                ];
        
        if (manager.allowsBackgroundLocationUpdates) {
            // background updates stored for later
            [history addObject: locationString];
            
            NSLog(@"# New coordinates in bg %f, %f, %f", currentLocation.coordinate.latitude, currentLocation.coordinate.longitude, currentLocation.altitude);
            
        } else {
            // live updates for geopet
            [self sendLocation:locationString speed:speed];
        }
        
        previousLocation = currentLocation;
        
    }
    
    // helper methods
    
-(bool) haveAlwaysPermission
    {
        return [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways;
    }
-(bool) haveWhenInUsePermission
    {
        CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
        return status == kCLAuthorizationStatusAuthorizedWhenInUse || status == kCLAuthorizationStatusAuthorizedAlways;
    }
    
-(char*) NSStringToUnityString:(NSString*) string
    {
        const char* cString = string.UTF8String;
        char* _unityString = (char*)malloc(strlen(cString) + 1);
        strcpy(_unityString, cString);
        return _unityString;
    }

    
    // for debugging
// -(void) reqAlwaysPermission
//     {
//         printf("req always?\n");
//         if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedAlways) {
//             if (locationManager == nil) {
//                 locationManager = [CLLocationManager new];
//             }
//             printf("requesting always\n");
//             [locationManager requestAlwaysAuthorization];
//         }
//     }
@end
