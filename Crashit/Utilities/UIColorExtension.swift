import UIKit

extension UIColor {
    //色から画像を生成
    func createImage() -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(self.cgColor)
        context!.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
    
    //色を暗くする
    func darkerColor() -> CGColor {
        let colorComponents = self.cgColor.components!
        return UIColor(red: max(colorComponents[0] - 0.2, 0.0), green: max(colorComponents[1] - 0.2, 0.0), blue: max(colorComponents[2] - 0.2, 0.0), alpha: 1).cgColor
    }
}
