import CoreGraphics

public struct DDAudio: Hashable {
    public var amplitude: CGFloat {
        pow(10.0, averagePower / 20.0)
    }
    public let averagePower: CGFloat
    public let peakPower: CGFloat
}
