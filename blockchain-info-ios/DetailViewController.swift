//
//  ViewController.swift
//  blockchain-info-ios
//
//  Created by staff on 2018/12/03.
//  Copyright © 2018 takumi-kimura. All rights reserved.
// API key
// https://blockchaininfo.news/wp-json
// https://x1.inkenkun.com/archives/909

import UIKit
import Social

class DetailViewController: UIViewController {
   
    @IBOutlet var titleLabel : UILabel!
    @IBOutlet var contentText : UITextView!
    @IBOutlet var dateLabel : UILabel!
    @IBOutlet var categoryLabel : UILabel!
    @IBOutlet var tagLabel: UILabel!
    @IBOutlet var timeToReadLabel: UILabel!

    
    var articleTitle : String = ""
    var articleURL: URL!
    var articleContent : String = ""
    var articleDate : String = ""
    var articleCategory : String = ""
    var articleTags : [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(articleTitle)
        print(articleURL)
        print(articleDate)
        print(articleCategory)
        print(articleTags)
        
        //Textfieldの画像がはみ出る問題を解決
        //https://teratail.com/questions/22476
        //取り出したいパターンを定義
        let patternWidth = "width=\"(.+?)\""
        let patternHeight = "height=\"(.+?)\""
        //正規表現の定義
        let regexWidth = try! NSRegularExpression(pattern: patternWidth, options: .caseInsensitive)
        let regexHeight = try! NSRegularExpression(pattern: patternHeight, options: .caseInsensitive)
        //記事内の中に定義されたパターンの正規表現とマッチしたものを探す
        let matchesWidth = regexWidth.matches(in: articleContent, options: [], range: NSMakeRange(0, articleContent.count))
        let matchesHeight = regexHeight.matches(in: articleContent, options: [], range: NSMakeRange(0, articleContent.count))
        //埋め込み画像のサイズを後で入れておくためのもの
        var resultsWidth: [String] = []
        var resultsHeight: [String] = []
        //マッチしたやつを一つずつ入れていく
        matchesWidth.forEach { (match) -> () in
            resultsWidth.append( (articleContent as NSString).substring(with: match.range(at: 1)) )
        }
        matchesHeight.forEach { (match) -> () in
            resultsHeight.append( (articleContent as NSString).substring(with: match.range(at: 1)) )
        }
        //スクリーンの幅を取得
        let screenWidth = Double(UIScreen.main.bounds.size.width)
        //「記事埋め込み画像の横幅」を定義する部分を「スクリーンの幅」に変更。参考記事
        //文字列を変更する　https://qiita.com/HIRO-NET/items/b9720ccb3c86e85e5872
        for i in 0..<resultsWidth.count {
            if let range = articleContent.range(of: "\"" + resultsWidth[i]) {
            articleContent.replaceSubrange(range, with: "\(screenWidth)")
            }
        }
        //記事埋め込み画像の縦幅」を定義する部分をアスペクト比率に合わせて変更
        for i in 0..<resultsHeight.count {
            let doubleWidth = Double(resultsWidth[i])
            let doubleHeight = Double(resultsHeight[i])
            let ratio = screenWidth/doubleWidth!
            let adjustedHeight = doubleHeight! * ratio
            if let range = articleContent.range(of: "\"" + resultsHeight[i]) {
                articleContent.replaceSubrange(range, with: "\(adjustedHeight)")
            }
        }
        
        
        /*  このやり方だと、HTMLで書かれたContentの中の日本語文字まで変換するので、文字化けが起きてた
         //HTMLユニコードの10進数文字コード。参考URL
         //http://begigrammer.hatenablog.com/entry/2018/03/15/035013
         let html = "<html>" + articleContent + "</html>"
         let encoded = html.data(using: String.Encoding.utf8)!
         let attributedOptions : [NSAttributedString.DocumentReadingOptionKey : Any] = [
         .documentType : NSAttributedString.DocumentType.html,
         ]
         let attributedTxt = try! NSAttributedString(data: encoded,
         
         options: attributedOptions,
         
         documentAttributes: nil)
         contentText.attributedText = attributedTxt
         */
        
        //こっちのやり方で解消。下の方に関数が書いてある。参考URL
        //https://qiita.com/kumetter/items/91b433cd4d30abe507c5
        //HTML記事を見れるようにする
        let content = parseText2HTML(sourceText: articleContent)
        contentText.attributedText = content
        
        //記事タイトルを設定
        titleLabel.text = articleTitle
        //日にちを設定
        dateLabel.text = articleDate
        //カテゴリーを設定
        categoryLabel.text = articleCategory
        //タグを設定 
        tagLabel.text = articleTags.joined(separator: ",")
        //目安読み時間を設定
        let articleWordString = content!.string
        let articleWordLength = articleWordString.count
        let timeToRead = 1 + (articleWordLength/600)
        timeToReadLabel.text = "この記事は約\(timeToRead)分で読めます"
        
    }
    
