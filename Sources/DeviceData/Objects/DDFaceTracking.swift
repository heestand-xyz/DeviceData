import Combine
import ARKit

public final class DDFaceTracking: DDObject {
    
    public var available: Bool {
        engine.available
    }
   
    public var authorization: CurrentValueSubject<DDAuthorization, Never> = .init(.unknown)
    
    public var active: CurrentValueSubject<Bool, Never> = .init(false)
    
    public var data: CurrentValueSubject<DDFaceTrack?, Never> = .init(nil)
    public var session: CurrentValueSubject<ARSession?, Never> = .init(nil)
    
    private let engine: DDFaceTrackingEngine
    
    private var cancelBag: Set<AnyCancellable> = []
    
    public init(engine: DDFaceTrackingEngine) {
        
        self.engine = engine
        
        active
            .sink { [weak self] active in
                guard let self else { return }
                if active {
                    engine.start()
                    self.session.value = engine.session
                } else {
                    self.session.value = nil
                    engine.stop()
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
                case .authorized:
                    self.authorization.value = .authorized
                @unknown default:
                    self.authorization.value = .unknown
                }
            }
            .store(in: &cancelBag)
        
        engine.cameraTransform.combineLatest(engine.faceAnchor)
            .map { cameraTransform, faceAnchor in
                DDFaceTrack(cameraTransform: cameraTransform, faceAnchor: faceAnchor)
            }
            .assign(to: \.data.value, on: self)
            .store(in: &cancelBag)
    }
    
    public func authorize() {
        engine.authorize()
    }
}
