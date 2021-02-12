import AVFoundation
import AudioToolbox

class SoundEffectPlayer {
    
    static let shared = SoundEffectPlayer()
    var isEnabled = true
    
    private var soundEffectPlayers = [SoundEffect : AVAudioPlayer]()
    
    private init() {
        try! AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.ambient)
        SoundEffect.allCases.forEach {
            let soundURL = URL(fileURLWithPath: Bundle.main.path(forResource: $0.rawValue, ofType: "mp3")!)
            let soundPlayer = try! AVAudioPlayer(contentsOf: soundURL)
            soundPlayer.volume = 0.09
            soundEffectPlayers[$0] = soundPlayer
        }
    }
    
    func play(_ soundEffect: SoundEffect) {
        if !SoundEffectPlayer.shared.isEnabled { return }
        soundEffectPlayers[soundEffect]!.play()
    }
}


enum SoundEffect: String, CaseIterable {
    case hitWall = "hitWall"
    case breakBlock = "breakBlock"
    case missed = "missed"
    case start = "start"
    case gameover = "gameover"
    case item = "item"
}
