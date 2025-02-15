import CoreGraphics

public struct DDAudio: Hashable {
    @available(*, deprecated, renamed: "normalizedPower")
    public var amplitude: CGFloat {
        pow(10.0, averagePower / 20.0)
    }
    public var normalizedPower: CGFloat {
        let minDb: CGFloat = -80.0
        let clamped = max(averagePower, minDb)
        return (clamped - minDb) / -minDb
    }
    public let averagePower: CGFloat
    public let peakPower: CGFloat
}
