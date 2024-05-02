import Combine
import CoreGraphics

@available(iOS 17.0, *)
public final class DDMicrophone: DDObject {
    
    public var available: Bool { true }
    
    public var authorization: CurrentValueSubject<DDAuthorization, Never> = .init(.unknown)
    
    public var active: CurrentValueSubject<Bool, Never> = .init(false)
    
    public var data: CurrentValueSubject<CGFloat?, Never> = .init(nil)
    
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
                case .granted:
                    self.authorization.value = .authorized
                case .denied:
                    self.authorization.value = .denied
                case .undetermined:
                    self.authorization.value = .notDetermined
                @unknown default:
                    self.authorization.value = .unknown
                }
            }
            .store(in: &cancelBag)
        
        engine.amplitude
            .map { $0 }
            .assign(to: \.data.value, on: self)
            .store(in: &cancelBag)
    }
    
    public func authorize() {
        engine.authorize()
    }
}
