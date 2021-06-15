//
//  FamilyMemoriesViewController.swift
//  FamilyTree
//
//  Created by Gia Huy on 11/06/2021.
//

import UIKit
import JGProgressHUD
import ObjectMapper
import Loaf
import SKPhotoBrowser

protocol FamilyMemoriesViewControllerDelegate {
    func createMemory()
    func logoutFromMemory()
}

class FamilyMemoriesViewController : UIViewController {
    
    @IBOutlet weak var tbl_memories:UITableView!
    
    var treeId = 0
    var memoryIdToDelete = 0
    var memories = [FamilyTreeMemory]()
    var delegate:FamilyMemoriesViewControllerDelegate?
    var refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tbl_memories.separatorStyle = .none
        tbl_memories.allowsSelection = false
        
        setupRefreshControl()
        getFamilyTreeMemories()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    func setupRefreshControl() {
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        self.tbl_memories.addSubview(refreshControl)
        
    }
    
    @objc func refresh(_ sender: AnyObject) {
        // Code to refresh table view
        getFamilyTreeMemories()
    }
    
    func getFamilyTreeMemories(){
        
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Please wait..."
        hud.show(in: self.view)
        
        ResAPI.sharedInstance.getFamilyTreeMemories(treeId: treeId, { (data, message) -> Void in
           
            switch message {
            case "SUCCESS":
                if(data != nil){
                    
                    let response:ResResponse = data as! ResResponse

                    if let memories = Mapper<FamilyTreeMemory>().mapArray(JSONObject: response.data) {
                        self.memories = memories
                        self.tbl_memories.reloadData()
                    }
                    
                }
            case "UNAUTHORIZED":
                ManageCacheObject.saveCurrentAccount(Account())
                for controller in self.navigationController!.viewControllers as Array {
                    if controller.isKind(of: LoginViewController.self) {
                        self.navigationController!.popToViewController(controller, animated: true)
                        return
                    }
                }

                let loginViewController: LoginViewController?
                loginViewController = UIStoryboard.loginViewController()
                self.navigationController!.pushViewController(loginViewController!, animated: false)
                
                Loaf.init(UnauthorizedError, state: .info, location: .bottom, presentingDirection: .left, dismissingDirection: .vertical, sender: self).show(.custom(4), completionHandler: nil)
            case "RECALL":
                self.getFamilyTreeMemories()
            case "NOTFOUND":
                Loaf.init("Request not found", state: .error, location: .bottom, presentingDirection: .left, dismissingDirection: .vertical, sender: self).show(.custom(2.5), completionHandler: nil)
            case "DATA":
                Loaf.init("Data error", state: .error, location: .bottom, presentingDirection: .left, dismissingDirection: .vertical, sender: self).show(.custom(2.5), completionHandler: nil)
            case "FORBIDEN":
                Loaf.init("You don't have permission to do this function", state: .error, location: .bottom, presentingDirection: .left, dismissingDirection: .vertical, sender: self).show(.custom(2.5), completionHandler: nil)
            default:
                if data != nil {
                    let response = data as! ResResponse
                    if !response.message!.isEmpty {
                        Loaf.init(response.message!, state: .error, location: .bottom, presentingDirection: .left, dismissingDirection: .vertical, sender: self).show(.custom(2.5), completionHandler: nil)
                    }
                }
                
            }
            
        })
        self.refreshControl.endRefreshing()
        hud.dismiss()
    }
    
    func deleteFamilyMemory(memoryId:Int) {
        
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Please wait..."
        hud.show(in: self.view)
        
        
        ResAPI.sharedInstance.deleteFamilyTreeMemory(memoryId: memoryId, { (data, message) -> Void in
            
            switch message {
            case "SUCCESS":
                Loaf.init("Delete successfully", state: .success, location: .bottom, presentingDirection: .left, dismissingDirection: .vertical, sender: self).show(.custom(3), completionHandler: nil)
                self.getFamilyTreeMemories()
            case "UNAUTHORIZED":
                self.delegate?.logoutFromMemory()
            case "RECALL":
                self.deleteFamilyMemory(memoryId:memoryId)
            case "NOTFOUND":
                Loaf.init("Request not found", state: .error, location: .bottom, presentingDirection: .left, dismissingDirection: .vertical, sender: self).show(.custom(2.5), completionHandler: nil)
            case "DATA":
                Loaf.init("Data error", state: .error, location: .bottom, presentingDirection: .left, dismissingDirection: .vertical, sender: self).show(.custom(2.5), completionHandler: nil)
            case "FORBIDEN":
                Loaf.init("You don't have permission to do this function", state: .error, location: .bottom, presentingDirection: .left, dismissingDirection: .vertical, sender: self).show(.custom(2.5), completionHandler: nil)
            default:
                if data != nil {
                    let response = data as! ResResponse
                    if !response.message!.isEmpty {
                        Loaf.init(response.message!, state: .error, location: .bottom, presentingDirection: .left, dismissingDirection: .vertical, sender: self).show(.custom(2.5), completionHandler: nil)
                    }
                }
                
            }
            
            hud.dismiss()
        })
    }
    
