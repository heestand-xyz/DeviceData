import CoreMotion

public final class DDMotionEngine: DDEngine {
  
    let manager: CMMotionManager
    
    public init() {
        manager = CMMotionManager()
    }
}
