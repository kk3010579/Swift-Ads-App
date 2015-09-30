/* =======================

- Classify -

made by FV iMAGINATION ©2015
for CodeCanyon

==========================*/


import UIKit

class MyAdCell: UITableViewCell {

    /* Views */
    @IBOutlet var adImage: UIImageView!
    @IBOutlet var adTitleLabel: UILabel!
    @IBOutlet var adDescrLabel: UILabel!
    //new items
    //@IBOutlet var favImage: UIImageView!
    @IBOutlet var markLabel: UILabel!
    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var checkFavoriteBt: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}
