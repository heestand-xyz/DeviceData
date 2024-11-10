import CoreGraphics
import OrderedCollections

public struct DDGamePad: Hashable {
    
    public var home: Bool
    public var menu: Bool
    public var options: Bool
    
    public struct Arrows: Hashable {
        public var left: Bool
        public var right: Bool
        public var up: Bool
        public var down: Bool
    }
    public var dpad: Arrows
    public var action: Arrows
    
    public struct Sick: Hashable {
        public var x: CGFloat
        public var y: CGFloat
        public var active: Bool
    }
    public var leftStick: Sick
    public var rightStick: Sick
    
    public struct TouchPad: Hashable {
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

    public func values() -> [String: Any] {
         [
            "home": home,
            "menu": menu,
            "options": options,
            "dpad/left": dpad.left,
            "dpad/right": dpad.right,
            "dpad/down": dpad.down,
            "dpad/up": dpad.up,
            "action/left": action.left,
            "action/right": action.right,
            "action/down": action.down,
            "action/up": action.up,
            "stick/left/x": leftStick.x,
            "stick/left/y": leftStick.y,
            "stick/left/active": leftStick.active,
            "stick/right/x": rightStick.x,
            "stick/right/y": rightStick.y,
            "stick/right/active": rightStick.active,
            "touchpad/x": touchPad.x,
            "touchpad/y": touchPad.y,
            "touchpad/active": touchPad.active,
            "shoulder/left": leftShoulder,
            "shoulder/right": rightShoulder,    
            "trigger/left": leftTrigger,
            "trigger/right": rightTrigger,
        ]
    }
}

extension DDGamePad {
    
    public static let off = DDGamePad(home: false, menu: false, options: false, dpad: Arrows(left: false, right: false, up: false, down: false), action: Arrows(left: false, right: false, up: false, down: false), leftStick: Sick(x: 0.0, y: 0.0, active: false), rightStick: Sick(x: 0.0, y: 0.0, active: false), touchPad: TouchPad(x: 0.0, y: 0.0, active: false), leftShoulder: false, rightShoulder: false, leftTrigger: 0.0, rightTrigger: 0.0)
}
