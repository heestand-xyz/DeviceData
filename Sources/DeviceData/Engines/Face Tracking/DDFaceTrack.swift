#if os(iOS)

import ARKit
import SceneKit
import simd
import OrderedCollections

public struct DDFaceTrack: Sendable {
    
    public let cameraTransform: SCNMatrix4?
    public let faceAnchor: ARFaceAnchor?
    
    public init(cameraTransform: SCNMatrix4?, faceAnchor: ARFaceAnchor?) {
        self.cameraTransform = cameraTransform
        self.faceAnchor = faceAnchor
    }
}

extension DDFaceTrack {

    private static let blendShapeLocations: [String: ARFaceAnchor.BlendShapeLocation] = [
        "blendShape/browDownLeft": .browDownLeft,
        "blendShape/browDownRight": .browDownRight,
        "blendShape/browInnerUp": .browInnerUp,
        "blendShape/browOuterUpLeft": .browOuterUpLeft,
        "blendShape/browOuterUpRight": .browOuterUpRight,
        "blendShape/cheekPuff": .cheekPuff,
        "blendShape/cheekSquintLeft": .cheekSquintLeft,
        "blendShape/cheekSquintRight": .cheekSquintRight,
        "blendShape/eyeBlinkLeft": .eyeBlinkLeft,
        "blendShape/eyeBlinkRight": .eyeBlinkRight,
        "blendShape/eyeLookDownLeft": .eyeLookDownLeft,
        "blendShape/eyeLookDownRight": .eyeLookDownRight,
        "blendShape/eyeLookInLeft": .eyeLookInLeft,
        "blendShape/eyeLookInRight": .eyeLookInRight,
        "blendShape/eyeLookOutLeft": .eyeLookOutLeft,
        "blendShape/eyeLookOutRight": .eyeLookOutRight,
        "blendShape/eyeLookUpLeft": .eyeLookUpLeft,
        "blendShape/eyeLookUpRight": .eyeLookUpRight,
        "blendShape/eyeSquintLeft": .eyeSquintLeft,
        "blendShape/eyeSquintRight": .eyeSquintRight,
        "blendShape/eyeWideLeft": .eyeWideLeft,
        "blendShape/eyeWideRight": .eyeWideRight,
        "blendShape/jawForward": .jawForward,
        "blendShape/jawLeft": .jawLeft,
        "blendShape/jawOpen": .jawOpen,
        "blendShape/jawRight": .jawRight,
        "blendShape/mouthClose": .mouthClose,
        "blendShape/mouthDimpleLeft": .mouthDimpleLeft,
        "blendShape/mouthDimpleRight": .mouthDimpleRight,
        "blendShape/mouthFrownLeft": .mouthFrownLeft,
        "blendShape/mouthFrownRight": .mouthFrownRight,
        "blendShape/mouthFunnel": .mouthFunnel,
        "blendShape/mouthLeft": .mouthLeft,
        "blendShape/mouthLowerDownLeft": .mouthLowerDownLeft,
        "blendShape/mouthLowerDownRight": .mouthLowerDownRight,
        "blendShape/mouthPressLeft": .mouthPressLeft,
        "blendShape/mouthPressRight": .mouthPressRight,
        "blendShape/mouthPucker": .mouthPucker,
        "blendShape/mouthRight": .mouthRight,
        "blendShape/mouthRollLower": .mouthRollLower,
        "blendShape/mouthRollUpper": .mouthRollUpper,
        "blendShape/mouthShrugLower": .mouthShrugLower,
        "blendShape/mouthShrugUpper": .mouthShrugUpper,
        "blendShape/mouthSmileLeft": .mouthSmileLeft,
        "blendShape/mouthSmileRight": .mouthSmileRight,
        "blendShape/mouthStretchLeft": .mouthStretchLeft,
        "blendShape/mouthStretchRight": .mouthStretchRight,
        "blendShape/mouthUpperUpLeft": .mouthUpperUpLeft,
        "blendShape/mouthUpperUpRight": .mouthUpperUpRight,
        "blendShape/noseSneerLeft": .noseSneerLeft,
        "blendShape/noseSneerRight": .noseSneerRight,
        "blendShape/tongueOut": .tongueOut,
    ]
    
