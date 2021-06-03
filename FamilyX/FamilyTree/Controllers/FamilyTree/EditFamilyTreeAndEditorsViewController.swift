//
//  ListUserShareTreeManageViewController.swift
//  FamilyTree
//
//  Created by Gia Huy on 02/06/2021.
//

import UIKit
import BmoViewPager

class ListUserShareTreeManageViewController : UIViewController, NavigationControllerCustomDelegate {
    
    @IBOutlet weak var bmo_view_pager_nav_bar: BmoViewPagerNavigationBar!
    @IBOutlet weak var bmo_view_pager: BmoViewPager!
    
    var treeId = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.bmo_view_pager_nav_bar.viewPager = bmo_view_pager
        self.bmo_view_pager.presentedPageIndex = 0
        self.bmo_view_pager.infinitScroll = false
        self.bmo_view_pager.dataSource = self
        self.bmo_view_pager.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //custom navigation bar
        let navigationControllerCustom : NavigationControllerCustom = self.navigationController as! NavigationControllerCustom
        navigationControllerCustom.setUpNavigationBar(self, hideBackButton: false, hideAddButton: true, title: "USERS")
        navigationControllerCustom.touchTarget = self
        navigationControllerCustom.navigationBar.barTintColor = ColorUtils.toolbar()
        navigationControllerCustom.navigationBar.isHidden = false
        
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.navigationController?.navigationItem.backBarButtonItem?.isEnabled = false
    }
    
    func backTap() {
        navigationController?.popViewController(animated: true)
    }
    
}

extension ListUserShareTreeManageViewController : BmoViewPagerDelegate, BmoViewPagerDataSource {
    
    func bmoViewPagerDataSourceNumberOfPage(in viewPager: BmoViewPager) -> Int {
        return 2
    }
    
    func bmoViewPagerDataSource(_ viewPager: BmoViewPager, viewControllerForPageAt page: Int) -> UIViewController {
        switch page {
        case 0 :
            let listUserToShareTreeViewController:ListUserToShareTreeViewController?
            listUserToShareTreeViewController = UIStoryboard.listUserToShareTreeViewController()
            listUserToShareTreeViewController?.treeId = self.treeId
            return listUserToShareTreeViewController!
        default:
            let listUserSharedTreeViewController:ListUserSharedTreeViewController?
            listUserSharedTreeViewController = UIStoryboard.listUserSharedTreeViewController()
            listUserSharedTreeViewController?.treeId = self.treeId
            return listUserSharedTreeViewController!
        }
    }
    
    func bmoViewPagerDataSourceNaviagtionBarItemNormalBackgroundView(_ viewPager: BmoViewPager, navigationBar: BmoViewPagerNavigationBar, forPageListAt page: Int) -> UIView? {
        switch page {
        case 0:
            let view = Bundle.main.loadNibNamed("TreeSeperatorViewBmo", owner: self, options: nil)?.first as! TreeSeperatorViewBmo
            view.lbl_title.text = "Users"
            view.lbl_title.textColor = .black
            view.view_container.backgroundColor = .systemGray5
            view.view_container.clipsToBounds = true
            view.view_container.layer.cornerRadius = 12
            return view
        default:
            let view = Bundle.main.loadNibNamed("TreeSeperatorViewBmo", owner: self, options: nil)?.first as! TreeSeperatorViewBmo
            view.lbl_title.text = "Shared"
            view.lbl_title.textColor = .black
            view.view_container.backgroundColor = .systemGray5
            view.view_container.clipsToBounds = true
            view.view_container.layer.cornerRadius = 12
            return view
        }
    }
    
    func bmoViewPagerDataSourceNaviagtionBarItemHighlightedBackgroundView(_ viewPager: BmoViewPager, navigationBar: BmoViewPagerNavigationBar, forPageListAt page: Int) -> UIView? {
   
        switch page {
        case 0:
            let view = Bundle.main.loadNibNamed("TreeSeperatorViewBmo", owner: self, options: nil)?.first as! TreeSeperatorViewBmo
            view.lbl_title.text = "Users"
            view.lbl_title.textColor = .white
            view.view_container.backgroundColor = ColorUtils.main_color()
            view.view_container.clipsToBounds = true
            view.view_container.layer.cornerRadius = 12
            return view
        default:
            let view = Bundle.main.loadNibNamed("TreeSeperatorViewBmo", owner: self, options: nil)?.first as! TreeSeperatorViewBmo
            view.lbl_title.text = "Shared"
            view.lbl_title.textColor = .white
            view.view_container.backgroundColor = ColorUtils.main_color()
            view.view_container.clipsToBounds = true
            view.view_container.layer.cornerRadius = 12
            return view
        }
        
        
    }
    
    func bmoViewPagerDataSourceNaviagtionBarItemSize(_ viewPager: BmoViewPager, navigationBar: BmoViewPagerNavigationBar, forPageListAt page: Int) -> CGSize {
        return CGSize(width: self.view.frame.width / 2, height: 50)
    }
    
    func bmoViewPagerDataSourceNaviagtionBarItemSpace(_ viewPager: BmoViewPager, navigationBar: BmoViewPagerNavigationBar, forPageListAt page: Int) -> CGFloat {
        return 0
    }
}
