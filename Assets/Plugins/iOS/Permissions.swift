import Foundation
import CoreLocation

@objc class PermissionsPlugin: NSObject {
    
    @objc static var I: PermissionsPlugin = PermissionsPlugin()
    
    private let locationManager = CLLocationManager()
    
    @objc func requestPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
}
