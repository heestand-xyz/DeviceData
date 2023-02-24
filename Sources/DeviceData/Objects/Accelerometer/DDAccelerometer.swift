import CoreMotion

public final class DDAccelerometer: DDObject {
    
    public var authorization: DDAuthorization { .notAvailable }
    
    public var available: Bool {
        motionEngine.manager.isAccelerometerAvailable
    }
    
    public var active: Bool {
        get {
            motionEngine.manager.isAccelerometerActive
        }
        set {
            if newValue {
                motionEngine.manager.startAccelerometerUpdates()
            } else {
                motionEngine.manager.stopAccelerometerUpdates()
            }
        }
    }
    
    @Published public var value: SIMD3<Double>?
    public var valuePublisher: Published<SIMD3<Double>?>.Publisher { $value }
    
    let motionEngine: DDMotionEngine
    
    public init(engine: DDMotionEngine) {
        motionEngine = engine
    }
}
