#if os(macOS) || os(tvOS)
public final class DDRealMotionEngine: DDMotionEngine, @unchecked Sendable {
    public var isAuthorized: Bool { true }
    public init() {}
    public func authorizeIfNeeded() async -> Bool {
        isAuthorized
    }
    public func startAll() {}
    public func stopAll() {}
}
#else
import Combine
import CoreMotion
import Foundation

public final class DDRealMotionEngine: DDMotionEngine, @unchecked Sendable {
    
    public var isAccelerometerAvailable: Bool {
        manager.isAccelerometerAvailable
    }
    public var isGyroscopeAvailable: Bool {
        manager.isGyroAvailable
    }
    
    public let accelerometerDataPassthroughSubject: PassthroughSubject<SIMD3<Double>, Never> = .init()
    public var gyroscopeDataPassthroughSubject: PassthroughSubject<SIMD3<Double>, Never> = .init()
    
    private let manager: CMMotionManager
    private let accelerometerQueue: OperationQueue = DDRealMotionEngine.makeQueue(
        name: "data-osc.motion.accelerometer"
    )
    private let gyroscopeQueue: OperationQueue = DDRealMotionEngine.makeQueue(
        name: "data-osc.motion.gyroscope"
    )
    
    public var isAuthorized: Bool { true }
    
    public init() {
        manager = CMMotionManager()
    }

    private static func makeQueue(name: String) -> OperationQueue {
        let queue = OperationQueue()
        queue.name = name
        queue.maxConcurrentOperationCount = 1
        queue.qualityOfService = .userInteractive
        return queue
    }
    
    public func authorizeIfNeeded() async -> Bool { isAuthorized }
    
    @MainActor
    public func startAll() {
        startAccelerometerUpdates()
        startGyroscopeUpdates()
    }
    
    @MainActor
    public func stopAll() {
        stopAccelerometerUpdates()
        stopGyroscopeUpdates()
    }
    
    public func startAccelerometerUpdates() {
        manager.startAccelerometerUpdates(to: accelerometerQueue) { [weak self] data, error in
            guard let self, error == nil, let data else { return }
            let vector = SIMD3(data.acceleration.x, data.acceleration.y, data.acceleration.z)
            self.accelerometerDataPassthroughSubject.send(vector)
        }
    }
    
    public func stopAccelerometerUpdates() {
        manager.stopAccelerometerUpdates()
        accelerometerQueue.cancelAllOperations()
    }
    
    public func startGyroscopeUpdates() {
        manager.startGyroUpdates(to: gyroscopeQueue) { [weak self] data, error in
            guard let self, error == nil, let data else { return }
            let vector = SIMD3(data.rotationRate.x, data.rotationRate.y, data.rotationRate.z)
            self.gyroscopeDataPassthroughSubject.send(vector)
        }
    }
    
    public func stopGyroscopeUpdates() {
        manager.stopGyroUpdates()
        gyroscopeQueue.cancelAllOperations()
    }
}
#endif
