import simd
import Combine
import CoreMotion

public protocol DDMotionEngine: DDEngine {
    
    var isAccelerometerAvailable: Bool { get }
    var isGyroscopeAvailable: Bool { get }
    
    var accelerometerDataPassthroughSubject: PassthroughSubject<SIMD3<Double>, Never> { get }
    var gyroscopeDataPassthroughSubject: PassthroughSubject<SIMD3<Double>, Never> { get }
   
    func startAccelerometerUpdates()
    func stopAccelerometerUpdates()
    
    func startGyroscopeUpdates()
    func stopGyroscopeUpdates()
}

extension DDMotionEngine {
    
    public static func real() -> DDRealMotionEngine {
        DDRealMotionEngine()
    }
    
    public static func mock() -> DDMockMotionEngine {
        DDMockMotionEngine()
    }
}
