//
//  FirstViewController.swift
//  super
//
//  Created by Aid Arslanagic on 15/06/2017.
//  Copyright © 2017 Simpastudio. All rights reserved.
//

import Alamofire
import AlamofireObjectMapper
import FontAwesome_swift
import SwiftyJSON
import UIKit

class ArticlesViewController: UITableViewController, UISearchBarDelegate {

    @IBOutlet weak var leftBarButton: UIBarButtonItem!
    @IBOutlet weak var rightBarButton: UIBarButtonItem!
    @IBOutlet weak var searchBar: UISearchBar!
    
    fileprivate let provider :Provider = Provider.sharedInstance
    fileprivate let placeholderImage = UIImage(named: "placeholder")

    //let firstCellHeight: CGFloat = 360.0
    //let secondCellHeight: CGFloat = 280.0
    //let regularCellHeight: CGFloat = 96.0
    
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = NSLocale.current
        formatter.timeZone = NSTimeZone.default
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 96.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        resetLeftBarButton()
        resetRightBarButton()

        refreshControl?.addTarget(self, action: #selector(ArticlesViewController.pullToRefresh), for: .valueChanged)

        NotificationCenter.default.addObserver(self, selector: #selector(showNews), name: NSNotification.Name(rawValue: newsUpdateNotificationKey), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showNewsUpdate), name: NSNotification.Name(rawValue: websocketUpdateNotificationKey), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showAlert), name: NSNotification.Name(rawValue: alertNotificationKey), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showWebsocketStatus), name: NSNotification.Name(rawValue: websocketStatusNotificationKey), object: nil)
        
        provider.loadArticles()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateSearchBarText()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        searchBar.resignFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: UI methods
    
    func updateSearchBarText() {
        if let searchString = provider.searchString {
            searchBar.text = searchString
        }
    }

    func showAlert(notification: NSNotification) {
        if (notification.userInfo?["message"] as? String) != nil {
            let alert = UIAlertController(title: NSLocalizedString("Network Error", comment: "Network Error"), message: NSLocalizedString("Please try again", comment: "Please try again"), preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }

    func showNews() {
        self.tableView.reloadData()
        resetRightBarButton()
    }
    
    func showNewsUpdate(notification: NSNotification) {
        let rightBarAttributes = [NSFontAttributeName: UIFont.fontAwesome(ofSize: 20),
                                  NSForegroundColorAttributeName: #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)] as [String: Any]
        rightBarButton.setTitleTextAttributes(rightBarAttributes, for: .normal)
        rightBarButton.title = String.fontAwesomeIcon(name: .arrowCircleUp)
    }
    
    func showWebsocketStatus(notification: NSNotification) {
        if (notification.userInfo?["status"] as? WebsocketStatus) != nil {
            let websocketStatus :WebsocketStatus = notification.userInfo?["status"] as! WebsocketStatus
            
            switch websocketStatus {
            case .connected:
                let textAttributes = rightBarButton.titleTextAttributes(for: .normal)
                if let color = textAttributes?["NSColor"] {
                    let rightBarAttributes = [NSFontAttributeName: UIFont.fontAwesome(ofSize: 20),
                                              NSForegroundColorAttributeName: (color as AnyObject).withAlphaComponent(1.0)] as [String: Any]
                    self.rightBarButton.setTitleTextAttributes(rightBarAttributes, for: .normal)
                }
                break
                
            default:
                let textAttributes = rightBarButton.titleTextAttributes(for: .normal)
                if let color = textAttributes?["NSColor"] {
                    let rightBarAttributes = [NSFontAttributeName: UIFont.fontAwesome(ofSize: 20),
                                              NSForegroundColorAttributeName: (color as AnyObject).withAlphaComponent(0.5)] as [String: Any]
                    self.rightBarButton.setTitleTextAttributes(rightBarAttributes, for: .normal)
                }
                
                break
            }
        }
    }
    
    func pullToRefresh() {
        refreshControl?.endRefreshing()
        provider.resetArticles()
    }

    func resetLeftBarButton() {
        let defaultColor = self.view.tintColor
        let leftBarAttributes = [NSFontAttributeName: UIFont.fontAwesome(ofSize: 20),
                                 NSForegroundColorAttributeName: defaultColor!] as [String: Any]
        leftBarButton.setTitleTextAttributes(leftBarAttributes, for: .normal)
        leftBarButton.title = String.fontAwesomeIcon(name: .filter)
    }
    
    func resetRightBarButton() {
        let defaultColor = self.view.tintColor
        let rightBarAttributes = [NSFontAttributeName: UIFont.fontAwesome(ofSize: 20),
                                  NSForegroundColorAttributeName: defaultColor!] as [String: Any]
        rightBarButton.setTitleTextAttributes(rightBarAttributes, for: .normal)
        rightBarButton.title = String.fontAwesomeIcon(name: .arrowUp)
    }

    func scrollToTop() {
        let indexPath = IndexPath(row: 0, section: 0)
        self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
    }

    // MARK: IBActions

    @IBAction func loadArticles() {
        refreshControl?.endRefreshing()
        provider.resetArticles()
        
        scrollToTop()
    }

    @IBAction func openMenu(_ sender: Any) {
        searchBar.resignFirstResponder()
        self.slideMenuController()?.openLeft()
    }
    
    // MARK: - UIStoryboardSegue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let segueID = segue.identifier else { return }

        let articleViewController = segue.destination as! ArticleViewController
        let indexPath = tableView.indexPathForSelectedRow!
        var selectedArticle:Article? = nil

        switch (segueID) {
        case "ArticleDetailFromBigCell":
            selectedArticle = provider.articles[indexPath.row]
            break
            
        case "ArticleDetail":
            selectedArticle = provider.articles[indexPath.row+1]
            break
            
        default:
            break
        }
        
        if (selectedArticle != nil) {
            articleViewController.article = selectedArticle
        }
    }
}

// MARK: - UITableViewDataSource

extension ArticlesViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return provider.articles.count-1
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        let lastElement = provider.articles.count - 2
        if indexPath.row == lastElement {
            provider.loadArticles()
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        var cell :UITableViewCell!
        
        switch (indexPath.row) {
        case 0:
            let article = provider.articles[indexPath.row]
            cell = tableView.dequeueReusableCell(withIdentifier: "BigCell") as! ArticleCell
            cell = configureArticleCell(cell:cell as! ArticleCell, article: article)
            break;

        case 1:
            let articles = [provider.articles[indexPath.row], provider.articles[indexPath.row+1]]
            cell = tableView.dequeueReusableCell(withIdentifier: "DoubleCell") as! DoubleCell
            cell = configureDoubleCell(cell:cell as! DoubleCell, articles: articles)
            break;

        default:
            let article = provider.articles[indexPath.row+1]
            cell = tableView.dequeueReusableCell(withIdentifier: "ArticleCell") as! ArticleCell
            cell = configureArticleCell(cell:cell as! ArticleCell, article: article)
            break;
        }
        
        return cell
    }
    
    func configureArticleCell(cell: ArticleCell, article: Article) -> ArticleCell {
        
        cell.articleImageView.kf.indicatorType = .activity
        
        if let urlString = article.imageUrl, let url = URL(string: urlString) {
            cell.articleImageView.kf.setImage(with: url, placeholder: placeholderImage)
        } else if let logoString = article.source?.logo, let url = URL(string: logoString) {
            cell.articleImageView.kf.setImage(with: url, placeholder: placeholderImage)
        }
        
        cell.titleLabel.text = article.title
        
        if let date = article.date {
            cell.dateLabel?.text = ArticlesViewController.dateFormatter.string(from: date)
        } else {
            cell.dateLabel?.text = nil
        }
        
        cell.sourceLabel.text = article.source?.title?.uppercased()
        
        if let logoString = article.source?.logo, let url = URL(string: logoString) {
            cell.sourceLogoImageView.kf.setImage(with: url, placeholder: placeholderImage)
        }
        
        cell.titleLabel.sizeToFit()
        return cell
    }

    func configureDoubleCell(cell: DoubleCell, articles: [Article]) -> DoubleCell {
        
        cell.delegate = self
        
        cell.articleImage1View.kf.indicatorType = .activity
        cell.articleImage2View.kf.indicatorType = .activity
        
        let firstArticle = articles.first
        let secondArticle = articles.last
        
        if let urlString = firstArticle?.imageUrl, let url = URL(string: urlString) {
            cell.articleImage1View.kf.setImage(with: url, placeholder: placeholderImage)
        } else if let logoString = firstArticle?.source?.logo, let url = URL(string: logoString) {
            cell.articleImage1View.kf.setImage(with: url, placeholder: placeholderImage)
        }
        
        if let urlString = secondArticle?.imageUrl, let url = URL(string: urlString) {
            cell.articleImage2View.kf.setImage(with: url, placeholder: placeholderImage)
        } else if let logoString = secondArticle?.source?.logo, let url = URL(string: logoString) {
            cell.articleImage2View.kf.setImage(with: url, placeholder: placeholderImage)
        }
        
        cell.title1Label.text = firstArticle?.title
        cell.title2Label.text = secondArticle?.title
        
        if let date = firstArticle?.date {
            cell.date1Label?.text = ArticlesViewController.dateFormatter.string(from: date)
        } else {
            cell.date1Label?.text = nil
        }

        if let date = secondArticle?.date {
            cell.date2Label?.text = ArticlesViewController.dateFormatter.string(from: date)
        } else {
            cell.date2Label?.text = nil
        }

        cell.source1Label.text = firstArticle?.source?.title?.uppercased()
        cell.source2Label.text = secondArticle?.source?.title?.uppercased()
        
        cell.title1Label.sizeToFit()
        cell.title2Label.sizeToFit()

        return cell
    }

}

// MARK: - UITableViewDelegate

extension ArticlesViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}

// MARK: - UISearchBarDelegate

extension ArticlesViewController {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.setShowsCancelButton(false, animated: true)
        
        updateSearchBarText()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.title = NSLocalizedString("ArticlesVcTitle", comment: "News");
        searchBar.resignFirstResponder()
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.text = nil

        provider.resetSearch()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchTitle = searchBar.text {
            self.title = searchTitle
            provider.searchArticles(title: searchTitle)
        }

        searchBar.resignFirstResponder()
        searchBar.setShowsCancelButton(false, animated: true)
    }
}

// MARK: - DoubleCell Protocol

extension ArticlesViewController: DoubleCellProtocol {
    
    func cellTapped(tag: Int) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let articleDetailController = storyboard.instantiateViewController(withIdentifier: "Article") as! ArticleViewController
        articleDetailController.article = provider.articles[tag]
        navigationController?.pushViewController(articleDetailController, animated: true)
    }
    
}
