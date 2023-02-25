import CoreGraphics

public struct DDGamePad {
    
    public var home: Bool
    public var menu: Bool
    public var options: Bool
    
    public struct DPad {
        public var left: Bool
        public var right: Bool
        public var up: Bool
        public var down: Bool
    }
    public var dpad: DPad
    
    public struct Action {
        public var left: Bool // X Square
        public var right: Bool // B Circle
        public var up: Bool // Y Triangle
        public var down: Bool // A Xmark
    }
    public var action: Action
    
    public struct Sick {
        public var x: CGFloat
        public var y: CGFloat
        public var active: Bool
    }
    public var leftStick: Sick
    public var rightStick: Sick
    
    public struct TouchPad {
        public var x: CGFloat
        public var y: CGFloat
        public var active: Bool
    }
    public var touchPad: TouchPad
    public var touchPadButton: Bool
    
    public var leftShoulder: Bool
    public var rightShoulder: Bool
    public var leftTrigger: CGFloat
    public var rightTrigger: CGFloat
}

extension DDGamePad {
    
    static let off = DDGamePad(home: false, menu: false, options: false, dpad: DPad(left: false, right: false, up: false, down: false), action: Action(left: false, right: false, up: false, down: false), leftStick: Sick(x: 0.0, y: 0.0, active: false), rightStick: Sick(x: 0.0, y: 0.0, active: false), touchPad: TouchPad(x: 0.0, y: 0.0, active: false), touchPadButton: false, leftShoulder: false, rightShoulder: false, leftTrigger: 0.0, rightTrigger: 0.0)
}
