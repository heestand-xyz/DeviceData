//
//  Matrix+Transform.swift
//  DeviceData
//
//  Created by Anton Heestand on 2025-05-04.
//

import simd
import CoreGraphics

extension simd_float4x4 {
    
    func matrixValues() -> [String: CGFloat] {
        
        var values: [String : CGFloat] = [:]
        
        values["position/x"] = CGFloat(columns.3.x)
        values["position/y"] = CGFloat(columns.3.y)
        values["position/z"] = CGFloat(columns.3.z)
        
        let rotationMatrix = simd_quatf(self)
        
        values["rotation/x"] = CGFloat(rotationMatrix.vector.x)
        values["rotation/y"] = CGFloat(rotationMatrix.vector.y)
        values["rotation/z"] = CGFloat(rotationMatrix.vector.z)
        values["rotation/w"] = CGFloat(rotationMatrix.vector.w)
        
        let eulerAngles = eulerAngles()
        
        values["rotation/yaw"] = CGFloat(eulerAngles.y)
        values["rotation/pitch"] = CGFloat(eulerAngles.x)
        values["rotation/roll"] = CGFloat(eulerAngles.z)
        
        return values
    }
    
    func eulerAngles() -> SIMD3<Float> {
        let q = simd_quatf(self)
        
        let sinr_cosp = 2 * (q.real * q.imag.x + q.imag.y * q.imag.z)
        let cosr_cosp = 1 - 2 * (q.imag.x * q.imag.x + q.imag.y * q.imag.y)
        let roll = atan2(sinr_cosp, cosr_cosp)

        let sinp = 2 * (q.real * q.imag.y - q.imag.z * q.imag.x)
        let pitch = abs(sinp) >= 1 ? copysign(.pi / 2, sinp) : asin(sinp)

        let siny_cosp = 2 * (q.real * q.imag.z + q.imag.x * q.imag.y)
        let cosy_cosp = 1 - 2 * (q.imag.y * q.imag.y + q.imag.z * q.imag.z)
        let yaw = atan2(siny_cosp, cosy_cosp)

        let rad2deg: Float = 180 / .pi
        return SIMD3<Float>(pitch, yaw, roll) * rad2deg
    }
    
    static let matrixKeys: [String] = [
        "position/x",
        "position/y",
        "position/z",
        "rotation/x",
        "rotation/y",
        "rotation/z",
        "rotation/w",
        "rotation/yaw",
        "rotation/pitch",
        "rotation/roll",
    ]
}
