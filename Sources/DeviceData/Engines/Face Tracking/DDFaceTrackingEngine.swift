#if !os(visionOS)

import Combine
import ARKit
import SceneKit
import AVKit

public final class DDFaceTrackingEngine: NSObject, DDEngine {
    
    public var available: Bool {
        ARFaceTrackingConfiguration.isSupported
    }

    var session: ARSession?
    
    let cameraTransform: PassthroughSubject<SCNMatrix4?, Never> = .init()
    let faceAnchor: PassthroughSubject<ARFaceAnchor?, Never> = .init()
    
    public var authorization: CurrentValueSubject<AVAuthorizationStatus, Never>
    
    public override init() {
        authorization = .init(AVCaptureDevice.authorizationStatus(for: .video))
        super.init()
    }
    
    func authorize() {
        AVCaptureDevice.requestAccess(for: .video) { [weak self] _ in
            DispatchQueue.main.async {
                self?.authorization.value = AVCaptureDevice.authorizationStatus(for: .video)
            }
        }
    }
    
    func start() {
        session = ARSession()
        let configuration: ARConfiguration = ARFaceTrackingConfiguration()
        if let videoFormat = ARFaceTrackingConfiguration.supportedVideoFormats.first {
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
    
    func stop() {
        session?.pause()
        session = nil
        cameraTransform.send(nil)
        faceAnchor.send(nil)
    }
}

extension DDFaceTrackingEngine: ARSessionDelegate {
    
    public func session(_ session: ARSession, didUpdate frame: ARFrame) {
        cameraTransform.send(SCNMatrix4(frame.camera.transform))
    }
    
    public func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {}
    
    public func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        guard let faceAnchor = anchors.first as? ARFaceAnchor else { return }
        self.faceAnchor.send(faceAnchor)
    }
    
    public func session(_ session: ARSession, didRemove anchors: [ARAnchor]) {
        self.faceAnchor.send(nil)
    }
}

#endif
