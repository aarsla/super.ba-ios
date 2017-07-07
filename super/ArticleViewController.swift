//
//  SecondViewController.swift
//  super
//
//  Created by Aid Arslanagic on 15/06/2017.
//  Copyright © 2017 Simpastudio. All rights reserved.
//

import UIKit
import Alamofire
import Kingfisher
import SafariServices

class ArticleViewController: UIViewController, SFSafariViewControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var readButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    
    var article: Article?

    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = NSLocale.current
        formatter.timeZone = NSTimeZone.default
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = article?.source?.title
        
        if let date = article?.date {
            self.dateLabel?.text = String(format: NSLocalizedString("published.by_source.at_date", comment: "Published by source.io on Wednesday, Jun 28 at 13:00"), self.title!, ArticleViewController.dateFormatter.string(from: date))
        }
        
        let placeholderImage = UIImage(named: "placeholder")

        self.imageView.kf.indicatorType = .activity

        if let urlString = article?.imageUrl, let url = URL(string: urlString) {
            self.imageView.kf.setImage(with: url, placeholder: placeholderImage)
        } else if let logoString = article?.source?.logo, let url = URL(string: logoString) {
            self.imageView.kf.setImage(with: url, placeholder: placeholderImage)
        }
        
        self.titleLabel.text = self.article?.title
        self.textLabel.text = self.article?.description
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Actions
    
    @IBAction func readMore(_ sender: Any) {
        let safariVC = SFSafariViewController(url: NSURL(string: (self.article?.link)!)! as URL, entersReaderIfAvailable: true)
        safariVC.delegate = self
        
        self.navigationController?.present(safariVC, animated: true, completion: nil)
    }

    @IBAction func goBack(_ sender: Any) {
        self.navigationController!.popViewController(animated: true)
    }
    
    
    // MARK: - Safari VC
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController)
    {
    }
}

