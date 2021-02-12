import UIKit

extension UIImage {
    //テクスチャのイメージを生成
    func texturelize() -> UIImage {
        var newImage: UIImage?
        UIGraphicsBeginImageContext(self.size)
        let width = self.size.width
        let height = self.size.height
        self.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
        newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
}
