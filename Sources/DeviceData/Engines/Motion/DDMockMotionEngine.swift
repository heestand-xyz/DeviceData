import Foundation
import Combine

public final class DDMockMotionEngine: DDMotionEngine {
    
    public var isAccelerometerAvailable: Bool = true
    
    public let accelerometerDataPassthroughSubject = PassthroughSubject<SIMD3<Double>, Never>()
    
    private var updateTimer: Timer?
    private var lastData: SIMD3<Double> = .zero
    
    init() {}
    
    public func startAccelerometerUpdates() {
        updateTimer = .scheduledTimer(withTimeInterval: 0.01, repeats: true) { [weak self] _ in
            guard let self else { return }
            let data = (lastData + .random(in: -0.1...0.1)) * 0.99
            accelerometerDataPassthroughSubject.send(data)
            lastData = data
        }
    }
    
    public func stopAccelerometerUpdates() {
        updateTimer?.invalidate()
        updateTimer = nil
        lastData = .zero
    }
}
