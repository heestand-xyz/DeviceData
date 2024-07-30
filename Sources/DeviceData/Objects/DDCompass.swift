#if !os(visionOS)

import Combine
import CoreLocation

public final class DDCompass: DDObject {
    
    public var available: Bool { true }
    
    public var authorization: CurrentValueSubject<DDAuthorization, Never> = .init(.notNeeded)
    
    public var active: CurrentValueSubject<Bool, Never> = .init(false)
    
    public var data: CurrentValueSubject<CLHeading?, Never> = .init(nil)
    
    private let engine: DDLocationEngine
    
    private var cancelBag: Set<AnyCancellable> = []
    
    public init(engine: DDLocationEngine) {
        
        self.engine = engine
        
        active
            .sink { [weak self] active in
                if active {
                    self?.engine.startUpdatingHeading()
                } else {
                    self?.engine.stopUpdatingHeading()
                }
            }
            .store(in: &cancelBag)
        
        engine.heading
            .map { $0 }
            .assign(to: \.data.value, on: self)
            .store(in: &cancelBag)
    }
    
    public func authorize() {
        engine.authorize()
    }
}

#endif
