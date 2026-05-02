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

    private static let jointIndicesByNamePath: [String: Int] = {
        var indices: [String: Int] = [:]
        for (index, rawJointName) in ARSkeletonDefinition.defaultBody3D.jointNames.enumerated() {
            let namePath = rawJointName
                .replacingOccurrences(of: "_joint", with: "")
                .replacingOccurrences(of: "_", with: "/")
            indices[namePath] = index
        }
        return indices
    }()
    
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
    
    public func value(for address: String) -> CGFloat? {
        if let key = address.dropPrefix("camera/") {
            return cameraTransform.flatMap { simd_float4x4($0).matrixValue(for: key) }
        }
        guard let bodyAnchor else { return nil }
        if let key = address.dropPrefix("skeleton/transform/") {
            return bodyAnchor.transform.matrixValue(for: key)
        }
        if let key = address.dropPrefix("skeleton/model/") {
            return jointValue(for: key, in: bodyAnchor, transformType: .model)
        }
        if let key = address.dropPrefix("skeleton/local/") {
            return jointValue(for: key, in: bodyAnchor, transformType: .local)
        }
        return nil
    }

    public func values() -> [String: CGFloat] {
        var values: [String: CGFloat] = [:]
        for address in Self.defaultActive.keys {
            if let value = value(for: address) {
                values[address] = value
            }
        }
        return values
    }
}

private extension DDBodyTrack {

    enum TransformType {
        case model
        case local
    }

    func jointValue(
        for key: String,
        in bodyAnchor: ARBodyAnchor,
        transformType: TransformType
    ) -> CGFloat? {
        let matrixKeyPrefix = "/position/"
        guard let range = key.range(of: matrixKeyPrefix, options: .backwards) else { return nil }
        let namePath = String(key[..<range.lowerBound])
        let matrixKey = "position/\(key[range.upperBound...])"
        guard let jointIndex = Self.jointIndicesByNamePath[namePath] else { return nil }
        let skeleton = bodyAnchor.skeleton
        guard skeleton.isJointTracked(jointIndex) else { return nil }
        guard skeleton.jointModelTransforms.indices.contains(jointIndex) else { return nil }
        guard skeleton.jointLocalTransforms.indices.contains(jointIndex) else { return nil }
        let jointTransform: simd_float4x4
        switch transformType {
        case .model:
            jointTransform = skeleton.jointModelTransforms[jointIndex]
        case .local:
            jointTransform = skeleton.jointLocalTransforms[jointIndex]
        }
        return (bodyAnchor.transform * jointTransform).matrixValue(for: matrixKey)
    }
}

private extension String {

    func dropPrefix(_ prefix: String) -> String? {
        guard hasPrefix(prefix) else { return nil }
        return String(dropFirst(prefix.count))
    }
}

#endif
