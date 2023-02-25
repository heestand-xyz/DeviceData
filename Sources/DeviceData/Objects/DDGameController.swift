import Combine

public final class DDGameController: DDObject {
    
    public var available: Bool { true }
    
    public var authorization: CurrentValueSubject<DDAuthorization, Never> = .init(.notNeeded)
    
    public var active: CurrentValueSubject<Bool, Never> = .init(false)
    
    public var connected: CurrentValueSubject<Bool, Never> = .init(false)
    
    public var data: CurrentValueSubject<DDGamePad?, Never> = .init(nil)
    
    private let engine: DDGameControllerEngine
    
    private var cancelBag: Set<AnyCancellable> = []
    
    public init(engine: DDGameControllerEngine) {
        
        self.engine = engine
        
        active
            .assign(to: \.active, on: engine)
            .store(in: &cancelBag)
        
        engine.isConnected
            .assign(to: \.connected.value, on: self)
            .store(in: &cancelBag)
        
        engine.gamePad
            .assign(to: \.data.value, on: self)
            .store(in: &cancelBag)
    }
}
