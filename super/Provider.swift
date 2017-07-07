//
//  Provider.swift
//  super
//
//  Created by Aid Arslanagic on 19/06/2017.
//  Copyright © 2017 Simpastudio. All rights reserved.
//

import UIKit
import Foundation
import Alamofire
import AlamofireNetworkActivityIndicator
import AlamofireObjectMapper
import Kingfisher
import ObjectMapper
import p2_OAuth2
import SwiftyJSON
import SlideMenuControllerSwift
import Starscream

let sourcesUpdateNotificationKey = "com.simpastudio.super.sourcesUpdate"
let newsUpdateNotificationKey = "com.simpastudio.super.newsUpdate"
let filtersUpdateNotificationKey = "com.simpastudio.super.filtersUpdate"
let websocketUpdateNotificationKey = "com.simpastudio.super.checkUpdate"
let alertNotificationKey = "com.simpastudio.super.sourcesAlert"
let websocketStatusNotificationKey = "com.simpastudio.super.socketChangeAlert"

let netProtocol = "https"
let netHost = "super.ba"
let netPort = 443

enum WebsocketStatus {
    case connected
    case disconnected
}

class Provider {
    
    static let sharedInstance = Provider()
    fileprivate let reachabilityManager = Alamofire.NetworkReachabilityManager(host: "super.ba")
    var alamofireManager: SessionManager?

    // Yes, these actually work.
    let oauth2 = OAuth2ClientCredentials(settings: [
        "client_id": "5952144f7e664a87a18c158b_2fpcotn1f8n4so8oo8s4gwg8ogsgk8g48oksc044s0o4k0kow0",
        "client_secret": "34vrb64rxx8g8kc8s4ck8s4wocc4kcgkws4cookcocog0k8gcw",
        "token_uri": "https://super.ba/oauth/v2/token",
        "scope": "user",
        "secret_in_body": false,
        "keychain": true,
        ] as OAuth2JSON)
    
    var socket = WebSocket(url: URL(string: "wss://super.ba:1880/ws/news")!)
    var socketStatus: WebsocketStatus = .disconnected
    
    var articles: [Article] = [];
    var sources: [Source] = [];
    var filteredSources: [String] = []
    var searchString: String? = nil

    fileprivate var offset: Int = 0
    fileprivate var filter: String = ""
    fileprivate var reconnectTimer: Timer = Timer()

    private init() {
        NetworkActivityIndicatorManager.shared.isEnabled = true
        
        ImageCache.default.maxDiskCacheSize = 200 * 1024 * 1024 // 200 MB
        ImageCache.default.maxCachePeriodInSecond = 60 * 60 * 24 * 3 // 3days

        let sessionManager = SessionManager()
        let retrier = OAuth2RetryHandler(oauth2: oauth2)
        sessionManager.adapter = retrier
        sessionManager.retrier = retrier
        
        alamofireManager = sessionManager
        
        //socket.disableSSLCertValidation = true
        socket.delegate = self
        socket.connect()
        reconnectTimer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(reconnectSocket), userInfo: nil, repeats: true)

