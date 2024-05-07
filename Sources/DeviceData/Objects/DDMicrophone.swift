import Combine
import CoreGraphics

public final class DDMicrophone: DDObject {
    
    public var available: Bool { true }
    
    public var authorization: CurrentValueSubject<DDAuthorization, Never> = .init(.unknown)
    
    public var active: CurrentValueSubject<Bool, Never> = .init(false)
    
    public var data: CurrentValueSubject<DDAudio?, Never> = .init(nil)
    
    private let engine: DDMicrophoneEngine
    
    private var cancelBag: Set<AnyCancellable> = []
    
    public init(engine: DDMicrophoneEngine) {
        
        self.engine = engine
        
        active
            .sink { [weak self] active in
                if active {
                    self?.engine.startUpdating()
                } else {
                    self?.engine.stopUpdating()
                }
            }
            .store(in: &cancelBag)
        
        engine.authorization
            .sink { [weak self] status in
                guard let self else { return }
                switch status {
                case .notDetermined:
                    self.authorization.value = .notDetermined
                case .restricted:
                    self.authorization.value = .restricted
                case .denied:
                    self.authorization.value = .denied
                case .authorized:
                    self.authorization.value = .authorized
                @unknown default:
                    self.authorization.value = .unknown
                }
            }
            .store(in: &cancelBag)
        
        engine.audio
            .map { $0 }
            .assign(to: \.data.value, on: self)
            .store(in: &cancelBag)
    }
    
    public func authorize() {
        engine.authorize()
    }
}
