import Combine
import CoreLocation

public final class DDLocationEngine: NSObject, DDEngine {
    
    private let manager: CLLocationManager
    
    public var location: PassthroughSubject<CLLocation, Never> = .init()
    public var heading: PassthroughSubject<CLHeading, Never> = .init()
    
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
    
    func authorize() {
        manager.requestAlwaysAuthorization()
    }
    
    func startUpdatingLocation() {
        manager.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        manager.stopUpdatingLocation()
    }
    
    func startUpdatingHeading() {
        manager.startUpdatingHeading()
    }
    
    func stopUpdatingHeading() {
        manager.stopUpdatingHeading()
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
    
    public func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        self.heading.send(newHeading)
    }
}
