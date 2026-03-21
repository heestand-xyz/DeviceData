import Combine
import GameController

public final class DDGameControllerEngine: DDEngine, @unchecked Sendable {

    public var active: Bool = false
    
    private var controller: GCController?
    
    private var controllers: [GCController] = []
    
    @available(*, deprecated, message: "Please use gamePadDevices.value.isEmpty == false.")
    public let isConnected: CurrentValueSubject<Bool, Never> = .init(false)
    
    @available(*, deprecated, message: "Please use gamePadDevices.")
    public let gamePad: CurrentValueSubject<DDGamePad?, Never> = .init(nil)
    
    public let gamePadDevices: CurrentValueSubject<[DDGamePadDevice], Never> = .init([])
    
    public var isAuthorized: Bool { true }
    
    public init() {
        listen()
        updateControllerState()
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
        updateControllerState(preferredController: notification.object as? GCController)
    }

    @objc private func controllerDisconnected(notification: NSNotification) {
        updateControllerState()
    }

    private func updateControllerState(preferredController: GCController? = nil) {
        controllers.forEach { controller in
            controller.extendedGamepad?.valueChangedHandler = nil
        }

        let controllers: [GCController] = GCController.controllers()
        let nextController: GCController?

        if let preferredController,
           let connectedController: GCController = controllers.first(where: { $0 === preferredController }) {
            nextController = connectedController
        } else if let controller,
                  let connectedController: GCController = controllers.first(where: { $0 === controller }) {
            nextController = connectedController
        } else {
            nextController = controllers.first
        }

        self.controllers = controllers
        controller = nextController
        
        let nextGamePadDevices: [DDGamePadDevice] = controllers.map(gamePadDevice(for:))
        
        isConnected.value = !controllers.isEmpty
        gamePadDevices.value = nextGamePadDevices
        if let nextController,
           let controllerIndex: Int = controllers.firstIndex(where: { $0 === nextController }) {
            gamePad.value = nextGamePadDevices[controllerIndex].gamePad
        } else {
            gamePad.value = nil
        }

        for controller in controllers {
            let controllerID: ObjectIdentifier = .init(controller)
            controller.extendedGamepad?.valueChangedHandler = { [weak self] gamePad, _ in

                guard let self, self.active else { return }

                self.gamePadDidChange(for: controllerID, gamePad: gamePad)
            }
        }
    }
    
    private func gamePadDidChange(for controllerID: ObjectIdentifier, gamePad: GCExtendedGamepad) {
        let currentControllers: [GCController] = controllers
        let currentGamePadDevices: [DDGamePadDevice] = gamePadDevices.value
        let controllerIDs: [ObjectIdentifier] = currentControllers.map(ObjectIdentifier.init)
        let currentGamePadDevicesByControllerID: [ObjectIdentifier: DDGamePadDevice] = Dictionary(
            uniqueKeysWithValues: zip(controllerIDs, currentGamePadDevices)
        )
        guard let updatedController: GCController = currentControllers.first(where: { ObjectIdentifier($0) == controllerID }) else { return }
        let updatedGamePadDevice: DDGamePadDevice = gamePadDevice(for: updatedController, gamePad: gamePad)
        let updatedGamePadDevices: [DDGamePadDevice] = currentControllers.map { controller in
            let currentControllerID: ObjectIdentifier = .init(controller)
            if currentControllerID == controllerID {
                return updatedGamePadDevice
            }
            return currentGamePadDevicesByControllerID[currentControllerID] ?? gamePadDevice(for: controller)
        }

        gamePadDevices.value = updatedGamePadDevices

        if let controller,
           let controllerIndex: Int = currentControllers.firstIndex(where: { $0 === controller }) {
            self.gamePad.value = updatedGamePadDevices[controllerIndex].gamePad
        } else {
            self.gamePad.value = nil
        }
    }
    
    private func gamePadDevice(for controller: GCController) -> DDGamePadDevice {
        guard let gamePad: GCExtendedGamepad = controller.extendedGamepad else {
            return DDGamePadDevice(
                id: gamePadDeviceID(for: controller),
                name: gamePadDeviceName(for: controller),
                gamePad: .off
            )
        }
        return gamePadDevice(for: controller, gamePad: gamePad)
    }

    private func gamePadDevice(for controller: GCController, gamePad: GCExtendedGamepad) -> DDGamePadDevice {
        DDGamePadDevice(
            id: gamePadDeviceID(for: controller),
            name: gamePadDeviceName(for: controller),
            gamePad: self.gamePad(for: gamePad)
        )
    }

    private func gamePadDeviceID(for controller: GCController) -> String {
        let controllerPointer: UInt = UInt(bitPattern: Unmanaged.passUnretained(controller).toOpaque())
        return "gccontroller-\(String(controllerPointer, radix: 16))"
    }

    private func gamePadDeviceName(for controller: GCController) -> String {
        controller.vendorName ?? controller.productCategory
    }
    
    private func gamePad(for gamePad: GCExtendedGamepad) -> DDGamePad {
        var gamePadValue: DDGamePad = .off

        gamePadValue.home = gamePad.buttonHome?.isPressed == true
        gamePadValue.menu = gamePad.buttonMenu.isPressed
        gamePadValue.options = gamePad.buttonOptions?.isPressed == true

        gamePadValue.action = DDGamePad.Arrows(left: gamePad.buttonX.isPressed,
                                               right: gamePad.buttonB.isPressed,
                                               up: gamePad.buttonY.isPressed,
                                               down: gamePad.buttonA.isPressed)

        gamePadValue.leftStick = DDGamePad.Sick(x: CGFloat(gamePad.leftThumbstick.xAxis.value),
                                                y: CGFloat(gamePad.leftThumbstick.yAxis.value),
                                                active: gamePad.leftThumbstickButton?.isPressed == true)

        gamePadValue.rightStick = DDGamePad.Sick(x: CGFloat(gamePad.rightThumbstick.xAxis.value),
                                                 y: CGFloat(gamePad.rightThumbstick.yAxis.value),
                                                 active: gamePad.rightThumbstickButton?.isPressed == true)

        gamePadValue.leftShoulder = gamePad.leftShoulder.isPressed
        gamePadValue.rightShoulder = gamePad.rightShoulder.isPressed

        gamePadValue.leftTrigger = CGFloat(gamePad.leftTrigger.value)
        gamePadValue.rightTrigger = CGFloat(gamePad.rightTrigger.value)

        gamePadValue.dpad = DDGamePad.Arrows(left: gamePad.dpad.left.isPressed,
                                             right: gamePad.dpad.right.isPressed,
                                             up: gamePad.dpad.up.isPressed,
                                             down: gamePad.dpad.down.isPressed)

        if let touchpad = gamePad.touchpads.sorted(by: { $0.key < $1.key }).first?.value {
            gamePadValue.touchPad = DDGamePad.TouchPad(x: CGFloat(touchpad.touchSurface.xAxis.value),
                                                       y: CGFloat(touchpad.touchSurface.yAxis.value),
                                                       active: touchpad.button.isPressed)
        }

        return gamePadValue
    }
}
