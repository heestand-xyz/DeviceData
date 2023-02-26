import ARKit
import SceneKit
import simd

public struct DDFaceTrack {
    
    public let cameraTransform: SCNMatrix4?
    public let faceAnchor: ARFaceAnchor?
}

extension DDFaceTrack {
    
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
            
            allValues["faceAnchor/lookAtPoint/x"] = CGFloat(faceAnchor.lookAtPoint.x)
            allValues["faceAnchor/lookAtPoint/y"] = CGFloat(faceAnchor.lookAtPoint.y)
            allValues["faceAnchor/lookAtPoint/z"] = CGFloat(faceAnchor.lookAtPoint.z)
            
            for (key, value) in values(matrix: faceAnchor.leftEyeTransform) {
                allValues["faceAnchor/leftEye/\(key)"] = value
            }

            for (key, value) in values(matrix: faceAnchor.rightEyeTransform) {
                allValues["faceAnchor/rightEye/\(key)"] = value
            }
            
            for (key, value) in values(matrix: faceAnchor.transform) {
                allValues["faceAnchor/\(key)"] = value
            }
        }
        
        if let cameraTransform {
        
            for (key, value) in values(matrix: simd_float4x4(cameraTransform)) {
                allValues["camera/\(key)"] = value
            }
        }
        
        return allValues
    }
    
    private func values(matrix: simd_float4x4) -> [String: CGFloat] {
        
        var values: [String : CGFloat] = [:]
        
        values["position/x"] = CGFloat(matrix.columns.3.x)
        values["position/y"] = CGFloat(matrix.columns.3.y)
        values["position/z"] = CGFloat(matrix.columns.3.z)
        
        let rotationMatrix = simd_quatf(matrix)
        
        values["rotation/x"] = CGFloat(rotationMatrix.vector.x)
        values["rotation/y"] = CGFloat(rotationMatrix.vector.y)
        values["rotation/z"] = CGFloat(rotationMatrix.vector.z)
        values["rotation/w"] = CGFloat(rotationMatrix.vector.w)
        
        return values
    }
}
