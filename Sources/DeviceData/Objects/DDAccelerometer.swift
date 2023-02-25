import Combine
import CoreMotion

public final class DDAccelerometer<E: DDMotionEngine>: DDObject {
    
    public var available: Bool {
        motionEngine.isAccelerometerAvailable
    }
    
    public var authorization: CurrentValueSubject<DDAuthorization, Never> = .init(.notAvailable)
    
    public var active: CurrentValueSubject<Bool, Never> = .init(false)

    public var data: CurrentValueSubject<SIMD3<Double>?, Never> = .init(nil)
    
    let motionEngine: E
    
    private var cancelBag: Set<AnyCancellable> = []
    
    public init(engine: E) {
        
        motionEngine = engine
        
        active
            .sink { [weak self] active in
                guard let self, available else { return }
                if active {
                    motionEngine.startAccelerometerUpdates()
                } else {
                    motionEngine.stopAccelerometerUpdates()
                    data.value = nil
                }
            }
            .store(in: &cancelBag)
        
        motionEngine.accelerometerDataPassthroughSubject
            .sink { [weak self] value in
                self?.data.value = value
            }
            .store(in: &cancelBag)
    }
}