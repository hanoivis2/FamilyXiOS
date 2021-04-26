//
//  ArrayChoiceReportViewController.swift
//  Techres-Sale
//
//  Created by Gia Huy on 6/24/19.
//  Copyright © 2019 vn.printstudio.res.employee. All rights reserved.
//

// Copyright 2018, Ralf Ebert
// License   https://opensource.org/licenses/MIT
// License   https://creativecommons.org/publicdomain/zero/1.0/
// Source    https://www.ralfebert.de/ios-examples/uikit/choicepopover/

import UIKit

protocol ArrayChoiceReportViewControllerDelegate {
    func selectAt(pos: Int, people:People)
}

class ArrayChoiceReportViewController<Element> : UITableViewController {
    
    typealias SelectionHandler = (Element) -> Void
    typealias LabelProvider = (Element) -> String
    
    private let values : [Element]
    private let labels : LabelProvider
    private let onSelect : SelectionHandler?
    //var index:Int = 0
    
    var delegate : ArrayChoiceReportViewControllerDelegate?
    
    
    var listString = [String]()
    var list_icons = [String]()
    var people = People()
    
    override func viewDidLoad() {
        let nib = UINib.init(nibName: "CustomActionTableViewCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "CustomActionTableViewCell")
        self.tableView.separatorStyle = .none
    }
    
    init(_ values : [Element], labels : @escaping LabelProvider = String.init(describing:), onSelect : SelectionHandler? = nil) {
        self.values = values
        self.onSelect = onSelect
        self.labels = labels
        super.init(style: .plain)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listString.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomActionTableViewCell", for: indexPath) as! CustomActionTableViewCell
        
        cell.lbl_action.text = listString[indexPath.row]
        //        cell.textLabel?.text = listString[indexPath.row]
        cell.img_icon.image = UIImage(named: self.list_icons[indexPath.row])
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.dismiss(animated: true)
        delegate?.selectAt(pos: indexPath.row, people: people)
   }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
}

