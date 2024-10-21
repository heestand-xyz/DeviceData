#if os(macOS)
public final class DDMockMotionEngine: DDMotionEngine {
    public init() {}
}
#else
import Foundation
import Combine

public final class DDMockMotionEngine: DDMotionEngine {
    
    public var isAccelerometerAvailable: Bool = true
    public var isGyroscopeAvailable: Bool = true
    
    public let accelerometerDataPassthroughSubject: PassthroughSubject<SIMD3<Double>, Never> = .init()
    public var gyroscopeDataPassthroughSubject: PassthroughSubject<SIMD3<Double>, Never> = .init()
    
    private var accelerometerUpdateTimer: Timer?
    private var gyroscopeUpdateTimer: Timer?
    
    private var accelerometerLastData: SIMD3<Double> = .zero
    private var gyroscopeLastData: SIMD3<Double> = .zero
    
    public init() {}
    
    public func startAccelerometerUpdates() {
        accelerometerUpdateTimer = .scheduledTimer(withTimeInterval: 0.01, repeats: true) { [weak self] _ in
            guard let self else { return }
            let data = (self.accelerometerLastData + SIMD3<Double>.random(in: -0.1...0.1)) * 0.99
            self.accelerometerDataPassthroughSubject.send(data)
            self.accelerometerLastData = data
        }
    }
    
    public func stopAccelerometerUpdates() {
        accelerometerUpdateTimer?.invalidate()
        accelerometerUpdateTimer = nil
        accelerometerLastData = .zero
    }
    
    public func startGyroscopeUpdates() {
        gyroscopeUpdateTimer = .scheduledTimer(withTimeInterval: 0.01, repeats: true) { [weak self] _ in
            guard let self else { return }
            let data = (self.gyroscopeLastData + SIMD3<Double>.random(in: -0.1...0.1)) * 0.99
            self.gyroscopeDataPassthroughSubject.send(data)
            self.gyroscopeLastData = data
        }
    }
    
    public func stopGyroscopeUpdates() {
        gyroscopeUpdateTimer?.invalidate()
        gyroscopeUpdateTimer = nil
        gyroscopeLastData = .zero
    }
}
#endif
