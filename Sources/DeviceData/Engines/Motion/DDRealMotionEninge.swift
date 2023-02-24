import Combine
import CoreMotion

public final class DDRealMotionEngine: DDMotionEngine {
    
    public var isAccelerometerAvailable: Bool {
        manager.isAccelerometerAvailable
    }
    
    public let accelerometerDataPassthroughSubject = PassthroughSubject<SIMD3<Double>, Never>()
    
    let manager: CMMotionManager
    
    private var updateCancelBag: Set<AnyCancellable> = []
    
    public init() {
        manager = CMMotionManager()
    }
    
    public func startAccelerometerUpdates() {
        manager.startAccelerometerUpdates()
        manager.accelerometerData.publisher
            .map { data in
                SIMD3(data.acceleration.x, data.acceleration.y, data.acceleration.z)
            }
            .sink(receiveValue: { [weak self] value in
                self?.accelerometerDataPassthroughSubject.send(value)
            })
            .store(in: &updateCancelBag)
    }
    
    public func stopAccelerometerUpdates() {
        updateCancelBag = []
        manager.stopAccelerometerUpdates()
    }
}
