import Combine
import GameController

public class DDGameControllerEngine: DDEngine {

    var active: Bool = false
    
    private var controller: GCController?
    
    let isConnected: CurrentValueSubject<Bool, Never> = .init(false)
    
    let gamePad: CurrentValueSubject<DDGamePad?, Never> = .init(nil)
    
    public init() {
        listen()
    }
    
    private func listen() {
        Foundation.NotificationCenter.default.addObserver(self, selector: #selector(controllerConnected), name: NSNotification.Name.GCControllerDidConnect, object: nil)
        Foundation.NotificationCenter.default.addObserver(self, selector: #selector(controllerDisconnected), name: NSNotification.Name.GCControllerDidDisconnect, object: nil)
    }

    @objc private func controllerConnected(notification: NSNotification) {
        
        print("Device Data - Game Controller - Connected")
        
        controller = notification.object as? GCController
        
        isConnected.value = controller != nil
        
        gamePad.value = .init(.off)
        
        controller?.extendedGamepad?.valueChangedHandler = { [weak self] (gamepad, gameElement) in
            
            guard let self, active else { return }
            
            guard let alias: String = gameElement.aliases.first else { return }
            
            print("Device Data - Game Controller - Alias:", alias)
            
            if let gameButton = gameElement as? GCControllerButtonInput {
            
                if alias.contains("Trigger") {
            
                }
                
            } else if let gamePad = gameElement as? GCControllerDirectionPad {
                
                let x: CGFloat = CGFloat(gamePad.xAxis.value)
                let y: CGFloat = CGFloat(gamePad.yAxis.value)
            
                if alias == "Direction Pad" {
                    
                    switch (x, y) {
                    case (-1.0, 0.0):
                        break
                    case (1.0, 0.0):
                        break
                    case (0.0, 1.0):
                        break
                    case (0.0, -1.0):
                        break
                    default:
                        break
                    }
                    
                } else if alias.contains("Touchpad") {
                    
                    if x != 0.0 || y != 0.0 {
                        
                    } else {
                        
                    }
                }
            }
        }
    }

    @objc private func controllerDisconnected(notification: NSNotification) {
        
        print("Device Data - Game Controller - Disconnected")
        
        controller = nil
        isConnected.value = false
        gamePad.value = nil
    }
}
