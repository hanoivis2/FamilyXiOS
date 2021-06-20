//
//  AddFamilyTreeMemoryViewController.swift
//  FamilyTree
//
//  Created by Gia Huy on 13/06/2021.
//

import UIKit
import DKImagePickerController
import SKPhotoBrowser
import JGProgressHUD
import DatePickerDialog
import Loaf
import Alamofire
import ObjectMapper

class AddFamilyTreeMemoryViewController : UIViewController, NavigationControllerCustomDelegate {
    
    
    @IBOutlet weak var view_image: UIView!
    @IBOutlet weak var collection_image: UICollectionView!
    @IBOutlet weak var constraint_image_selected: NSLayoutConstraint!
    @IBOutlet weak var textfield_content_post: UITextView!
    @IBOutlet weak var textfield_birthday:UITextField!
    
    var selectedAssets = [UIImage]()
    var image_urls = [String]()
    var treeId = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.textfield_content_post.placeholder = "Some description for memory ..."
        self.textfield_content_post.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        textfield_content_post.delegate = self
        
        textfield_content_post.addDoneButtonOnKeyboard()
        
        constraint_image_selected.constant = 0
        view_image.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //custom navigation bar
        let navigationControllerCustom : NavigationControllerCustom = self.navigationController as! NavigationControllerCustom
        navigationControllerCustom.setUpNavigationBar(self, hideBackButton: false, hideAddButton: true, title: "ADD MEMORY")
        navigationControllerCustom.touchTarget = self
        navigationControllerCustom.navigationBar.barTintColor = ColorUtils.toolbar()
        navigationControllerCustom.navigationBar.isHidden = false
        
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.navigationController?.navigationItem.backBarButtonItem?.isEnabled = false
        
       
    }
    
    func backTap() {
        navigationController?.popViewController(animated: true)
    }
    
    func addFamilyMemory() {
        
        var dateString = ""
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let date = dateFormatter.date(from: self.textfield_birthday.text!)
        dateFormatter.dateFormat = "yyyy-MM-ddThh:mm:ss.s+zzzzzz"
        dateString = dateFormatter.string(from: date!)
        
        ResAPI.sharedInstance.addFamilyTreeMemory(treeId: treeId, description: textfield_content_post.text!, memoryDate: dateString, imageUrls: image_urls, { (data, message) -> Void in
            
            switch message {
            case "SUCCESS":
                Loaf.init("Add successfully", state: .success, location: .bottom, presentingDirection: .left, dismissingDirection: .vertical, sender: self).show(.custom(2.5), completionHandler: { _ in
                    self.navigationController?.popViewController(animated: true)
                })
                
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
                self.addFamilyMemory()
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
    }
    
    func uploadPhotoToServer(parameters: Dictionary<String, AnyObject>, imageData: Data?, fileName:String, completion: ((String) -> Void)?) {
        
        let urlUploadFile = OAUTH_SERVER_URL  + String(format: API_UPLOAD_IMAGE, ManageCacheObject.getVersion())

        let headers: HTTPHeaders = [
            "Content-type": "multipart/form-data",
            "Authorization":"\(ManageCacheObject.getCurrentAccount().accessToken)"
        ]
        
        let processingClosure: ((Double) -> Void)? = {(percent: Double) in
            print("Upload: \(percent*100)%")
        }
        
        let successClosure: ((DataResponse<Any>) -> Void)? = {response in
            print("SUCCEEDED :)")
            if let res:ResResponse = Mapper<ResResponse>().map(JSONObject: response.result.value) {
                if let url = res.data as? String {
                    completion!(url)
                }
                else {
                    completion!("")
                    print(res.message ?? "fail")
                }
            }
            else {
                completion!("")
            }
        }
        
        let failClosure: ((Error) -> Void)? = { err in
            print("FAILED :( \(err.localizedDescription)")
            Loaf.init(err.localizedDescription, state: .error, location: .bottom, presentingDirection: .left, dismissingDirection: .vertical, sender: self).show(.custom(3), completionHandler: nil)
        }
        
        ImageUploadClient.uploadWithData(serverUrl: URL(string: urlUploadFile)!, headers: headers, fileData: imageData!, filename: fileName, progressing: processingClosure, success: successClosure, failure: failClosure)
    }
    
    @IBAction func actionChooseMemoryDate(_ sender: Any) {
        
        var dateComponents = DateComponents()
        dateComponents.year = -100
        
        var dateComponentsFuture = DateComponents()
        dateComponentsFuture.year = 100


        let datePicker = DatePickerDialog(textColor: .black, buttonColor: .darkGray, font: UIFont(name: "Helvetica", size: 14.0)!, locale: Locale(identifier: "vi_VN"), showCancelButton: true)
        self.view.addSubview(datePicker)
        
        var currentDate = Date()
        if !self.textfield_birthday.text!.isEmpty {
            let dateFormatter = DateFormatter()
            dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
            dateFormatter.dateFormat = "dd/MM/yyyy"
            currentDate = dateFormatter.date(from: self.textfield_birthday.text!)!
        }

        datePicker.show("Choose date", doneButtonTitle: "Done", cancelButtonTitle: "Cancel", defaultDate: currentDate, minimumDate: Calendar.current.date(byAdding: dateComponents, to: Date()), maximumDate: Calendar.current.date(byAdding: dateComponentsFuture, to: Date()), datePickerMode: .date) { (date) in
            if let dt = date {
                let formatter = DateFormatter()
                formatter.dateFormat = "dd/MM/yyyy"
                self.textfield_birthday.text = formatter.string(from: dt)
            }
        }

        self.view.addSubview(datePicker)
    }
    
    @IBAction func actionChooseImage(_ sender: Any) {
      
        
        let pickerController = DKImagePickerController()
        pickerController.maxSelectableCount = 30
        pickerController.allowMultipleTypes = false
        pickerController.assetType = .allPhotos
        pickerController.sourceType = .photo

        pickerController.didSelectAssets = { (assets: [DKAsset]) in
            var images: [UIImage] = []
            let group = DispatchGroup()
            for item in assets {
                group.enter()
                item.fetchOriginalImage(completeBlock: {image, _ in

                    
                    images.append(image!)
                    
                    
                    group.leave()
                })
            }
            group.notify(queue: .main) {
                self.selectedAssets = images
                switch self.selectedAssets.count {
                case 0:
                    self.constraint_image_selected.constant = 0
                    self.view_image.isHidden = true
                    break
                default:
                    self.constraint_image_selected.constant = 250
                    self.view_image.isHidden = false
                    break
                }
                DispatchQueue.main.async { [weak self] in
                    self?.collection_image.reloadData()
                }
            }
        }
        
        self.present(pickerController, animated: true) {}
    }
    
    @IBAction func actionCreateMemory(_ sender:Any) {
        
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Please wait some minutes to upload all images..."
        hud.show(in: self.view)
        
        if textfield_content_post.text.isEmpty {
            Loaf.init("Please fill in memory's description", state: .info, location: .bottom, presentingDirection: .left, dismissingDirection: .vertical, sender: self).show(.custom(2.5), completionHandler: nil)
        }
        else if textfield_birthday.text!.isEmpty {
            Loaf.init("Please choose memory date", state: .info, location: .bottom, presentingDirection: .left, dismissingDirection: .vertical, sender: self).show(.custom(2.5), completionHandler: nil)
        }
        else {
            if(!selectedAssets.isEmpty) {
                
                
                
                let group1 = DispatchGroup()
                
                for i in 0..<self.selectedAssets.count {
                    
                    group1.enter()
                    var isBreak = false
                    
                    let item = self.selectedAssets[i]
                    let parameters = [String:AnyObject]()
                    var imageData: Data = item.pngData()!
                    imageData = Utils.bestImageDataForUpload(data: imageData, item: item)
                    let date = Date()
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-ddHH:mm:ss"
                    let result = formatter.string(from: date)
                    let randomString = String((0..<15).map{ _ in result.randomElement()! })
                    let file_name = String(format: "avatar_%@.%@", randomString, "jpg")
                    
                    
                    self.uploadPhotoToServer(parameters: parameters, imageData: imageData, fileName: file_name) { (url) in

                        if url == "" {
                            isBreak = true
                        }
                        else {
                            self.image_urls.append(url)

                        }

                        group1.leave()
                    }

                    if isBreak {
                        break
                    }

                }
                
                group1.notify(queue: .main) {

                    if self.selectedAssets.count == self.image_urls.count {
                        print(">>>>> post, \(self.image_urls.count)")
                        self.addFamilyMemory()
                    }
                    else {
                        print(">>>>> reject, \(self.image_urls.count)")
                        self.image_urls.removeAll()
                        Loaf.init("One or more of your images is too large to upload, please try other images!", state: .warning, location: .bottom, presentingDirection: .left, dismissingDirection: .vertical, sender: self).show(.custom(5), completionHandler: nil)
                    }

                    hud.dismiss()
                }
            }
            else {
                self.addFamilyMemory()
            }
        }
        
        
    }
    
}

extension AddFamilyTreeMemoryViewController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       return selectedAssets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
         let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImagePostCollectionViewCell", for: indexPath as IndexPath) as! ImagePostCollectionViewCell
        let image_selected = self.selectedAssets[indexPath.row]
        cell.image_post.image = image_selected
        cell.pos = indexPath.row
        cell.delegate = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 250, height: 250)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let images: [SKPhoto] = selectedAssets.map(){item -> SKPhoto in
            let photo: SKPhoto = SKPhoto.photoWithImage(item)
            photo.shouldCachePhotoURLImage = false
            return photo
        }

        // 2. create PhotoBrowser Instance, and present.
        let browser = SKPhotoBrowser(photos: images)
        browser.initializePageIndex(indexPath.row)
        present(browser, animated: true, completion: {})
    }
    
}

