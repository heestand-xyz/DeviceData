#if os(iOS)

import Combine
import ARKit
import SceneKit
import AVKit

public final class DDBodyTrackingEngine: NSObject, DDEngine, @unchecked Sendable {
    
    public var available: Bool {
        ARFaceTrackingConfiguration.isSupported
    }

    var session: ARSession?
    
    public let cameraTransform: PassthroughSubject<SCNMatrix4?, Never> = .init()
    public let bodyAnchor: PassthroughSubject<ARBodyAnchor?, Never> = .init()
    
    public var authorization: CurrentValueSubject<AVAuthorizationStatus, Never>
    
    public var isAuthorized: Bool {
        authorization.value == .authorized
    }
    
    public override init() {
        authorization = .init(AVCaptureDevice.authorizationStatus(for: .video))
        super.init()
    }
    
    public func authorizeIfNeeded() async -> Bool {
        if isAuthorized { return true }
        return await withCheckedContinuation { continuation in
            AVCaptureDevice.requestAccess(for: .video) { [weak self] _ in
                let status = AVCaptureDevice.authorizationStatus(for: .video)
                self?.authorization.value = status
                continuation.resume(returning: status == .authorized)
            }
        }
    }
    
    public func authorize() {
        AVCaptureDevice.requestAccess(for: .video) { [weak self] _ in
            DispatchQueue.main.async {
                self?.authorization.value = AVCaptureDevice.authorizationStatus(for: .video)
            }
        }
    }
    
    @MainActor
    public func startAll() {
        start()
    }
    
    @MainActor
    public func stopAll() {
        stop()
    }
    
    public func start() {
        session = ARSession()
        let configuration: ARConfiguration = ARBodyTrackingConfiguration()
        if let videoFormat = ARBodyTrackingConfiguration.supportedVideoFormats.first {
            configuration.videoFormat = videoFormat
        }
        configuration.isLightEstimationEnabled = false
        let options: ARSession.RunOptions = [
            .resetTracking,
            .removeExistingAnchors
        ]
        session!.run(configuration, options: options)
        session!.delegate = self
    }
    
    public func stop() {
        session?.pause()
        session = nil
        cameraTransform.send(nil)
        bodyAnchor.send(nil)
    }
}

extension DDBodyTrackingEngine: ARSessionDelegate {
    
    public func session(_ session: ARSession, didUpdate frame: ARFrame) {
        cameraTransform.send(SCNMatrix4(frame.camera.transform))
        if let bodyAnchor = frame.anchors.compactMap({ $0 as? ARBodyAnchor }).first {
            self.bodyAnchor.send(bodyAnchor)            
        }
    }
    
    public func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {}
    
    public func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {}
    
    public func session(_ session: ARSession, didRemove anchors: [ARAnchor]) {
        self.bodyAnchor.send(nil)
    }
}

#endif
