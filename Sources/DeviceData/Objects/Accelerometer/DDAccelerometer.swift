import Combine
import CoreMotion

public final class DDAccelerometer: DDObject {
    
    public var available: Bool {
        motionEngine.manager.isAccelerometerAvailable
    }
    
    @Published public var authorization: DDAuthorization = .notAvailable
    public var authorizationPublisher: Published<DDAuthorization>.Publisher { $authorization }
    
    @Published public var active: Bool = false {
        didSet {
            guard available else { return }
            if active {
                motionEngine.manager.startAccelerometerUpdates()
            } else {
                motionEngine.manager.stopAccelerometerUpdates()
                value = nil
            }
        }
    }
    public var activePublisher: Published<Bool>.Publisher { $active }
    
    @Published public var value: CMAccelerometerData?
    public var valuePublisher: Published<CMAccelerometerData?>.Publisher { $value }
    
    let motionEngine: DDMotionEngine
    
    private var cancelBag: Set<AnyCancellable> = []
    
    public init(engine: DDMotionEngine) {
        
        motionEngine = engine
        
        motionEngine.manager.accelerometerData.publisher
            .map { $0 }
            .assign(to: \.value, on: self)
            .store(in: &cancelBag)
    }
}