extension AddFamilyTreeMemoryViewController : UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        
        if textView.text.isEmpty {
            textView.placeholder = "Some description for memory ..."
        }
        else {
            textView.placeholder = ""
        }

    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard range.location == 0 else {
            return true
        }
        let newString = (textView.text as NSString).replacingCharacters(in: range, with: text) as NSString
        return newString.rangeOfCharacter(from: NSCharacterSet.whitespacesAndNewlines).location != 0
    }
    

    
}

extension AddFamilyTreeMemoryViewController : ImagePostCollectionViewCellDelegate {
    func erase(pos: Int) {
        self.selectedAssets.remove(at: pos)
        
        if self.selectedAssets.count > 0 {
            UIView.animate(withDuration: 0.2,
                       delay: 0.1,
                       options: UIView.AnimationOptions.curveEaseIn,
                       animations: { () -> Void in
                        self.constraint_image_selected.constant = 250
                        self.view_image.isHidden = false
            }, completion: { (finished) -> Void in
                
            })
        }
        else {
            UIView.animate(withDuration: 0.2,
                       delay: 0.1,
                       options: UIView.AnimationOptions.curveEaseIn,
                       animations: { () -> Void in
                        self.constraint_image_selected.constant = 0
                        self.view_image.isHidden = true
            }, completion: { (finished) -> Void in
                
            })
        }
        
        collection_image.reloadData()
        
       
    }
}

protocol ImagePostCollectionViewCellDelegate {
    func erase(pos:Int)
}

class ImagePostCollectionViewCell: UICollectionViewCell {
    
    
    var pos = 0
    var delegate:ImagePostCollectionViewCellDelegate?
    
    @IBOutlet weak var image_post: UIImageView!
    
    @IBAction func btn_cancel(_ sender: Any) {
        delegate?.erase(pos: pos)
    }
}