    //記事内容表示位置を一番上に持ってくるため
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        contentText.setContentOffset(CGPoint.zero, animated: false)
    }
    
    //前の画面に戻る
    @IBAction func back(sender: Any?) {
        self.dismiss(animated: true, completion: nil) 
    }
    
    @IBAction func share(sender: Any?) {
        // 共有する項目
        let shareText = self.articleTitle
        let shareWebsite = self.articleURL!
        //let shareImage = UIImage(named: "test.jpg")!
        //let shareItems = [shareText, shareWebsite, shareImage] as [Any]
        let shareItems = [shareText, shareWebsite] as [Any]

        let avc = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)

        
        present(avc, animated: true, completion: nil)
    
    }
    
    //お気に入り機能
    @IBAction func save(sender: Any?) {
        // 記事IDを取得
        let articleURLstr = articleURL.absoluteString
        let articleID = String(articleURLstr.suffix(5))
        
        // NSUserDefaults型でディスク読み込んでから書き込み
        // セット
        let defaults: UserDefaults = UserDefaults.standard

            //読み込み
        var ID:[String] = defaults.stringArray(forKey: "articleID") ?? ["default"]
        
            if ID.contains(articleID){
                //すでに登録されいてるなら解除（消す）
                ID.removeAll(where: { $0  == articleID })
                //ポップアップを表示させる。０.５秒後に自動で消えるようにする。
                let dialog: UIAlertController = UIAlertController(title: "お気に入りリストから削除しました", message: "☆", preferredStyle: .alert)
                self.present(dialog, animated: true) { () -> Void in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.dismiss(animated: true, completion: nil)
                    }
                }
                }else{
                // 登録されていないなら、値の追加
                ID.append(articleID)
                //ポップアップを表示させる。０.５秒後に自動で消えるようにする。
                let dialog: UIAlertController = UIAlertController(title: "お気に入り登録されました", message: "★", preferredStyle: .alert)
                self.present(dialog, animated: true) { () -> Void in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }
        // 値をセット
        defaults.set(ID, forKey: "articleID")
        // データ保存
        defaults.synchronize()
        print(defaults.object(forKey: "articleID"))
        
    }
    
    
    /// HTML形式で記述された文字列をNSAttributedStringに変換する
    ///
    /// - Parameter text: 変換する文字列
    /// - Returns: HTMLドキュメントに変換されたNSAttributedString
    func parseText2HTML(sourceText text: String) -> NSAttributedString? {
        
        // 受け取ったデータをUTF-8エンコードする
        let encodeData = text.data(using: String.Encoding.utf8, allowLossyConversion: true)
        
        // 表示データのオプションを設定する
        let attributedOptions : [NSAttributedString.DocumentReadingOptionKey : Any] = [
            NSAttributedString.DocumentReadingOptionKey(rawValue: NSAttributedString.DocumentAttributeKey.documentType.rawValue): NSAttributedString.DocumentType.html as AnyObject,
            NSAttributedString.DocumentReadingOptionKey(rawValue: NSAttributedString.DocumentAttributeKey.characterEncoding.rawValue): String.Encoding.utf8.rawValue as AnyObject
        ]

        // 文字列の変換処理
        var attributedString:NSAttributedString?
        do {
            attributedString = try NSAttributedString(
                data: encodeData!,
                options: attributedOptions,
                documentAttributes: nil
            )
        } catch {
            // 変換でエラーが出た場合
            print(error)
        }
        return attributedString
    }
    
}

