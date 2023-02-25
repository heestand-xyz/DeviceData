import Combine
import CoreLocation

public final class DDLocation: DDObject {
    
    public var available: Bool { true }
    
    public var authorization: CurrentValueSubject<DDAuthorization, Never> = .init(.unknown)
    
    public var active: CurrentValueSubject<Bool, Never> = .init(false)
    
    public var data: CurrentValueSubject<CLLocationCoordinate2D?, Never> = .init(nil)
    
    private let engine: DDLocationEngine
    
    private var cancelBag: Set<AnyCancellable> = []
    
    public init(engine: DDLocationEngine) {
        
        self.engine = engine
        
        active
            .sink { [weak self] active in
                if active {
                    self?.engine.startRequestingLocation()
                } else {
                    self?.engine.stopRequestingLocation()
                }
            }
            .store(in: &cancelBag)
        
        engine.authorization
            .sink { [weak self] status in
                guard let self else { return }
                switch status {
                case .notDetermined:
                    self.authorization.value = .notDetermined
                case .restricted:
                    self.authorization.value = .restricted
                case .denied:
                    self.authorization.value = .denied
                case .authorizedAlways:
                    self.authorization.value = .authorizedAlways
                case .authorizedWhenInUse:
                    self.authorization.value = .authorizedWhenInUse
                @unknown default:
                    self.authorization.value = .unknown
                }
            }
            .store(in: &cancelBag)
        
        engine.coordinate
            .map { $0 }
            .assign(to: \.data.value, on: self)
            .store(in: &cancelBag)
    }
    
    public func authorize() {
        engine.authorize()
    }
}
