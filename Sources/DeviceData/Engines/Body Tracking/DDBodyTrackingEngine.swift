#if os(iOS)

import Combine
import ARKit
import SceneKit
import AVKit

public final class DDBodyTrackingEngine: NSObject, DDEngine {
    
    public var available: Bool {
        ARFaceTrackingConfiguration.isSupported
    }

    var session: ARSession?
    
    public let cameraTransform: PassthroughSubject<SCNMatrix4?, Never> = .init()
    public let bodyAnchor: PassthroughSubject<ARBodyAnchor?, Never> = .init()
    
    public var authorization: CurrentValueSubject<AVAuthorizationStatus, Never>
    
    public override init() {
        authorization = .init(AVCaptureDevice.authorizationStatus(for: .video))
        super.init()
    }
    
    public func authorize() {
        AVCaptureDevice.requestAccess(for: .video) { [weak self] _ in
            DispatchQueue.main.async {
                self?.authorization.value = AVCaptureDevice.authorizationStatus(for: .video)
            }
        }
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
    }
    
    public func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {}
    
    public func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        guard let bodyAnchor = anchors.first as? ARBodyAnchor else { return }
        self.bodyAnchor.send(bodyAnchor)
    }
    
    public func session(_ session: ARSession, didRemove anchors: [ARAnchor]) {
        self.bodyAnchor.send(nil)
    }
}

#endif
