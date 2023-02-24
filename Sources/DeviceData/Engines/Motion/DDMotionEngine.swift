import simd
import Combine
import CoreMotion

public protocol DDMotionEngine: DDEngine {
    
    var isAccelerometerAvailable: Bool { get }
    
    var accelerometerDataPassthroughSubject: PassthroughSubject<SIMD3<Double>, Never> { get }
   
    func startAccelerometerUpdates()
    func stopAccelerometerUpdates()
}

extension DDMotionEngine {
    
    public static func real() -> DDRealMotionEngine {
        DDRealMotionEngine()
    }
    
    public static func mock() -> DDMockMotionEngine {
        DDMockMotionEngine()
    }
}
