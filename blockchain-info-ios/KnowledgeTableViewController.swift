//
//  test.swift
//  blockchain-info-ios
//
//  Created by staff on 2018/12/27.
//  Copyright © 2018 takumi-kimura. All rights reserved.
//

import Foundation
import UIKit
import XLPagerTabStrip
import PromiseKit


class KnowledgeTableViewController: UITableViewController, IndicatorInfoProvider {
    
    
        var urlCategories = URL(string: "https://blockchaininfo.news/wp-json/wp/v2/posts?categories=193")!
    
    //https://blockchaininfo.news/wp-json/wp/v2/posts?categories=193&page=2
        
        
        //ここがボタンのタイトルに利用されます
        var itemInfo: IndicatorInfo = "ニュース"
    
        //列数を動的に変えるために
        var numberofRows = 10
        //実際の記事の数
        var numberOfArticles = 10
    
        /*
         記事ページを読み込むのに使う関数
         */
        //記事リストのタイトル
        var arrayString: [String] = []
        //記事リストの画像を取得するためのURL
        var arrayHRefURL: [URL] = []
        //記事リストの画像URL
        var arrayImageLink: [URL] = []
        //記事リストの画像
        var arrayImage: [UIImage] = []
        
        
        /*
         記事をタップした際、遷移先に値を受け渡すための関数
         */
        //記事のタイトル
        var articleTitle: String = ""
        //記事のURL
        var articleURL: URL!
        //記事の投稿日にち
        var articleDate: String = ""
        //記事の内容
        var articleContent: String = ""
        //記事のカテゴリー取得に必要なURL
        var articleCategoryURL: URL!
        //記事のカテゴリー名
        var articleCategory: String = ""
        //記事のタグ名取得に必要なURL
        var articleTagsURL : [URL] = []
        //記事のタグ名
        var articleTagsName: [String] = []
        //記事のタグ
        var tags: NSArray!
        //タップした記事のRow
        var tappedIndexPathNum: Int!
        
