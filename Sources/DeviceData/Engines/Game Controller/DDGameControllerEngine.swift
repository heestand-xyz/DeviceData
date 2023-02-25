import Combine
import GameController

public final class DDGameControllerEngine: DDEngine {

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
        
        controller = notification.object as? GCController
        
        isConnected.value = controller != nil
        
        gamePad.value = .init(.off)
        
        controller?.extendedGamepad?.valueChangedHandler = { [weak self] (controller, _) in
            
            guard let self, active else { return }
            
            var gamePad: DDGamePad = gamePad.value ?? .off
            
            gamePad.home = controller.buttonHome?.isPressed == true
            gamePad.menu = controller.buttonMenu.isPressed
            gamePad.options = controller.buttonOptions?.isPressed == true
            
            gamePad.action.left = controller.buttonX.isPressed
            gamePad.action.down = controller.buttonA.isPressed
            gamePad.action.up = controller.buttonY.isPressed
            gamePad.action.right = controller.buttonB.isPressed
            
            gamePad.leftStick = DDGamePad.Sick(x: CGFloat(controller.leftThumbstick.xAxis.value),
                                               y: CGFloat(controller.leftThumbstick.yAxis.value),
                                               active: controller.leftThumbstickButton?.isPressed == true)
            
            gamePad.rightStick = DDGamePad.Sick(x: CGFloat(controller.rightThumbstick.xAxis.value),
                                                y: CGFloat(controller.rightThumbstick.yAxis.value),
                                                active: controller.rightThumbstickButton?.isPressed == true)
            
            gamePad.leftShoulder = controller.leftShoulder.isPressed
            gamePad.leftShoulder = controller.rightShoulder.isPressed
            
            gamePad.leftTrigger = CGFloat(controller.leftTrigger.value)
            gamePad.rightTrigger = CGFloat(controller.rightTrigger.value)
            
            gamePad.dpad = DDGamePad.DPad(left: controller.dpad.left.isPressed,
                                          right: controller.dpad.right.isPressed,
                                          up: controller.dpad.up.isPressed,
                                          down: controller.dpad.down.isPressed)
            
            if let touchpad = controller.touchpads.sorted(by: { $0.key < $1.key }).first?.value {
                gamePad.touchPad = DDGamePad.TouchPad(x: CGFloat(touchpad.touchSurface.xAxis.value),
                                                      y: CGFloat(touchpad.touchSurface.yAxis.value),
                                                      active: touchpad.button.isPressed)
                
            }
            
            self.gamePad.value = gamePad
        }
    }

    @objc private func controllerDisconnected(notification: NSNotification) {
        controller = nil
        isConnected.value = false
        gamePad.value = nil
    }
}
