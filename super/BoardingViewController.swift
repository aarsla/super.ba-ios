//
//  BoardingViewController.swift
//  super
//
//  Created by Aid Arslanagic on 13/07/2017.
//  Copyright © 2017 Simpastudio. All rights reserved.
//

import UIKit

private let reuseIdentifier = "BoardingCell"

class BoardingViewController: UICollectionViewController {

    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    fileprivate let provider :Provider = Provider.sharedInstance
    fileprivate var selectedSources :[Source] = []
        
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func checkDoneButton() {
        if (selectedSources.isEmpty) {
            doneButton.isEnabled = false
        } else {
            doneButton.isEnabled = true
        }
    }
    
    @IBAction func dismissController(_ sender: Any) {
        provider.resetArticles()
        NotificationCenter.default.post(name: Notification.Name(rawValue: sourcesUpdateNotificationKey), object: self)

        self.dismiss(animated: true, completion: nil)
    }
    
}

// MARK: - UICollectionViewDataSource

extension BoardingViewController {
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return provider.sources.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! BoardingCell
        
        let source = provider.sources[indexPath.row]
        
        if let logoString = source.logo, let url = URL(string: logoString) {
            cell.logoImageView?.kf.setImage(with: url)
        }
        
        if let urlString = source.url {
            cell.urlTitleLabel?.text = urlString
        }
        
        cell.checkmarkLabel.font = UIFont(name: "FontAwesome", size: 20.0)
        cell.checkmarkLabel.text = String.fontAwesomeIcon(name: .checkCircle)
        
        cell.sourceTitleLabel?.text = source.title
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension BoardingViewController {
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! BoardingCell
        let source = provider.sources[indexPath.row]
        provider.toggleNewsFilter(source: source.title!)

        if let index = selectedSources.index(where: { $0.title == source.title }) {
            selectedSources.remove(at: index)
        } else {
            selectedSources.append(source)
        }
        
        cell.checkmarkLabel.isHidden = !cell.checkmarkLabel.isHidden
        checkDoneButton()
    }
}