        override func viewDidLoad() {
            super.viewDidLoad()
            tableView.tableFooterView = UIView(frame: .zero)
            
            // リフレッシュコントローラー
            refreshControl = UIRefreshControl()
            // リフレッシュしたときに実行する関数を追加
            refreshControl?.addTarget(self, action: #selector(RankingTableViewController.refresh(_:)), for: .valueChanged)
            
            
        }
        
        override func numberOfSections(in tableView: UITableView) -> Int {
            // セクションを返す。基本的に１でいい。２になると、同じ内容を２回返すことになる。
            return 1
        }
        
        override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return self.numberOfArticles
        }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //一番下までスクロールしたかどうか
        if(self.tableView.contentOffset.y >= (self.tableView.contentSize.height - self.tableView.bounds.size.height))
        {
            //まだ表示するコンテンツが存在するか判定し存在するなら○件分を取得して表示更新する
            print("hi")
            self.numberofRows += 10
            if self.numberofRows >= 109{
            }else{
                let newNumberofRows = String(self.numberofRows)
                self.urlCategories = URL(string: "https://blockchaininfo.news/wp-json/wp/v2/posts?categories=193" + "&per_page=" + newNumberofRows)!
                print(self.urlCategories)
                print(self.numberOfArticles)
                
                DispatchQueue.main.async {
                    // テーブルビューを更新
                    self.tableView.reloadData()
                }
            }
        }

    }
        
        override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            // セルの内容を決める
            
            //StoryBoardのCellと紐付け
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            
            //セル内の画像
            let postThumbnail = cell.viewWithTag(1) as! UIImageView
            //セル内の記事タイトル
            let postTitle = cell.viewWithTag(2) as! UILabel
            
            //urlCategoriesは今週の人気記事のデータを人気順で返すURL。
            let task = URLSession.shared.dataTask(with: urlCategories) { (data, response, error) in
                do {
                    //データをJSONにする
                    let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! NSArray
                    
                        self.numberOfArticles = json.count
                    //人気記事数が３つまで表示する予定なので 0..<3
                    for i in 0..<self.numberOfArticles {
                        //記事をとる
                        let items = json[i] as? NSDictionary
                        //記事のタイトルを取る
                        let renderedTitle = items!["title"]as? NSDictionary
                        let title = renderedTitle!["rendered"] as? String
                        //記事タイトルをarrayStringに入れる
                        self.arrayString.append(title!)
                        
                        //画像を取りに行きたいので、リンク集にいく
                        let links = items!["_links"] as? NSDictionary
                        //featuredMediaの中のURL先に画像データのURLがあるので取得
                        let featuredMedia = links!["wp:featuredmedia"] as? NSArray
                        
                        // お問い合わせページがランキングにランクインしていた
                        // お問い合わせページにサムネイル画像がないので、Nilが返されてエラーになっていた。
                        if featuredMedia != nil{
                            //画像データがあるURLをDictionary型→String型→URL型で取得する。
                            let featuredMediaDetail = featuredMedia![0] as? NSDictionary
                            let featuredMediaHrefString = featuredMediaDetail!["href"] as? String
                            let featuredMediaHref = URL(string:featuredMediaHrefString!)
                            //arrayHRefURLのArrayに全部データ詰めとく
                            self.arrayHRefURL.append(featuredMediaHref!)
                        }
                        
                        /*
                         let task = URLSession.shared.dataTask(with: self.arrayHRefURL[0]) { (data, response, error) in
                         do {
                         //データをJSONにする
                         let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as? NSDictionary
                         
                         DispatchQueue.main.async {
                         let imageLinkString = json!["source_url"] as? String
                         let imageLinkURL = URL(string: imageLinkString!)
                         self.arrayImageLink.append(imageLinkURL!)
                         print(self.arrayImageLink)
                         }
                         }
                         catch{
                         print(error)
                         }
                         }
                         task.resume()
                         
                         */
                        
                        /*
                         let first = items![i] as? NSDictionary
                         let snippet = first!["snippet"] as? NSDictionary
                         let videoTitle = snippet!["title"] as? String
                         titles[i].text = videoTitle!
                         
                         let thumbnails = snippet!["thumbnails"] as? NSDictionary
                         let bigimage = thumbnails!["high"] as? NSDictionary
                         let imageURLString = bigimage!["url"] as? String
                         let imageURL = URL(string: imageURLString!)
                         let data = try? Data(contentsOf: imageURL!)
                         images[i].image = UIImage(data: data!)
                         */
                    } //end of loop
                    
                    DispatchQueue.main.async {
                        //タイトルをセル内のラベルに表示させる
                        postTitle.numberOfLines = 0
                        postTitle.lineBreakMode = NSLineBreakMode.byWordWrapping
                        postTitle.text = self.arrayString[indexPath.row]
                        postTitle.sizeToFit()
                        // postThumbnail.image = self.arrayImage[indexPath.row]
                    }
                }
                catch{
                    print(error)
                }
            }
            task.resume()
            return cell
        }
        
        // Cell が選択された場合
        override func tableView(_ table: UITableView,didSelectRowAt indexPath: IndexPath) {
            //タップした記事番号を取得
            self.tappedIndexPathNum = indexPath.row
            promiseChain()
        }
        
        
        // Segueする際に呼び出される
        override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
            if (segue.identifier == "toDetail") {
                // navigationcontrollerが間に挟まるので型変換的なことをする
                let nav = segue.destination as! UINavigationController
                let detailViewController = nav.topViewController as! DetailViewController
                //値の受け渡し
                detailViewController.articleTitle = self.articleTitle
                detailViewController.articleURL = self.articleURL
                detailViewController.articleContent = self.articleContent
                detailViewController.articleDate = self.articleDate
                detailViewController.articleCategory = self.articleCategory
                detailViewController.articleTags = self.articleTagsName

            }
        }
        
        
        func promiseChain() {
            firstly {
                self.fetchData()
                }.then { data in
                    //self.forTesting(data)
                    self.fromfetchedURLMoreData(data)
                }.catch { (error) in
                    print("got an error: \(error)")
            }
        }
        
        
        // 記事の名前、内容、日にち、カテゴリー、タグなどを取得する（ゆくゆく遷移先に送るために）。
        func fetchData() -> Promise<URL> {
            
            //ここで初期化しないと、前の記事のデータでPromiseがすぐ達成されてしまう
            self.articleCategoryURL = nil
            print(self.urlCategories)
            let task = URLSession.shared.dataTask(with: self.urlCategories) { (data, response, error) in
                do {
                    //データをJSONにする
                    let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! NSArray
                    
                    
                    //タップした記事の情報
                    let tappedArticle = json[self.tappedIndexPathNum] as? NSDictionary
                    
                    //記事のタイトルを取得
                    let renderedTitle = tappedArticle!["title"]as? NSDictionary
                    let title = renderedTitle!["rendered"] as? String
                    self.articleTitle = title!
                    
                    //記事URLをとる
                    let articleURLString = tappedArticle!["link"] as? String
                    self.articleURL = URL(string: articleURLString!)
                    
                    //記事の内容を取得
                    let renderedContent = tappedArticle!["content"] as? NSDictionary
                    let content = renderedContent!["rendered"] as? String
                    self.articleContent = content!
                    
                    //記事の投稿日にちを取得
                    let date = tappedArticle!["date"] as? String
                    let cleanDate = String(date!.prefix(10))
                    self.articleDate = cleanDate
                    
                    //記事のカテゴリーID（URL)を取得。
                    //カテゴリー名を取得するには、再度HTTPリクエストする必要あり。
                    //Any型をStringにするには、まずas Int?にして、その後Stringにすればできた。
                    //そのうち省略したい
                    
                    let categories = tappedArticle!["categories"] as! NSArray
                    let categoriesInt = categories[0] as? Int
                    let categoriesString = String(categoriesInt!)
                    let categoriesStringURL = "https://blockchaininfo.news/wp-json/wp/v2/categories/" + categoriesString
                    let categoriesURL = URL(string: categoriesStringURL)
                    self.articleCategoryURL = categoriesURL!
                    //タグIDを取得して、URLを生成する。
                    self.tags = tappedArticle!["tags"] as? NSArray
                    //ここで初期化しないと、永遠にarticleTagsURLにタップするたびに溜まっていく
                    self.articleTagsURL = []
                    for i in 0..<self.tags.count {
                        let tagsInt = self.tags[i] as? Int
                        let tagsString = String(tagsInt!)
                        let tagsStringURL = "https://blockchaininfo.news/wp-json/wp/v2/tags/" + tagsString
                        let tagsURL = URL(string: tagsStringURL)
                        self.articleTagsURL.append(tagsURL!)
                    }
                    
                }
                catch{
                    print(error)
                }
            }
            task.resume()
            
            /* Waitはよろしくない
             while self.articleTagsURL == [] {
             Thread.sleep(forTimeInterval: 0.5)
             break
             }*/
            
            
            return Promise { seal in
                //Whileの中の文を実行すると、ずっとやっている。非同期が終わってもずっとここでやっている感じ
                //Breakすると、一回のみ適応されるから意味がない
                // DispatchQueue.main.async {
                repeat{
                    Thread.sleep(forTimeInterval: 0.01)
                } while self.articleCategoryURL == nil
                if self.articleCategoryURL != nil {
                    seal.fulfill(self.articleCategoryURL)
                }
                // }
            }
            
        }
        
        func fromfetchedURLMoreData(_ data: URL) -> Promise<String> {
            print("fetching 2nd data: \(data)")
            
            //カテゴリー名を引っ張ってくる
            let task = URLSession.shared.dataTask(with: self.articleCategoryURL) { (data, response, error) in
                do {
                    //データをJSONにする
                    let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary
                    
                    DispatchQueue.main.async {
                        let categoryName = json["name"] as? String
                        self.articleCategory = categoryName!
                    }
                }
                catch{
                    print(error)
                }
            }
            task.resume()
            
            
            
            self.articleTagsName = []
            
            for i in 0..<self.tags.count{
                //タグ名を引っ張ってくる
                let task2 = URLSession.shared.dataTask(with: self.articleTagsURL[i]) { (data, response, error) in
                    do {
                        //データをJSONにする
                        let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary
                        
                        DispatchQueue.main.async {
                            let tagsName = json["name"] as? String
                            self.articleTagsName.append(tagsName!)
                            if self.articleTagsName.count == self.tags.count {
                                // 記事ページに遷移　ここに入れると遅くなるかも知れない？
                                self.performSegue(withIdentifier: "toDetail",sender: nil)
                            }
                            
                        }
                    }
                    catch{
                        print(error)
                    }
                }
                task2.resume()
            }
            
            
            return Promise { seal in
                seal.resolve(.fulfilled("did fetch 2nd data"))
            }
        }
        
        
        
        @objc func refresh(_ sender: UIRefreshControl) {
            // レスポンスが割と速かったので、2秒後にAPIからデータを取得する
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                // APIに接続してテーブルビューを更新
                self.updatePostList(sender)
            }
        }
        
        // tableviewのデータを更新
        func updatePostList(_ sender: UIRefreshControl?) -> Void {
            // メインスレッドで実行
            DispatchQueue.main.async {
                // テーブルビューを更新
                self.tableView.reloadData()
                // リフレッシュだとsenderがあるので、リフレッシュ完了
                if sender != nil {
                    sender?.endRefreshing()
                    print("refresh")
                }
            }
        }
        
        //PagerTabStripControllerのために必須
        func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
            return itemInfo
        }
    
        
}

