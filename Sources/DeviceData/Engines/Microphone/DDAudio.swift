import CoreGraphics

public struct DDAudio: Hashable {
    public var amplitude: CGFloat {
        pow(10.0, averagePower / 20.0)
    }
    public var normalizedPower: CGFloat {
        let minDb: CGFloat = -80.0
        let clamped = max(averagePower, minDb)
        return (clamped - minDb) / -minDb
    }
    public var normalizedLevel: CGFloat {
        let minDb: CGFloat = -80.0
        let clamped = min(max(averagePower, minDb), 0.0)
        let minAmplitude = pow(10.0, minDb / 20.0)
        let amplitude = pow(10.0, clamped / 20.0)
        let normalizedAmplitude = (amplitude - minAmplitude) / (1.0 - minAmplitude)
        return pow(min(max(normalizedAmplitude, 0.0), 1.0), 0.5)
    }
    public let averagePower: CGFloat
    public let peakPower: CGFloat
}