    public static let defaultActive: OrderedDictionary<String, Bool> = {
        var keys: OrderedDictionary<String, Bool> = [:]
        for key in simd_float4x4.matrixKeys.map({ "camera/\($0)" }) { keys[key] = true }
        for key in simd_float4x4.matrixKeys.map({ "face/\($0)" }) { keys[key] = true }
        for key in simd_float4x4.matrixKeys.map({ "eye/left/\($0)" }) { keys[key] = false }
        for key in simd_float4x4.matrixKeys.map({ "eye/right/\($0)" }) { keys[key] = false }
        for key in ["x", "y", "z"].map({ "lookAt/\($0)" }) { keys[key] = false }
        keys["blendShape/browDownLeft"] = false
        keys["blendShape/browDownRight"] = false
        keys["blendShape/browInnerUp"] = false
        keys["blendShape/browOuterUpLeft"] = false
        keys["blendShape/browOuterUpRight"] = false
        keys["blendShape/cheekPuff"] = false
        keys["blendShape/cheekSquintLeft"] = false
        keys["blendShape/cheekSquintRight"] = false
        keys["blendShape/eyeBlinkLeft"] = false
        keys["blendShape/eyeBlinkRight"] = false
        keys["blendShape/eyeLookDownLeft"] = false
        keys["blendShape/eyeLookDownRight"] = false
        keys["blendShape/eyeLookInLeft"] = false
        keys["blendShape/eyeLookInRight"] = false
        keys["blendShape/eyeLookOutLeft"] = false
        keys["blendShape/eyeLookOutRight"] = false
        keys["blendShape/eyeLookUpLeft"] = false
        keys["blendShape/eyeLookUpRight"] = false
        keys["blendShape/eyeSquintLeft"] = false
        keys["blendShape/eyeSquintRight"] = false
        keys["blendShape/eyeWideLeft"] = false
        keys["blendShape/eyeWideRight"] = false
        keys["blendShape/jawForward"] = false
        keys["blendShape/jawLeft"] = false
        keys["blendShape/jawOpen"] = false
        keys["blendShape/jawRight"] = false
        keys["blendShape/mouthClose"] = false
        keys["blendShape/mouthDimpleLeft"] = false
        keys["blendShape/mouthDimpleRight"] = false
        keys["blendShape/mouthFrownLeft"] = false
        keys["blendShape/mouthFrownRight"] = false
        keys["blendShape/mouthFunnel"] = false
        keys["blendShape/mouthLeft"] = false
        keys["blendShape/mouthLowerDownLeft"] = false
        keys["blendShape/mouthLowerDownRight"] = false
        keys["blendShape/mouthPressLeft"] = false
        keys["blendShape/mouthPressRight"] = false
        keys["blendShape/mouthPucker"] = false
        keys["blendShape/mouthRight"] = false
        keys["blendShape/mouthRollLower"] = false
        keys["blendShape/mouthRollUpper"] = false
        keys["blendShape/mouthShrugLower"] = false
        keys["blendShape/mouthShrugUpper"] = false
        keys["blendShape/mouthSmileLeft"] = false
        keys["blendShape/mouthSmileRight"] = false
        keys["blendShape/mouthStretchLeft"] = false
        keys["blendShape/mouthStretchRight"] = false
        keys["blendShape/mouthUpperUpLeft"] = false
        keys["blendShape/mouthUpperUpRight"] = false
        keys["blendShape/noseSneerLeft"] = false
        keys["blendShape/noseSneerRight"] = false
        keys["blendShape/tongueOut"] = false
        return keys
    }()
    
    public func value(for address: String) -> CGFloat? {
        if let key = address.dropPrefix("camera/") {
            return cameraTransform.flatMap { simd_float4x4($0).matrixValue(for: key) }
        }
        guard let faceAnchor else { return nil }
        if let key = address.dropPrefix("face/") {
            return faceAnchor.transform.matrixValue(for: key)
        }
        if let key = address.dropPrefix("eye/left/") {
            return faceAnchor.leftEyeTransform.matrixValue(for: key)
        }
        if let key = address.dropPrefix("eye/right/") {
            return faceAnchor.rightEyeTransform.matrixValue(for: key)
        }
        switch address {
        case "lookAt/x":
            return CGFloat(faceAnchor.lookAtPoint.x)
        case "lookAt/y":
            return CGFloat(faceAnchor.lookAtPoint.y)
        case "lookAt/z":
            return CGFloat(faceAnchor.lookAtPoint.z)
        default:
            guard let blendShapeLocation = Self.blendShapeLocations[address] else { return nil }
            return CGFloat((faceAnchor.blendShapes[blendShapeLocation] ?? 0.0).floatValue)
        }
    }

    public func values() -> [String: CGFloat] {
        var values: [String: CGFloat] = [:]
        for (address, _) in Self.defaultActive {
            if let value = value(for: address) {
                values[address] = value
            }
        }
        return values
    }
}

private extension String {

    func dropPrefix(_ prefix: String) -> String? {
        guard hasPrefix(prefix) else { return nil }
        return String(dropFirst(prefix.count))
    }
}

#endif
