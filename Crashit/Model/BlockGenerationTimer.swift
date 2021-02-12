import Foundation

//ブロックの定期的な生成
class BlockGenerationTimer: NSObject {
    
    var timer = Timer()
    var timerInProgressCallback: (() -> Void)!
    
    func startTimer(interval: TimeInterval, timerInProgress: @escaping () -> Void) {
        timer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(BlockGenerationTimer.updateTime), userInfo: nil, repeats: true)
        timerInProgressCallback = timerInProgress
    }
    
    @objc func updateTime() {
        timerInProgressCallback()
    }
}
