//
//  FamilyMemoriesViewController.swift
//  FamilyTree
//
//  Created by Gia Huy on 11/06/2021.
//

import UIKit

class FamilyMemoriesViewController : UIViewController {
    
    @IBOutlet weak var tbl_memories:UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tbl_memories.separatorStyle = .none
        tbl_memories.allowsSelection = false
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
}

extension FamilyMemoriesViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FamilyMemoriesTableViewCell") as! FamilyMemoriesTableViewCell
        
        cell.collection_memoryImage.delegate = cell.self
        cell.collection_memoryImage.dataSource = cell.self
        cell.lbl_name.text = "Tran Gia Huy"
        cell.lbl_date.text = "06/02/2019"
        cell.lbl_memoryName.text = "Sinh nhat Vy"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}

protocol FamilyMemoriesDelegate {
    func delete(at:Int)
}

class FamilyMemoriesTableViewCell : UITableViewCell {
    
    @IBOutlet weak var img_avatar: UILabel!
    @IBOutlet weak var lbl_name: UILabel!
    @IBOutlet weak var lbl_date: UILabel!
    @IBOutlet weak var lbl_memoryName: UILabel!
    @IBOutlet weak var collection_memoryImage: UICollectionView!
    
    var imageUrls = [String]()
    var delegate:FamilyMemoriesDelegate?
    var pos = 0
    
    @IBAction func btn_deleteMemories(_ sender: Any) {
        delegate?.delete(at: pos)
    }
}

extension FamilyMemoriesTableViewCell : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FamilyMemoriesImageColletionViewCell", for: indexPath) as! FamilyMemoriesImageColletionViewCell
        
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
         return 10
    }
}

class FamilyMemoriesImageColletionViewCell : UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
}
