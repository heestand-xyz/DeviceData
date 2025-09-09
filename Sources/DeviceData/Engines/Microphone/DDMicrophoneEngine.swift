import Combine
import AVKit

public final class DDMicrophoneEngine: NSObject, DDEngine, @unchecked Sendable {

    private let recorder: AVAudioRecorder?
    private var timer: Timer?
    
    private var url: URL?
    
    public var audio: PassthroughSubject<DDAudio, Never> = .init()
    
    public var authorization: CurrentValueSubject<AVAuthorizationStatus, Never>
//    public var authorization: CurrentValueSubject<DDAuthorization, Never>

    public var isAuthorized: Bool {
        authorization.value == .authorized
    }
    
    public override init() {

        let url: URL = FileManager.default.temporaryDirectory
            .appending(path: "audio_\(UUID().uuidString).m4a")
        self.url = url
        
        recorder = try? AVAudioRecorder(url: url, settings: [:])
        
        authorization = .init(AVCaptureDevice.authorizationStatus(for: .audio))
//        if #available(iOS 17.0, *) {
//            authorization = .init(AudioAuth.authorization())
//        } else {
//            authorization = .init(.unknown)
//        }

        super.init()
        
#if !os(macOS)
        try? AVAudioSession.sharedInstance().setCategory(.record)
#endif
    }
    
    public func authorizeIfNeeded() async -> Bool {
        if isAuthorized { return true }
        return await withCheckedContinuation { continuation in
            AVCaptureDevice.requestAccess(for: .audio) { [weak self] _ in
                let status = AVCaptureDevice.authorizationStatus(for: .audio)
                self?.authorization.value = status
                continuation.resume(returning: status == .authorized)
            }
        }
    }
        
    public func authorize() {
        AVCaptureDevice.requestAccess(for: .audio) { [weak self] _ in
            DispatchQueue.main.async {
                self?.authorization.value = AVCaptureDevice.authorizationStatus(for: .audio)
            }
        }
    }
    
    public func startUpdating() {
        guard recorder?.prepareToRecord() == true else { return }
        recorder?.isMeteringEnabled = true
        recorder?.record()
        timer = .scheduledTimer(withTimeInterval: 0.01, repeats: true) { [weak self] _ in
            guard let self else { return }
            recorder?.updateMeters()
            guard let averagePower: Float = recorder?.averagePower(forChannel: 0) else { return }
            guard let peakPower: Float = recorder?.peakPower(forChannel: 0) else { return }
            audio.send(DDAudio(averagePower: CGFloat(averagePower), peakPower: CGFloat(peakPower)))
        }
    }
    
    public func stopUpdating() {
        recorder?.stop()
        recorder?.deleteRecording()
        timer?.invalidate()
        timer = nil
    }
    
//    @available(iOS 17.0, *)
//    struct AudioAuth {
//        
//        static func authorize() async {
//            await AVAudioApplication.requestRecordPermission()
//        }
//        
//        static func authorization() -> DDAuthorization {
//            switch AVAudioApplication.shared.recordPermission {
//            case .undetermined:
//                return .notDetermined
//            case .denied:
//                return .denied
//            case .granted:
//                return .authorized
//            @unknown default:
//                return .unknown
//            }
//        }
//    }
}
