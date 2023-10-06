import Foundation
import ColorThiefSwift

extension MMCQ.Color {
    
    //HSL色空間
    var hue: CGFloat {
        let colorComponents = makeUIColor().cgColor.components!.dropLast()
        if colorComponents.dropFirst().allSatisfy({ $0 == colorComponents.first }) {
            return 0
        }
        let max = CGFloat(colorComponents.max()!)
        let min = CGFloat(colorComponents.min()!)
        
        var tmp: CGFloat!
        switch colorComponents.firstIndex(of: max) {
        case 0:
            tmp = 60 * ((colorComponents[1] - colorComponents[2]) / (max - min))
        case 1:
            tmp = 60 * ((colorComponents[2] - colorComponents[0]) / (max - min)) + 120
        case 2:
            tmp = 60 * ((colorComponents[0] - colorComponents[1]) / (max - min)) + 240
        default:
            return 0
        }
        return tmp < 0 ? tmp + 360 : tmp
    }
    
    var lightness: CGFloat {
        let colorComponents = makeUIColor().cgColor.components!
        return  (0.2126 * CGFloat(colorComponents[0])) + (0.7152 * CGFloat(colorComponents[1])) + (0.0722 * CGFloat(colorComponents[2]))
    }
    
    var saturation: CGFloat {
        let colorComponents = makeUIColor().cgColor.components!
        let max = CGFloat(colorComponents.max()!)
        let min = CGFloat(colorComponents.min()!)
        if lightness < 0.5 {
            return (max - min) / (max + min)
        } else {
            return (max - min) / (510 - max - min)
        }
    }
}
