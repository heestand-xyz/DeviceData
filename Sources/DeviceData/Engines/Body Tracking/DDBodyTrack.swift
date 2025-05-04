#if os(iOS)

import ARKit
import SceneKit
import simd
import OrderedCollections

public struct DDBodyTrack {
    
    public let cameraTransform: SCNMatrix4?
    public let bodyAnchor: ARBodyAnchor?
    
    public init(cameraTransform: SCNMatrix4?, bodyAnchor: ARBodyAnchor?) {
        self.cameraTransform = cameraTransform
        self.bodyAnchor = bodyAnchor
    }
}

extension DDBodyTrack {
    
    public static let defaultActive: OrderedDictionary<String, Bool> = {
        var keys: OrderedDictionary<String, Bool> = [:]
        for key in simd_float4x4.matrixKeys.map({ "camera/\($0)" }) { keys[key] = true }
        for key in simd_float4x4.matrixKeys.map({ "skeleton/local/root/\($0)" }) { keys[key] = true }
        for key in simd_float4x4.matrixKeys.map({ "skeleton/local/head/\($0)" }) { keys[key] = false }
        for key in simd_float4x4.matrixKeys.map({ "skeleton/local/leftHand/\($0)" }) { keys[key] = false }
        for key in simd_float4x4.matrixKeys.map({ "skeleton/local/rightHand/\($0)" }) { keys[key] = false }
        for key in simd_float4x4.matrixKeys.map({ "skeleton/local/leftShoulder/\($0)" }) { keys[key] = false }
        for key in simd_float4x4.matrixKeys.map({ "skeleton/local/rightShoulder/\($0)" }) { keys[key] = false }
        for key in simd_float4x4.matrixKeys.map({ "skeleton/local/leftFoot/\($0)" }) { keys[key] = false }
        for key in simd_float4x4.matrixKeys.map({ "skeleton/local/rightFoot/\($0)" }) { keys[key] = false }
        for key in simd_float4x4.matrixKeys.map({ "skeleton/model/root/\($0)" }) { keys[key] = true }
        for key in simd_float4x4.matrixKeys.map({ "skeleton/model/head/\($0)" }) { keys[key] = false }
        for key in simd_float4x4.matrixKeys.map({ "skeleton/model/leftHand/\($0)" }) { keys[key] = false }
        for key in simd_float4x4.matrixKeys.map({ "skeleton/model/rightHand/\($0)" }) { keys[key] = false }
        for key in simd_float4x4.matrixKeys.map({ "skeleton/model/leftShoulder/\($0)" }) { keys[key] = false }
        for key in simd_float4x4.matrixKeys.map({ "skeleton/model/rightShoulder/\($0)" }) { keys[key] = false }
        for key in simd_float4x4.matrixKeys.map({ "skeleton/model/leftFoot/\($0)" }) { keys[key] = false }
        for key in simd_float4x4.matrixKeys.map({ "skeleton/model/rightFoot/\($0)" }) { keys[key] = false }
        return keys
    }()
    
    public func values() -> [String: CGFloat] {
        
        var allValues: [String : CGFloat] = [:]
        
        if let bodyAnchor {
            var taggedTransforms: [String: simd_float4x4?] = [:]
            taggedTransforms["skeleton/local/root"] = bodyAnchor.skeleton.localTransform(for: .root)
            taggedTransforms["skeleton/local/head"] = bodyAnchor.skeleton.localTransform(for: .head)
            taggedTransforms["skeleton/local/leftHand"] = bodyAnchor.skeleton.localTransform(for: .leftHand)
            taggedTransforms["skeleton/local/rightHand"] = bodyAnchor.skeleton.localTransform(for: .rightHand)
            taggedTransforms["skeleton/local/leftShoulder"] = bodyAnchor.skeleton.localTransform(for: .leftShoulder)
            taggedTransforms["skeleton/local/rightShoulder"] = bodyAnchor.skeleton.localTransform(for: .rightShoulder)
            taggedTransforms["skeleton/local/leftFoot"] = bodyAnchor.skeleton.localTransform(for: .leftFoot)
            taggedTransforms["skeleton/local/rightFoot"] = bodyAnchor.skeleton.localTransform(for: .rightFoot)
            taggedTransforms["skeleton/model/root"] = bodyAnchor.skeleton.modelTransform(for: .root)
            taggedTransforms["skeleton/model/head"] = bodyAnchor.skeleton.modelTransform(for: .head)
            taggedTransforms["skeleton/model/leftHand"] = bodyAnchor.skeleton.modelTransform(for: .leftHand)
            taggedTransforms["skeleton/model/rightHand"] = bodyAnchor.skeleton.modelTransform(for: .rightHand)
            taggedTransforms["skeleton/model/leftShoulder"] = bodyAnchor.skeleton.modelTransform(for: .leftShoulder)
            taggedTransforms["skeleton/model/rightShoulder"] = bodyAnchor.skeleton.modelTransform(for: .rightShoulder)
            taggedTransforms["skeleton/model/leftFoot"] = bodyAnchor.skeleton.modelTransform(for: .leftFoot)
            taggedTransforms["skeleton/model/rightFoot"] = bodyAnchor.skeleton.modelTransform(for: .rightFoot)
            for (key, transform) in taggedTransforms {
                for (subKey, value) in transform?.matrixValues() ?? [:] {
                    allValues["\(key)/\(subKey)"] = value
                }
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
