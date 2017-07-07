//
//  ArticleCell.swift
//  super
//
//  Created by Aid Arslanagic on 15/06/2017.
//  Copyright © 2017 Simpastudio. All rights reserved.
//

import UIKit

class ArticleCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var articleImageView: UIImageView!
    @IBOutlet weak var sourceLogoImageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var sourceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let placeholderImage = UIImage(named: "placeholder")
        
        articleImageView?.layer.cornerRadius = 4.0
        articleImageView?.clipsToBounds = true
        articleImageView.image = placeholderImage
        
        sourceLogoImageView?.layer.cornerRadius = 2.0
        sourceLogoImageView?.clipsToBounds = true
        sourceLogoImageView.image = placeholderImage
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel?.sizeToFit()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()        
    }
}
