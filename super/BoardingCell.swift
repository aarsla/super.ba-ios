//
//  BoardingCell.swift
//  super
//
//  Created by Aid Arslanagic on 13/07/2017.
//  Copyright © 2017 Simpastudio. All rights reserved.
//

import UIKit

class BoardingCell: UICollectionViewCell {
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var sourceTitleLabel: UILabel!
    @IBOutlet weak var urlTitleLabel: UILabel!
    @IBOutlet weak var checkmarkLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        checkmarkLabel.isHidden = true;
    }    
}
