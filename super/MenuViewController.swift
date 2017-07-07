//
//  MainViewController.swift
//  super
//
//  Created by Aid Arslanagic on 16/06/2017.
//  Copyright © 2017 Simpastudio. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SlideMenuControllerSwift

class MenuViewController: UITableViewController, SlideMenuControllerDelegate {

    fileprivate let provider :Provider = Provider.sharedInstance

    override func viewDidLoad() {
        super.viewDidLoad()
        slideMenuController()?.delegate = self

        NotificationCenter.default.addObserver(self, selector: #selector(showSources), name: NSNotification.Name(rawValue: sourcesUpdateNotificationKey), object: nil)
    }
        
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func showSources() {
        self.tableView.reloadData()
    }
    
    // MARK: - SlideMenuControllerDelegate
    
    func leftWillClose() {
        //NotificationCenter.default.post(name: Notification.Name(rawValue: filtersNotificationKey), object: self)
    }
}

// MARK: - UITableView Delegate

extension MenuViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedSource = provider.sources[indexPath.row];
        provider.addNewsFilter(source: selectedSource.title!)
        tableView.reloadData()
    }
}

// MARK: - UITableView Data source

extension MenuViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return provider.sources.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:MenuCell = tableView.dequeueReusableCell(withIdentifier: "MenuCell") as! MenuCell
        
        let source = provider.sources[indexPath.row]
        let filteredSources = provider.filteredSources
        
        if (filteredSources.contains(source.title!)) {
            cell.sourceTitleLabel?.textColor = #colorLiteral(red: 0.6029270887, green: 0.6671635509, blue: 0.8504692912, alpha: 1)
            cell.logoImageView.alpha = 0.25
        } else {
            cell.sourceTitleLabel?.textColor = #colorLiteral(red: 0.1919409633, green: 0.4961107969, blue: 0.745100379, alpha: 1)
            cell.logoImageView.alpha = 1.0
        }
        
        if let logoString = source.logo, let url = URL(string: logoString) {
            cell.logoImageView?.kf.setImage(with: url)
        }
        
        cell.sourceTitleLabel?.text = source.title
        return cell
    }
}
