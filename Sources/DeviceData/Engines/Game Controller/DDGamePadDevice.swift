//
//  DDGamePadDevice.swift
//  DeviceData
//
//  Created by Anton Heestand on 2026-03-21.
//

public struct DDGamePadDevice: Identifiable, Sendable {
    public let id: String
    public let name: String
    public internal(set) var gamePad: DDGamePad
}
