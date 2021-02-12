import UIKit

extension UIView {
    //角丸
    func roundCorner(radius: CGFloat) {
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = true
    }
    
    //ボタンの同時タッチをさせない
    func setExclusiveTouch() {
        for button in self.subviews {
            if button is UIButton {
                (button as! UIButton).isExclusiveTouch = true
            }
        }
    }
}
