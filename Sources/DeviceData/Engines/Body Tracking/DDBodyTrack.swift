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
        for key in simd_float4x4.matrixKeys.map({ "skeleton/transform/\($0)" }) { keys[key] = false }
        let defaultNamePaths: [String] = [
            "root",
            "head",
            "left/hand",
            "right/hand",
            "left/shoulder/1",
            "right/shoulder/1",
            "left/foot",
            "right/foot",
        ]
        for rawJointName in ARSkeletonDefinition.defaultBody3D.jointNames {
            let namePath = rawJointName
                .replacingOccurrences(of: "_joint", with: "")
                .replacingOccurrences(of: "_", with: "/")
            for subKey in simd_float4x4.matrixKeys {
                guard subKey.starts(with: "position") else { continue }
                let modelKey = "skeleton/model/\(namePath)/\(subKey)"
                let localKey = "skeleton/local/\(namePath)/\(subKey)"
                keys[modelKey] = defaultNamePaths.contains(namePath)
                keys[localKey] = false
            }
        }
        for key in simd_float4x4.matrixKeys.map({ "camera/\($0)" }) { keys[key] = false }
        return keys
    }()
    
    public func values() -> [String: CGFloat] {
        
        var allValues: [String : CGFloat] = [:]
        
        if let bodyAnchor {
            let skeleton = bodyAnchor.skeleton
            var taggedTransforms: [String: simd_float4x4?] = [:]
            taggedTransforms["skeleton/transform"] = bodyAnchor.transform
            for (i, rawJointName) in ARSkeletonDefinition.defaultBody3D.jointNames.enumerated() {
                let namePath = rawJointName
                    .replacingOccurrences(of: "_joint", with: "")
                    .replacingOccurrences(of: "_", with: "/")
                guard skeleton.isJointTracked(i) else { continue }
                guard skeleton.jointModelTransforms.indices.contains(i) else { continue }
                let modelTransform = skeleton.jointModelTransforms[i]
                let localTransform = skeleton.jointLocalTransforms[i]
                taggedTransforms["skeleton/model/\(namePath)"] = bodyAnchor.transform * modelTransform
                taggedTransforms["skeleton/local/\(namePath)"] = bodyAnchor.transform * localTransform
            }
            for (key, transform) in taggedTransforms {
                for (subKey, value) in transform?.matrixValues() ?? [:] {
                    if key != "skeleton/transform" {
                        guard subKey.starts(with: "position") else { continue }
                    }
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
