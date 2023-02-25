import CoreGraphics

public struct DDGamePad {
    
    public let create: Bool
    public let options: Bool
    
    public struct Directional {
        public let left: Bool
        public let right: Bool
        public let up: Bool
        public let down: Bool
    }
    public let directional: Directional
    
    public struct Action {
        public let left: Bool // X Square
        public let right: Bool // B Circle
        public let up: Bool // Y Triangle
        public let down: Bool // A Xmark
    }
    public let action: Action
    
    public struct Sick {
        public let x: CGFloat
        public let y: CGFloat
    }
    public let leftStick: Sick
    public let rightStick: Sick
    
    public struct TouchPad {
        public let x: CGFloat
        public let y: CGFloat
    }
    public let touchPad: TouchPad
    public let touchPadButton: Bool
    
    public let l1: Bool
    public let r1: Bool
    public let l2: CGFloat
    public let r2: CGFloat
    public let l3: Bool
    public let r3: Bool
}

extension DDGamePad {
    
    static let off = DDGamePad(create: false, options: false, directional: Directional(left: false, right: false, up: false, down: false), action: Action(left: false, right: false, up: false, down: false), leftStick: Sick(x: 0.0, y: 0.0), rightStick: Sick(x: 0.0, y: 0.0), touchPad: TouchPad(x: 0.0, y: 0.0), touchPadButton: false, l1: false, r1: false, l2: 0.0, r2: 0.0, l3: false, r3: false)
}
