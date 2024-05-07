import Combine
import AVKit

public final class DDMicrophoneEngine: NSObject, DDEngine {

    private let recorder: AVAudioRecorder?
    private var timer: Timer?
    
    private var url: URL?
    
    public var audio: PassthroughSubject<DDAudio, Never> = .init()
    
    public var authorization: CurrentValueSubject<AVAuthorizationStatus, Never>
    
    public override init() {

        let url: URL = Bundle.main.bundleURL.appending(path: "audio_\(UUID().uuidString)")
        self.url = url
        
        recorder = try? AVAudioRecorder(url: url, settings: [:])
        
        authorization = .init(AVCaptureDevice.authorizationStatus(for: .audio))

        super.init()
    }
    
    deinit {
        recorder?.stop()
        recorder?.deleteRecording()
        if let path = url?.path(percentEncoded: false) {
            try? FileManager.default.removeItem(atPath: path)
        }
    }
    
    func authorize() {
        AVCaptureDevice.requestAccess(for: .audio) { [weak self] _ in
            DispatchQueue.main.async {
                self?.authorization.value = AVCaptureDevice.authorizationStatus(for: .audio)
            }
        }
    }
    
    func startUpdating() {
        try? AVAudioSession.sharedInstance().setCategory(.playAndRecord)
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
    
    func stopUpdating() {
        recorder?.pause()
        timer?.invalidate()
        timer = nil
    }
}
