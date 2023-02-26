import Combine
import UIKit

public final class DDProximityEngine: DDEngine {
    
    private var enabled: Bool {
        get {
            UIDevice.current.isProximityMonitoringEnabled
        }
        set {
            UIDevice.current.isProximityMonitoringEnabled = newValue
        }
    }
    
    var available: Bool {
        if enabled {
            return true
        } else {
            enabled = true
            let available = enabled
            enabled = false
            return available            
        }
    }
    
    lazy var active: CurrentValueSubject<Bool, Never> = .init(enabled)
    
    var state: PassthroughSubject<Bool, Never> = .init()
    
    private var cancelBag: Set<AnyCancellable> = []
    
    public init() {
        
        active
            .sink { [weak self] active in
                guard let self else { return }
                if active {
                    enabled = true
                    NotificationCenter.default.addObserver(
                        self,
                        selector: #selector(proximityStateChange),
                        name: UIDevice.proximityStateDidChangeNotification,
                        object: nil
                    )
                } else {
                    enabled = false
                    NotificationCenter.default.removeObserver(self)
                }
            }
            .store(in: &cancelBag)
    }
    
    @objc private func proximityStateChange() {
        state.send(UIDevice.current.proximityState)
    }
}
