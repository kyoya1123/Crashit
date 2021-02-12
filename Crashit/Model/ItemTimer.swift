import Foundation

//アイテムの有効時間
class ItemTimer: NSObject {
    
    var timer = Timer()
    var timerEndedCallback: (() -> Void)!
    var timerInProgressCallback: ((_ count: Int) -> Void)!
    var count = 0
    
    func startTimer(time: Int, timerEnded: @escaping () -> Void, timerInProgress: ((_ count: Int) -> Void)!) -> Timer {
        if !timer.isValid {
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ItemTimer.updateTime), userInfo: time, repeats: true)
            timerEndedCallback = timerEnded
            timerInProgressCallback = timerInProgress
        }
        return timer
    }
    
    @objc func updateTime(_ timer: Timer) {
        let time = timer.userInfo as! Int
        count += 1
        if count <= time {
            timerInProgressCallback(time - count)
        } else {
            timer.invalidate()
            timerEndedCallback()
        }
    }
}
