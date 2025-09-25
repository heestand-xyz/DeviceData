#if !os(tvOS)
import Combine
import CoreLocation

public final class DDLocationEngine: NSObject, DDEngine, @unchecked Sendable {
    
    private let manager: CLLocationManager
    
    public var location: PassthroughSubject<CLLocation, Never> = .init()
#if os(iOS)
    public var heading: PassthroughSubject<CLHeading, Never> = .init()
#endif
    
    public var authorization: CurrentValueSubject<CLAuthorizationStatus, Never>
    
    public var isAuthorized: Bool {
#if os(visionOS)
        [.authorizedWhenInUse].contains(authorization.value)
#elseif os(iOS)
        [.authorizedAlways, .authorizedWhenInUse].contains(authorization.value)
#elseif os(macOS)
        [.authorizedAlways].contains(authorization.value)
#endif
    }
    
    private var authorizationContinuation: CheckedContinuation<Void, Never>?
    
    public override init() {
        
        let manager = CLLocationManager()
        self.manager = manager
        
        authorization = .init(manager.authorizationStatus)
        
        super.init()
        
        manager.delegate = self
        
//        manager.pausesLocationUpdatesAutomatically = false
//        manager.allowsBackgroundLocationUpdates = true
    }
    
    public func authorizeIfNeeded() async -> Bool {
        if isAuthorized { return true }
        await withCheckedContinuation { continuation in
            authorizationContinuation = continuation
            manager.requestWhenInUseAuthorization()
        }
        authorizationContinuation = nil
        return isAuthorized
    }
    
    public func authorize() {
        manager.requestWhenInUseAuthorization()
    }
    
    @MainActor
    public func startAll() {
        startUpdatingLocation()
#if os(iOS)
        startUpdatingHeading()
#endif
    }
    
    @MainActor
    public func stopAll() {
        stopUpdatingLocation()
#if os(iOS)
        stopUpdatingHeading()
#endif
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
        if let authorizationContinuation {
            authorizationContinuation.resume()
        }
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
