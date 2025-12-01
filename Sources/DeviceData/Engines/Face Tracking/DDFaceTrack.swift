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
    
    public func values() -> [String: CGFloat] {
        
        var allValues: [String : CGFloat] = [:]
        
        if let faceAnchor {
            
            let blendShapeValues: [String: NSNumber] = [
                "blendShape/browDownLeft" : faceAnchor.blendShapes[.browDownLeft] ?? 0.0,
                "blendShape/browDownRight" : faceAnchor.blendShapes[.browDownRight] ?? 0.0,
                "blendShape/browInnerUp" : faceAnchor.blendShapes[.browInnerUp] ?? 0.0,
                "blendShape/browOuterUpLeft" : faceAnchor.blendShapes[.browOuterUpLeft] ?? 0.0,
                "blendShape/browOuterUpRight" : faceAnchor.blendShapes[.browOuterUpRight] ?? 0.0,
                "blendShape/cheekPuff" : faceAnchor.blendShapes[.cheekPuff] ?? 0.0,
                "blendShape/cheekSquintLeft" : faceAnchor.blendShapes[.cheekSquintLeft] ?? 0.0,
                "blendShape/cheekSquintRight" : faceAnchor.blendShapes[.cheekSquintRight] ?? 0.0,
                "blendShape/eyeBlinkLeft" : faceAnchor.blendShapes[.eyeBlinkLeft] ?? 0.0,
                "blendShape/eyeBlinkRight" : faceAnchor.blendShapes[.eyeBlinkRight] ?? 0.0,
                "blendShape/eyeLookDownLeft" : faceAnchor.blendShapes[.eyeLookDownLeft] ?? 0.0,
                "blendShape/eyeLookDownRight" : faceAnchor.blendShapes[.eyeLookDownRight] ?? 0.0,
                "blendShape/eyeLookInLeft" : faceAnchor.blendShapes[.eyeLookInLeft] ?? 0.0,
                "blendShape/eyeLookInRight" : faceAnchor.blendShapes[.eyeLookInRight] ?? 0.0,
                "blendShape/eyeLookOutLeft" : faceAnchor.blendShapes[.eyeLookOutLeft] ?? 0.0,
                "blendShape/eyeLookOutRight" : faceAnchor.blendShapes[.eyeLookOutRight] ?? 0.0,
                "blendShape/eyeLookUpLeft" : faceAnchor.blendShapes[.eyeLookUpLeft] ?? 0.0,
                "blendShape/eyeLookUpRight" : faceAnchor.blendShapes[.eyeLookUpRight] ?? 0.0,
                "blendShape/eyeSquintLeft" : faceAnchor.blendShapes[.eyeSquintLeft] ?? 0.0,
                "blendShape/eyeSquintRight" : faceAnchor.blendShapes[.eyeSquintRight] ?? 0.0,
                "blendShape/eyeWideLeft" : faceAnchor.blendShapes[.eyeWideLeft] ?? 0.0,
                "blendShape/eyeWideRight" : faceAnchor.blendShapes[.eyeWideRight] ?? 0.0,
                "blendShape/jawForward" : faceAnchor.blendShapes[.jawForward] ?? 0.0,
                "blendShape/jawLeft" : faceAnchor.blendShapes[.jawLeft] ?? 0.0,
                "blendShape/jawOpen" : faceAnchor.blendShapes[.jawOpen] ?? 0.0,
                "blendShape/jawRight" : faceAnchor.blendShapes[.jawRight] ?? 0.0,
                "blendShape/mouthClose" : faceAnchor.blendShapes[.mouthClose] ?? 0.0,
                "blendShape/mouthDimpleLeft" : faceAnchor.blendShapes[.mouthDimpleLeft] ?? 0.0,
                "blendShape/mouthDimpleRight" : faceAnchor.blendShapes[.mouthDimpleRight] ?? 0.0,
                "blendShape/mouthFrownLeft" : faceAnchor.blendShapes[.mouthFrownLeft] ?? 0.0,
                "blendShape/mouthFrownRight" : faceAnchor.blendShapes[.mouthFrownRight] ?? 0.0,
                "blendShape/mouthFunnel" : faceAnchor.blendShapes[.mouthFunnel] ?? 0.0,
                "blendShape/mouthLeft" : faceAnchor.blendShapes[.mouthLeft] ?? 0.0,
                "blendShape/mouthLowerDownLeft" : faceAnchor.blendShapes[.mouthLowerDownLeft] ?? 0.0,
                "blendShape/mouthLowerDownRight" : faceAnchor.blendShapes[.mouthLowerDownRight] ?? 0.0,
                "blendShape/mouthPressLeft" : faceAnchor.blendShapes[.mouthPressLeft] ?? 0.0,
                "blendShape/mouthPressRight" : faceAnchor.blendShapes[.mouthPressRight] ?? 0.0,
                "blendShape/mouthPucker" : faceAnchor.blendShapes[.mouthPucker] ?? 0.0,
                "blendShape/mouthRight" : faceAnchor.blendShapes[.mouthRight] ?? 0.0,
                "blendShape/mouthRollLower" : faceAnchor.blendShapes[.mouthRollLower] ?? 0.0,
                "blendShape/mouthRollUpper" : faceAnchor.blendShapes[.mouthRollUpper] ?? 0.0,
                "blendShape/mouthShrugLower" : faceAnchor.blendShapes[.mouthShrugLower] ?? 0.0,
                "blendShape/mouthShrugUpper" : faceAnchor.blendShapes[.mouthShrugUpper] ?? 0.0,
                "blendShape/mouthSmileLeft" : faceAnchor.blendShapes[.mouthSmileLeft] ?? 0.0,
                "blendShape/mouthSmileRight" : faceAnchor.blendShapes[.mouthSmileRight] ?? 0.0,
                "blendShape/mouthStretchLeft" : faceAnchor.blendShapes[.mouthStretchLeft] ?? 0.0,
                "blendShape/mouthStretchRight" : faceAnchor.blendShapes[.mouthStretchRight] ?? 0.0,
                "blendShape/mouthUpperUpLeft" : faceAnchor.blendShapes[.mouthUpperUpLeft] ?? 0.0,
                "blendShape/mouthUpperUpRight" : faceAnchor.blendShapes[.mouthUpperUpRight] ?? 0.0,
                "blendShape/noseSneerLeft" : faceAnchor.blendShapes[.noseSneerLeft] ?? 0.0,
                "blendShape/noseSneerRight" : faceAnchor.blendShapes[.noseSneerRight] ?? 0.0,
                "blendShape/tongueOut" : faceAnchor.blendShapes[.tongueOut] ?? 0.0,
            ]
            
            for (key, value) in blendShapeValues {
                allValues[key] = CGFloat(value.floatValue)
            }
            
            allValues["lookAt/x"] = CGFloat(faceAnchor.lookAtPoint.x)
            allValues["lookAt/y"] = CGFloat(faceAnchor.lookAtPoint.y)
            allValues["lookAt/z"] = CGFloat(faceAnchor.lookAtPoint.z)
            
            for (key, value) in faceAnchor.leftEyeTransform.matrixValues() {
                allValues["eye/left/\(key)"] = value
            }
            
            for (key, value) in faceAnchor.rightEyeTransform.matrixValues() {
                allValues["eye/right/\(key)"] = value
            }
            
            for (key, value) in faceAnchor.transform.matrixValues() {
                allValues["face/\(key)"] = value
            }
        }
        
        if let cameraTransform {
            
            for (key, value) in simd_float4x4(cameraTransform).matrixValues() {
                allValues["camera/\(key)"] = value
            }
        }
        
        return allValues
    }
}

#endif