    @IBAction func btn_addMemory(_ sender:Any) {
        delegate?.createMemory()
    }
    
}

extension FamilyMemoriesViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FamilyMemoriesTableViewCell") as! FamilyMemoriesTableViewCell
        
        let item = memories[indexPath.row]
        
        cell.imageUrls = item.imageUrls
        cell.collection_memoryImage.delegate = cell.self
        cell.collection_memoryImage.dataSource = cell.self
        cell.collection_memoryImage.reloadData()
        cell.delegate = self
        
        cell.lbl_name.text = item.creator.firstName + " " + item.creator.midName + " " + item.creator.lastName
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        let date = dateFormatter.date(from: item.memoryDate)
        dateFormatter.dateFormat = "dd/MM/yyyy"
        cell.lbl_date.text = dateFormatter.string(from: date ?? Date())
        
 
        cell.lbl_memoryName.text = item.description
        
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}

extension FamilyMemoriesViewController : FamilyMemoriesDelegate {
    func showImageAt(pos: Int, images:[SKPhoto]) {
        let browser = SKPhotoBrowser(photos: images)
        browser.initializePageIndex(pos)
        present(browser, animated: true, completion: {})
    }
    
    func delete(at: Int) {
        self.memoryIdToDelete = memories[at].id
        self.dismiss(animated: true, completion: nil)
        let dialogConfirmViewController:DialogConfirmViewController?
        dialogConfirmViewController = UIStoryboard.dialogConfirmViewController()
        dialogConfirmViewController?.dialogTitle = "Confirm"
        dialogConfirmViewController?.content = "Are you sure to delete this memory?"
        dialogConfirmViewController?.delegate = self
        self.present(dialogConfirmViewController!, animated: true, completion: nil)
    }
}

extension FamilyMemoriesViewController : DialogConfirmDelegate {
    func accept() {
        deleteFamilyMemory(memoryId: memoryIdToDelete)
    }
    
    func deny() {
        
    }
}

protocol FamilyMemoriesDelegate {
    func delete(at:Int)
    func showImageAt(pos:Int, images:[SKPhoto])
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
        return imageUrls.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FamilyMemoriesImageColletionViewCell", for: indexPath) as! FamilyMemoriesImageColletionViewCell
        
        let imageView = UIImageView()
        if let url = URL(string: imageUrls[indexPath.row]) {
            
            
            imageView.kf.setImage(with: url, placeholder: UIImage(named: "no_image"), options: [.cacheOriginalImage], progressBlock: { receivedSize, totalSize in
                // Progress updated
            }, completionHandler: { result in
                if let image = imageView.image {
                    cell.imageView.image = image
                }
            })
            
        } else {
            cell.imageView.image = UIImage(named: "no_image")!
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 120, height: 120)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
         return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let images: [SKPhoto] = imageUrls.map(){item -> SKPhoto in
            
            var photo = SKPhoto.photoWithImage(UIImage(named: "no_image")!)
            let imageView = UIImageView()
            if let url = URL(string: item) {
                
                
                imageView.kf.setImage(with: url, placeholder: UIImage(named: "no_image"), options: [.cacheOriginalImage], progressBlock: { receivedSize, totalSize in
                    // Progress updated
                }, completionHandler: { result in
                    if let image = imageView.image {
                        photo = SKPhoto.photoWithImage(image)
                    }
                    else {
                        photo = SKPhoto.photoWithImage(UIImage(named: "no_image")!)
                    }
                })
                
            } else {
                photo = SKPhoto.photoWithImage(UIImage(named: "no_image")!)
            }
            
            
            
            photo.shouldCachePhotoURLImage = false
            return photo
        }

        delegate?.showImageAt(pos: indexPath.row, images:images)
    }
}

class FamilyMemoriesImageColletionViewCell : UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
}
