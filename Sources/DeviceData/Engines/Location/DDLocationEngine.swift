#if !os(tvOS)
import Combine
import CoreLocation

public final class DDLocationEngine: NSObject, DDEngine {
    
    private let manager: CLLocationManager
    
    public var location: PassthroughSubject<CLLocation, Never> = .init()
#if os(iOS)
    public var heading: PassthroughSubject<CLHeading, Never> = .init()
#endif
    
    public var authorization: CurrentValueSubject<CLAuthorizationStatus, Never>
    
    public override init() {
        
        let manager = CLLocationManager()
        self.manager = manager
        
        authorization = .init(manager.authorizationStatus)
        
        super.init()
        
        manager.delegate = self
        
//        manager.pausesLocationUpdatesAutomatically = false
//        manager.allowsBackgroundLocationUpdates = true
    }
    
    public func authorize() {
        manager.requestWhenInUseAuthorization()
    }
    
    public func startUpdatingLocation() {
        manager.startUpdatingLocation()
    }
    
    public func stopUpdatingLocation() {
        manager.stopUpdatingLocation()
    }
    
#if os(iOS)
    public func startUpdatingHeading() {
        manager.startUpdatingHeading()
    }
    
    public func stopUpdatingHeading() {
        manager.stopUpdatingHeading()
    }
#endif
    
    public func checkLocation() {
        if let location = manager.location {
            self.location.send(location)
        }
    }
}

extension DDLocationEngine: CLLocationManagerDelegate {
    
    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorization.value = manager.authorizationStatus
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        self.location.send(location)
    }
    
#if os(iOS)
    public func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        self.heading.send(newHeading)
    }
#endif
}
#endif
