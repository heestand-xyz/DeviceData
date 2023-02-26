import Combine

public final class DDProximity: DDObject {
    
    public var available: Bool {
        engine.available
    }
    
    public var authorization: CurrentValueSubject<DDAuthorization, Never> = .init(.notNeeded)
    
    public var active: CurrentValueSubject<Bool, Never> = .init(false)
    
    public var data: CurrentValueSubject<Bool?, Never> = .init(nil)
    
    private let engine: DDProximityEngine
    
    private var cancelBag: Set<AnyCancellable> = []
    
    public init(engine: DDProximityEngine) {
        
        self.engine = engine
        
        active
            .assign(to: \.active.value, on: engine)
            .store(in: &cancelBag)
        
        engine.state
            .map { $0 }
            .assign(to: \.data.value, on: self)
            .store(in: &cancelBag)
    }
    
    public func authorize() {}
}
