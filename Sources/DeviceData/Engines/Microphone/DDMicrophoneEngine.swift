import Combine
import AVKit

@available(iOS 17.0, *)
public final class DDMicrophoneEngine: NSObject, DDEngine {
    
    private let recorder: AVAudioRecorder
    private var timer: Timer?
    
    public var amplitude: PassthroughSubject<CGFloat, Never> = .init()
    
    public var authorization: CurrentValueSubject<AVAudioApplication.recordPermission, Never>
    
    public override init() {

        recorder = AVAudioRecorder()
        recorder.isMeteringEnabled = true
        
        authorization = .init(AVAudioApplication.shared.recordPermission)
        
        super.init()
    }
    
    func authorize() {
        Task {
            if await AVAudioApplication.requestRecordPermission() {
                await MainActor.run {
                    authorization.value = .granted
                }
            } else {
                await MainActor.run {
                    authorization.value = .denied
                }
            }
        }
    }
    
    func startUpdating() {
        recorder.record()
        timer = .scheduledTimer(withTimeInterval: 0.01, repeats: true) { [weak self] _ in
            guard let self else { return }
            recorder.updateMeters()
            let currentAmplitude: Float = 1 - pow(10, recorder.averagePower(forChannel: 0) / 20)
            amplitude.send(CGFloat(currentAmplitude))
        }
    }
    
    func stopUpdating() {
        recorder.pause()
        timer?.invalidate()
        timer = nil
    }
}
