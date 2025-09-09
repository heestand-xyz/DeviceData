import Combine
import GameController

public final class DDGameControllerEngine: DDEngine, @unchecked Sendable {

    public var active: Bool = false
    
    private var controller: GCController?
    
    public let isConnected: CurrentValueSubject<Bool, Never> = .init(false)
    
    public let gamePad: CurrentValueSubject<DDGamePad?, Never> = .init(nil)
    
    public var isAuthorized: Bool { true }
    
    public init() {
        listen()
    }
    
    deinit {
        unlisten()
    }
    
    public func authorizeIfNeeded() async -> Bool { isAuthorized }
    
    @MainActor
    public func startAll() {
        active = true
    }
    
    @MainActor
    public func stopAll() {
        active = false
    }
    
    private func listen() {
        Foundation.NotificationCenter.default.addObserver(self, selector: #selector(controllerConnected), name: NSNotification.Name.GCControllerDidConnect, object: nil)
        Foundation.NotificationCenter.default.addObserver(self, selector: #selector(controllerDisconnected), name: NSNotification.Name.GCControllerDidDisconnect, object: nil)
    }
    
    public func unlisten() {
        Foundation.NotificationCenter.default.removeObserver(self, name: NSNotification.Name.GCControllerDidConnect, object: nil)
        Foundation.NotificationCenter.default.removeObserver(self, name: NSNotification.Name.GCControllerDidDisconnect, object: nil)
    }

    @objc private func controllerConnected(notification: NSNotification) {
        
        controller = notification.object as? GCController
        
        isConnected.value = controller != nil
        
        gamePad.value = .init(.off)
        
        controller?.extendedGamepad?.valueChangedHandler = { [weak self] (controller, _) in
            
            guard let self, self.active else { return }
            
            var gamePad: DDGamePad = self.gamePad.value ?? .off
            
            gamePad.home = controller.buttonHome?.isPressed == true
            gamePad.menu = controller.buttonMenu.isPressed
            gamePad.options = controller.buttonOptions?.isPressed == true
            
            gamePad.action = DDGamePad.Arrows(left: controller.buttonX.isPressed,
                                              right: controller.buttonB.isPressed,
                                              up: controller.buttonY.isPressed,
                                              down: controller.buttonA.isPressed)
            
            gamePad.leftStick = DDGamePad.Sick(x: CGFloat(controller.leftThumbstick.xAxis.value),
                                               y: CGFloat(controller.leftThumbstick.yAxis.value),
                                               active: controller.leftThumbstickButton?.isPressed == true)
            
            gamePad.rightStick = DDGamePad.Sick(x: CGFloat(controller.rightThumbstick.xAxis.value),
                                                y: CGFloat(controller.rightThumbstick.yAxis.value),
                                                active: controller.rightThumbstickButton?.isPressed == true)
            
            gamePad.leftShoulder = controller.leftShoulder.isPressed
            gamePad.rightShoulder = controller.rightShoulder.isPressed
            
            gamePad.leftTrigger = CGFloat(controller.leftTrigger.value)
            gamePad.rightTrigger = CGFloat(controller.rightTrigger.value)
            
            gamePad.dpad = DDGamePad.Arrows(left: controller.dpad.left.isPressed,
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
