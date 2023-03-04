import Combine
import CoreMotion

public final class DDRealMotionEngine: DDMotionEngine {
    
    public var isAccelerometerAvailable: Bool {
        manager.isAccelerometerAvailable
    }
    public var isGyroscopeAvailable: Bool {
        manager.isGyroAvailable
    }
    
    public let accelerometerDataPassthroughSubject: PassthroughSubject<SIMD3<Double>, Never> = .init()
    public var gyroscopeDataPassthroughSubject: PassthroughSubject<SIMD3<Double>, Never> = .init()
    
    let manager: CMMotionManager
    
    public init() {
        manager = CMMotionManager()
    }
    
    public func startAccelerometerUpdates() {
        manager.startAccelerometerUpdates(to: .main) { [weak self] data, error in
            guard let self, error == nil, let data else { return }
            let vector = SIMD3(data.acceleration.x, data.acceleration.y, data.acceleration.z)
            self.accelerometerDataPassthroughSubject.send(vector)
        }
    }
    
    public func stopAccelerometerUpdates() {
        manager.stopAccelerometerUpdates()
    }
    
    public func startGyroscopeUpdates() {
        manager.startGyroUpdates(to: .main) { [weak self] data, error in
            guard let self, error == nil, let data else { return }
            let vector = SIMD3(data.rotationRate.x, data.rotationRate.y, data.rotationRate.z)
            self.gyroscopeDataPassthroughSubject.send(vector)
        }
    }
    
    public func stopGyroscopeUpdates() {
        manager.stopGyroUpdates()
    }
}