        loadNewsFilters()
        getSources()
    }
    
    @objc func reconnectSocket() {
        if !socket.isConnected {
            socket.connect()
        }
    }

    // MARK: - Filters
    
    func loadNewsFilters() {
        let defaults = UserDefaults.standard
        var filteredSources = defaults.stringArray(forKey: "filteredSources")
        
        if filteredSources == nil {
            filteredSources = []
            defaults.set(filteredSources, forKey: "filteredSources")
        }
        
        self.filteredSources = filteredSources!
        setNewsFilters(sources: filteredSources!)
    }
    
    func addNewsFilter(source: String) {
        let defaults = UserDefaults.standard
        var filteredSources = defaults.stringArray(forKey: "filteredSources")
        
        if (filteredSources?.contains(source))! {
            if let index = filteredSources?.index(of: source) {
                filteredSources?.remove(at: index)
            }
        } else {
            filteredSources?.append(source)
        }
        
        let uniqueSources = Array(Set(filteredSources!))
        defaults.set(uniqueSources, forKey: "filteredSources")
        
        self.filteredSources = uniqueSources
        setNewsFilters(sources: uniqueSources)
        resetArticles()
    }
    
    func setNewsFilters(sources: [String]) {
        let paramsJSON = JSON(sources)
        let paramsString = paramsJSON.rawString(String.Encoding.utf8)
        let paramsData = paramsString?.data(using: String.Encoding.utf8)
        self.filter = (paramsData?.base64EncodedString())!
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: newsUpdateNotificationKey), object: self)
    }
    
    // MARK: - Sources
    
    func getSources() {
        
        alamofireManager?.request("https://super.ba/api").validate().responseJSON { response in
            if (response.result.value as? [String: Any]) != nil {
                let URL = "https://super.ba/api/v1/sources"
                
                self.alamofireManager?.request(URL, method: .get).responseObject { (response: DataResponse<SourcesResponse>) in
                    let sourcesResponse = response.result.value
                    
                    if let sources = sourcesResponse?.sources {
                        self.sources = sources
                        
                        NotificationCenter.default.post(name: Notification.Name(rawValue: sourcesUpdateNotificationKey), object: self)
                        self.resetArticles()
                    }
                }
            } else {
                let alertDataDict:[String: String] = ["message": "\(response)"]
                NotificationCenter.default.post(name: Notification.Name(rawValue: alertNotificationKey), object: self, userInfo: alertDataDict)
                }
            }
    }
    
    func forgetTokens() {
        oauth2.forgetTokens()
    }
    
    // MARK: - Reachability

    func listenForReachability() {
        self.reachabilityManager?.listener = { status in
            //print("Network Status Changed: \(status)")
            switch status {
            case .notReachable:
                // Show error state
                break
            case .reachable(_), .unknown:
                // Hide error state
                break
            }
        }
        
        self.reachabilityManager?.startListening()
    }
    
    // MARK: - Articles

    func resetSearch() {
        self.searchString = nil;
        resetArticles()
    }
    
    func resetArticles() {
        self.offset = 0
        loadArticles(reset: true)
    }

    func searchArticles(title: String) {
        self.searchString = title
        self.offset = 0
        loadArticles(reset: true)
    }
    
    func loadArticles(reset: Bool = false) {

        let URL = "\(netProtocol)://\(netHost):\(netPort)/api/v1/articles"
        
        var parameters: Parameters = [
            "category": "BiH",
            "offset": self.offset,
            "limit": 10,
            "filters": self.filter,
        ]
        
        if let searchString = self.searchString {
            //let escapedTitle = searchString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
            parameters["search"] = searchString
        }
        
        //print(parameters)
        
        alamofireManager?.request(URL, method: .get, parameters: parameters).responseObject { (response: DataResponse<ArticlesResponse>) in
            let articleResponse = response.result.value
            
            if let articles = articleResponse?.articles {
                
                // Sort by date
                let sortedArticles = articles.sorted(by: { $0.date! > $1.date! })
                //self.articles = articles.sorted(by: { (lhs, rhs) -> Bool in
                //    lhs.date! > rhs.date!
                //})

                
                if reset {
                    self.offset = 0
                    self.articles = []
                }

                self.articles += sortedArticles
                
                // Remove duplicates
                self.articles = self.articles.removeDuplicates()

                NotificationCenter.default.post(name: Notification.Name(rawValue: newsUpdateNotificationKey), object: self)
                self.offset = self.offset+10;
            }
        }
    }
}

// MARK: - Websocket Delegate Methods.

extension Provider : WebSocketDelegate {
    
    func websocketDidConnect(socket: WebSocket) {
        socketStatus = .connected
        
        let statusDataDict:[String: WebsocketStatus] = ["status": socketStatus]
        NotificationCenter.default.post(name: Notification.Name(rawValue: websocketStatusNotificationKey), object: self, userInfo: statusDataDict)
    }
    
    func websocketDidDisconnect(socket: WebSocket, error: NSError?) {
        socketStatus = .disconnected

        let statusDataDict:[String: WebsocketStatus] = ["status": socketStatus]
        NotificationCenter.default.post(name: Notification.Name(rawValue: websocketStatusNotificationKey), object: self, userInfo: statusDataDict)
    }
    
    func websocketDidReceiveMessage(socket: WebSocket, text: String) {
        if let data = text.data(using: .utf8, allowLossyConversion: false) {
            let json = JSON(data)
            var newArticles :[Article] = []
            
            for (_,subJson):(String, JSON) in json {
                if let jsonString = subJson.rawString(), let article = Article(JSONString: jsonString) {
                    if !self.articles.contains(article) {
                        newArticles.append(article)
                    }
                }
            }
            
            if !newArticles.isEmpty {
                let articlesDict:[String: [Article]] = ["articles": newArticles]
                NotificationCenter.default.post(name: Notification.Name(rawValue: websocketUpdateNotificationKey), object: self, userInfo: articlesDict)
            }
        }
    }
    
    func websocketDidReceiveData(socket: WebSocket, data: Data) {
        //print("Received data: \(data.count)")
    }
}

extension Array where Element:Equatable {
    func removeDuplicates() -> [Element] {
        var result = [Element]()
        
        for value in self {
            if result.contains(value) == false {
                result.append(value)
            }
        }
        
        return result
    }
}
