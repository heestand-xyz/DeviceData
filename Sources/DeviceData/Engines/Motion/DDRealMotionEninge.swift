import Combine
import CoreMotion

public final class DDRealMotionEngine: DDMotionEngine {
    
    public var isAccelerometerAvailable: Bool {
        manager.isAccelerometerAvailable
    }
    
    public let accelerometerDataPassthroughSubject = PassthroughSubject<SIMD3<Double>, Never>()
    
    let manager: CMMotionManager
    
    public init() {
        manager = CMMotionManager()
    }
    
    public func startAccelerometerUpdates() {
        manager.startAccelerometerUpdates(to: .main) { [weak self] data, error in
            guard let self, error == nil, let data else { return }
            let vector = SIMD3(data.acceleration.x, data.acceleration.y, data.acceleration.z)
            accelerometerDataPassthroughSubject.send(vector)
        }
    }
    
    public func stopAccelerometerUpdates() {
        manager.stopAccelerometerUpdates()
    }
}
