import Combine
import CoreLocation

public final class DDLocationEngine: NSObject, DDEngine {
    
    private let manager: CLLocationManager
    
    public var coordinate: PassthroughSubject<CLLocationCoordinate2D, Never> = .init()
    
    public var authorization: CurrentValueSubject<CLAuthorizationStatus, Never>
    
    public override init() {
        
        let manager = CLLocationManager()
        self.manager = manager
        
        authorization = .init(manager.authorizationStatus)
        
        super.init()
        
        manager.delegate = self
    }
    
    func authorize() {
        manager.requestAlwaysAuthorization()
    }
    
    func startRequestingLocation() {
        manager.startUpdatingLocation()
    }
    
    func stopRequestingLocation() {
        manager.stopUpdatingLocation()
    }
}

extension DDLocationEngine: CLLocationManagerDelegate {
    
    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorization.value = manager.authorizationStatus
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let coordinate = locations.first?.coordinate else { return }
        self.coordinate.send(coordinate)
    }
}
