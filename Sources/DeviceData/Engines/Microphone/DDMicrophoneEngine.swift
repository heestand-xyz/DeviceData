import Combine
import AVKit

public final class DDMicrophoneEngine: NSObject, DDEngine, @unchecked Sendable {

    private let recorder: AVAudioRecorder?
    private let meteringQueue = DispatchQueue(label: "data-osc.microphone.metering", qos: .userInteractive)
    private var timer: DispatchSourceTimer?
    private static let meteringInterval: DispatchTimeInterval = .nanoseconds(1_000_000_000 / 120)
    
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
    
    @MainActor
    public func startAll() {
        startUpdating()
    }
    
    @MainActor
    public func stopAll() {
        stopUpdating()
    }
    
    public func startUpdating() {
        meteringQueue.async { [weak self] in
            guard let self else { return }
            self.timer?.cancel()
            self.timer = nil
            guard self.recorder?.prepareToRecord() == true else { return }
            self.recorder?.isMeteringEnabled = true
            self.recorder?.record()
            let timer = DispatchSource.makeTimerSource(queue: self.meteringQueue)
            timer.schedule(
                deadline: .now() + Self.meteringInterval,
                repeating: Self.meteringInterval,
                leeway: .milliseconds(1)
            )
            timer.setEventHandler { [weak self] in
                guard let self else { return }
                self.recorder?.updateMeters()
                guard let averagePower: Float = self.recorder?.averagePower(forChannel: 0) else { return }
                guard let peakPower: Float = self.recorder?.peakPower(forChannel: 0) else { return }
                self.audio.send(DDAudio(averagePower: CGFloat(averagePower), peakPower: CGFloat(peakPower)))
            }
            self.timer = timer
            timer.resume()
        }
    }
    
    public func stopUpdating() {
        meteringQueue.async { [weak self] in
            guard let self else { return }
            self.timer?.cancel()
            self.timer = nil
            self.recorder?.stop()
            self.recorder?.deleteRecording()
        }
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
