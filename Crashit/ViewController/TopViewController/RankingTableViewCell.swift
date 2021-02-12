import UIKit

class RankingTableViewCell: UITableViewCell {
    
    @IBOutlet weak var rankLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    
    func setupLabels(_ rank: Int, _ user: UserDataSet, _ score: Int, _ ballType: BallType) {
        rankLabel.roundCorner(radius: rankLabel.frame.height / 2)
        rankLabel.text = String(rank)
        nameLabel.text = user.name
        scoreLabel.text = String(score)
        self.rankLabel.backgroundColor = #colorLiteral(red: 0.1147753969, green: 0.1146159694, blue: 0.1174070016, alpha: 1)
        if user.deviceID == UIDevice.current.identifierForVendor!.uuidString {
            self.rankLabel.backgroundColor = ballType.uiColor
        }
    }
}
