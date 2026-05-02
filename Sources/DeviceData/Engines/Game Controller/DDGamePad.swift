import CoreGraphics
import OrderedCollections

public struct DDGamePad: Hashable, Sendable {
    
    public var home: Bool
    public var menu: Bool
    public var options: Bool
    
    public struct Arrows: Hashable, Sendable {
        public var left: Bool
        public var right: Bool
        public var up: Bool
        public var down: Bool
    }
    public var dpad: Arrows
    public var action: Arrows
    
    public struct Sick: Hashable, Sendable {
        public var x: CGFloat
        public var y: CGFloat
        public var active: Bool
    }
    public var leftStick: Sick
    public var rightStick: Sick
    
    public struct TouchPad: Hashable, Sendable {
        public var x: CGFloat
        public var y: CGFloat
        public var active: Bool
    }
    public var touchPad: TouchPad
    
    public var leftShoulder: Bool
    public var rightShoulder: Bool
    public var leftTrigger: CGFloat
    public var rightTrigger: CGFloat
}

extension DDGamePad {

    public static let defaultActive: OrderedDictionary<String, Bool> = [
        "home": true,
        "menu": true,
        "options": true,
        "dpad/left": true,
        "dpad/right": true,
        "dpad/down": true,
        "dpad/up": true,
        "action/left": true,
        "action/right": true,
        "action/down": true,
        "action/up": true,
        "stick/left/x": true,
        "stick/left/y": true,
        "stick/left/active": true,
        "stick/right/x": true,
        "stick/right/y": true,
        "stick/right/active": true,
        "shoulder/left": true,
        "shoulder/right": true,
        "trigger/left": true,
        "trigger/right": true,
        "touchpad/x": false,
        "touchpad/y": false,
        "touchpad/active": false,
    ]

    public func value(for address: String) -> DDScalar? {
        switch address {
        case "home":
            .bool(home)
        case "menu":
            .bool(menu)
        case "options":
            .bool(options)
        case "dpad/left":
            .bool(dpad.left)
        case "dpad/right":
            .bool(dpad.right)
        case "dpad/down":
            .bool(dpad.down)
        case "dpad/up":
            .bool(dpad.up)
        case "action/left":
            .bool(action.left)
        case "action/right":
            .bool(action.right)
        case "action/down":
            .bool(action.down)
        case "action/up":
            .bool(action.up)
        case "stick/left/x":
            .float(leftStick.x)
        case "stick/left/y":
            .float(leftStick.y)
        case "stick/left/active":
            .bool(leftStick.active)
        case "stick/right/x":
            .float(rightStick.x)
        case "stick/right/y":
            .float(rightStick.y)
        case "stick/right/active":
            .bool(rightStick.active)
        case "touchpad/x":
            .float(touchPad.x)
        case "touchpad/y":
            .float(touchPad.y)
        case "touchpad/active":
            .bool(touchPad.active)
        case "shoulder/left":
            .bool(leftShoulder)
        case "shoulder/right":
            .bool(rightShoulder)
        case "trigger/left":
            .float(leftTrigger)
        case "trigger/right":
            .float(rightTrigger)
        default:
            nil
        }
    }

    public func values() -> [String: Any] {
        var values: [String: Any] = [:]
        for (address, _) in Self.defaultActive {
            switch value(for: address) {
            case .bool(let value):
                values[address] = value
            case .float(let value):
                values[address] = value
            case nil:
                continue
            }
        }
        return values
    }
}

extension DDGamePad {
    
    public static let off = DDGamePad(home: false, menu: false, options: false, dpad: Arrows(left: false, right: false, up: false, down: false), action: Arrows(left: false, right: false, up: false, down: false), leftStick: Sick(x: 0.0, y: 0.0, active: false), rightStick: Sick(x: 0.0, y: 0.0, active: false), touchPad: TouchPad(x: 0.0, y: 0.0, active: false), leftShoulder: false, rightShoulder: false, leftTrigger: 0.0, rightTrigger: 0.0)
}
