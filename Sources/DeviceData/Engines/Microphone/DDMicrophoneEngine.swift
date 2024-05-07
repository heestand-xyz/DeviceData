import Combine
import AVKit

public final class DDMicrophoneEngine: NSObject, DDEngine {
    
    private let recorder: AVAudioRecorder
    private var timer: Timer?
    
    public var amplitude: PassthroughSubject<DDAudio, Never> = .init()
    
    public var authorization: CurrentValueSubject<AVAuthorizationStatus, Never>
    
    public override init() {

        recorder = AVAudioRecorder()
        recorder.isMeteringEnabled = true
        
        authorization = .init(AVCaptureDevice.authorizationStatus(for: .audio))

        super.init()
    }
    
    func authorize() {
        AVCaptureDevice.requestAccess(for: .audio) { [weak self] _ in
            DispatchQueue.main.async {
                self?.authorization.value = AVCaptureDevice.authorizationStatus(for: .audio)
            }
        }
    }
    
    func startUpdating() {
        recorder.record()
        timer = .scheduledTimer(withTimeInterval: 0.01, repeats: true) { [weak self] _ in
            guard let self else { return }
            recorder.updateMeters()
            let averagePower: Float = recorder.averagePower(forChannel: 0)
            amplitude.send(DDAudio(averagePower: CGFloat(averagePower)))
        }
    }
    
    func stopUpdating() {
        recorder.pause()
        timer?.invalidate()
        timer = nil
    }
}
