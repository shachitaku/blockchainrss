//
//  HTMLtoString.swift
//  blockchain-info-ios
//
//  Created by staff on 2018/12/12.
//  Copyright © 2018 takumi-kimura. All rights reserved.
//  http://b.hatena.ne.jp/entry/s/medium.com/swift-column/4f04d00a5804

import UIKit
import XLPagerTabStrip

// デフォルトで継承している UIViewController を ButtonBarPagerTabStripViewController に書き換える
class ParentViewController: ButtonBarPagerTabStripViewController{
    
    override func viewDidLoad() {
        settings.style.buttonBarBackgroundColor = .black
        // ButtonBarItemの背景色
        settings.style.buttonBarItemBackgroundColor = .white
        // 選択中のButtonBarの下部の色
        settings.style.selectedBarBackgroundColor = .orange
        settings.style.buttonBarItemFont = .boldSystemFont(ofSize: 14)
        settings.style.selectedBarHeight = 2.0
        settings.style.buttonBarMinimumLineSpacing = 0
        settings.style.buttonBarItemTitleColor = .black
        settings.style.buttonBarItemsShouldFillAvailiableWidth = true
        settings.style.buttonBarLeftContentInset = 0
        settings.style.buttonBarRightContentInset = 0
        changeCurrentIndexProgressive = { [weak self] (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            guard changeCurrentIndex == true else { return }
            // 選択されていないボタンのテキスト色
            oldCell?.label.textColor = .black
            // 選択されているボタンのテキスト色
            newCell?.label.textColor = .red
        }
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        var vcs: [UIViewController] = []
        let table1 =  UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "人気記事") as! RankingTableViewController
        table1.itemInfo = "人気記事"
        vcs.append(table1)
        let table2 =  UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Knowledge") as! KnowledgeTableViewController
        table2.itemInfo = "ナレッジ"
        vcs.append(table2)
        return vcs
    }
    
    
}
