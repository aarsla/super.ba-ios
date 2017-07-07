//
//  ArticleCell.swift
//  super
//
//  Created by Aid Arslanagic on 15/06/2017.
//  Copyright © 2017 Simpastudio. All rights reserved.
//

import UIKit

protocol DoubleCellProtocol: class {
    func cellTapped(tag: Int)
}

class DoubleCell: UITableViewCell {
    
    @IBOutlet weak var content1View:UIView!;
    @IBOutlet weak var title1Label: UILabel!
    @IBOutlet weak var articleImage1View: UIImageView!
    @IBOutlet weak var sourceLogoImage1View: UIImageView!
    @IBOutlet weak var date1Label: UILabel!
    @IBOutlet weak var source1Label: UILabel!

    @IBOutlet weak var content2View:UIView!;
    @IBOutlet weak var title2Label: UILabel!
    @IBOutlet weak var articleImage2View: UIImageView!
    @IBOutlet weak var sourceLogoImage2View: UIImageView!
    @IBOutlet weak var date2Label: UILabel!
    @IBOutlet weak var source2Label: UILabel!

    weak var delegate: DoubleCellProtocol?

    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tapFirstCellGesture = UITapGestureRecognizer(target: self, action: #selector(cellTapped(_:)))
        tapFirstCellGesture.numberOfTapsRequired = 1
        self.content1View.addGestureRecognizer(tapFirstCellGesture)

        let tapSecondCellGesture = UITapGestureRecognizer(target: self, action: #selector(cellTapped(_:)))
        tapSecondCellGesture.numberOfTapsRequired = 1
        self.content2View.addGestureRecognizer(tapSecondCellGesture)

        let placeholderImage = UIImage(named: "placeholder")
        
        articleImage1View?.layer.cornerRadius = 4.0
        articleImage1View?.clipsToBounds = true
        articleImage1View.image = placeholderImage

        articleImage2View?.layer.cornerRadius = 4.0
        articleImage2View?.clipsToBounds = true
        articleImage2View.image = placeholderImage
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        title1Label?.sizeToFit()
        title2Label?.sizeToFit()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()        
    }
    
    @IBAction @objc func cellTapped(_ sender: UITapGestureRecognizer) {
        if let view = sender.view {
            delegate?.cellTapped(tag: view.tag)
        }
    }
}
