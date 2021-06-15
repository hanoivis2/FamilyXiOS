//
//  EditUserProfileViewController.swift
//  FamilyTree
//
//  Created by Gia Huy on 15/06/2021.
//

import UIKit
import DropDown
import CropViewController
import DatePickerDialog
import Loaf
import JGProgressHUD
import Alamofire
import ObjectMapper

class EditUserProfileViewController : UIViewController, NavigationControllerCustomDelegate {

    @IBOutlet weak var img_avatar: UIImageView!
    @IBOutlet weak var textfield_firstName: UITextField!
    @IBOutlet weak var textfield_midName: UITextField!
    @IBOutlet weak var textfield_lastName: UITextField!
    @IBOutlet weak var textfield_birthday: UITextField!
    @IBOutlet weak var textfield_gender: UITextField!
    @IBOutlet weak var textfield_phone: UITextField!
    @IBOutlet weak var textfield_address: UITextField!
    
    let dropDownGender = DropDown()
    var allGenderType: [GenderType] = [GenderType(id: GENDER_ID.MALE.rawValue, text: "Male"),
                                        GenderType(id: GENDER_ID.FEMALE.rawValue, text: "Female")]
    
    var genderSelected = 0
    
    var hasChangedImage = false

    override func viewDidLoad() {
        super.viewDidLoad()
        

        dropDownGender.anchorView = textfield_gender
        
        dropDownGender.dataSource = allGenderType.map(){$0.text}
        
        DropDown.appearance().selectedTextColor = ColorUtils.main_color()
        DropDown.appearance().textColor = UIColor.black
        DropDown.appearance().textFont = UIFont.systemFont(ofSize: 14)
        
        let person = ManageCacheObject.getCurrentAccount()
        
        genderSelected = ManageCacheObject.getCurrentAccount().gender
        
        if person.gender == GENDER_ID.MALE.rawValue {
            dropDownGender.selectRow(at: 0)
        }
        else {
            dropDownGender.selectRow(at: 1)
        }
        
       
        
        
        let imageView = UIImageView()
        if let url = URL(string: person.avatarUrl) {
            
            
            imageView.kf.setImage(with: url, placeholder: UIImage(named: "no_image"), options: [.cacheOriginalImage], progressBlock: { receivedSize, totalSize in
                // Progress updated
            }, completionHandler: { result in
                if let image = imageView.image {
                    self.img_avatar.image = image
                }
            })
            
        } else {
            self.img_avatar.image = UIImage(named: "no_image")!
        }

        textfield_firstName.text = person.firstName
        textfield_midName.text = person.midName
        textfield_lastName.text = person.lastName
        textfield_birthday.text = person.birthday
        textfield_gender.text = (person.gender == GENDER_ID.MALE.rawValue) ? "Male" : "Female"
        textfield_phone.text = person.phone
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let navigationControllerCustom : NavigationControllerCustom = self.navigationController as! NavigationControllerCustom
        navigationControllerCustom.setUpNavigationBar(self, hideBackButton: false, title: "EDIT NODE")
        navigationControllerCustom.touchTarget = self
        self.navigationItem.hidesBackButton = true
        
    }
    
    func backTap() {
        navigationController?.popViewController(animated: true)
    }
    
    func editProfile(avatarUrl:String){
        
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Please wait..."
        hud.show(in: self.view)
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let date = dateFormatter.date(from: textfield_birthday.text!)
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let birthday = dateFormatter.string(from: date ?? Date())
        
        ResAPI.sharedInstance.editProfileUser(firstName: textfield_firstName.text ?? "", midName: textfield_midName.text ?? "", lastName: textfield_lastName.text ?? "", avatarUrl: avatarUrl, address: textfield_address.text ?? "", phone: textfield_phone.text ?? "", gender: genderSelected, birthday: birthday, { (data, message) -> Void in
           
            switch message {
            case "SUCCESS":
                Loaf.init("Updated successfully", state: .success, location: .bottom, presentingDirection: .left, dismissingDirection: .vertical, sender: self).show(.custom(2.5), completionHandler: nil)
                if(data != nil){

                    let response:ResResponse = data as! ResResponse

                    if let newAccount = Mapper<Account>().map(JSONObject: response.data) {
                        ManageCacheObject.saveCurrentAccount(newAccount)
                    }
                    else {
                        Loaf.init(response.message ?? "", state: .info, location: .bottom, presentingDirection: .left, dismissingDirection: .vertical, sender: self).show(.custom(2.5), completionHandler: nil)
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
                self.editProfile(avatarUrl: avatarUrl)
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
    
    func uploadPhotoToServer(parameters: Dictionary<String, AnyObject>, imageData: Data?, fileName:String, completion: ((String) -> Void)?) {
        
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Please wait..."
        hud.show(in: self.view)
        
        let urlUploadFile = OAUTH_SERVER_URL  + String(format: API_UPLOAD_IMAGE, ManageCacheObject.getVersion())


        let headers: HTTPHeaders = [
            "Content-type": "multipart/form-data",
            "Authorization":"\(ManageCacheObject.getCurrentAccount().accessToken)"
        ]
        
        let processingClosure: ((Double) -> Void)? = {(percent: Double) in
            
        }
        
        let successClosure: ((DataResponse<Any>) -> Void)? = {response in
            print("SUCCEEDED :)")
            if let res:ResResponse = Mapper<ResResponse>().map(JSONObject: response.result.value) {
                completion!(res.data as! String)
            }
            else {
                completion!("")
                Loaf.init("Your image is too large to upload, please try another by edit your node!", state: .warning, location: .bottom, presentingDirection: .left, dismissingDirection: .vertical, sender: self).show(.custom(5), completionHandler: nil)
            }
            
            hud.dismiss()
        }
        
        let failClosure: ((Error) -> Void)? = { err in
            print("FAILED :( \(err.localizedDescription)")
            Loaf.init(err.localizedDescription, state: .error, location: .bottom, presentingDirection: .left, dismissingDirection: .vertical, sender: self).show(.custom(3), completionHandler: nil)
            hud.dismiss()
        }
        
        ImageUploadClient.uploadWithData(serverUrl: URL(string: urlUploadFile)!, headers: headers, fileData: imageData!, filename: fileName, progressing: processingClosure, success: successClosure, failure: failClosure)
    }

    
    @IBAction func btn_confirm(_ sender: Any) {
        
        if hasChangedImage {
            let item = img_avatar.image!
            let parameters = [String:AnyObject]()
            var imageData: Data = item.pngData()!
            imageData = Utils.bestImageDataForUpload(data: imageData, item: item)
            let date = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-ddHH:mm:ss"
            let result = formatter.string(from: date)
            let randomString = String((0..<15).map{ _ in result.randomElement()! })
            let file_name = String(format: "avatar_%@.%@", randomString, "jpg")
            
            
            uploadPhotoToServer(parameters: parameters, imageData: imageData, fileName: file_name) { (url) in
                self.editProfile(avatarUrl: url)
            }
        }
        else {
            self.editProfile(avatarUrl: "")
        }
        
    }
    
    @IBAction func btn_choose_birthday(_ sender: Any) {
        
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

        datePicker.show("Choose birthday", doneButtonTitle: "Done", cancelButtonTitle: "Cancel", defaultDate: currentDate, minimumDate: Calendar.current.date(byAdding: dateComponents, to: Date()), maximumDate: Calendar.current.date(byAdding: dateComponentsFuture, to: Date()), datePickerMode: .date) { (date) in
            if let dt = date {
                let formatter = DateFormatter()
                formatter.dateFormat = "dd/MM/yyyy"
                self.textfield_birthday.text = formatter.string(from: dt)
            }
        }

        self.view.addSubview(datePicker)
    }

    
    @IBAction func btn_choose_gender(_ sender: Any) {
        dropDownGender.show()
        dropDownGender.selectionAction = { [unowned self] (index: Int, item: String) in
            self.textfield_gender.text = item
            self.genderSelected = self.allGenderType[index].id
        }
    }

    
    
    @IBAction func btn_chhoose_avatar(_ sender: Any) {
        var config = YPImagePickerConfiguration()
        config.screens = [.library, .photo]
        config.library.options = nil
        config.library.onlySquare = false
        config.library.isSquareByDefault = false
        config.library.minWidthForItem = nil
        config.library.mediaType = YPlibraryMediaType.photo
        config.library.defaultMultipleSelection = false
        config.library.maxNumberOfItems = 1
        config.library.minNumberOfItems = 1
        config.library.numberOfItemsInRow = 4
        config.library.spacingBetweenItems = 1.0
        config.library.skipSelectionsGallery = true
        config.library.preselectedItems = nil
        config.showsPhotoFilters = false
        config.showsVideoTrimmer = false
        config.startOnScreen = YPPickerScreen.library

         let picker = YPImagePicker(configuration: config)
         picker.didFinishPicking { [unowned picker] items, _ in
             for item in items {
                 switch item {
                 case .photo(let photo):
                    
                     let image = photo.originalImage.fixedOrientation()!.resizeImage(500, opaque: true)
                     let cropViewController = CropViewController(image: image)
                     cropViewController.aspectRatioPreset = .presetSquare
                     cropViewController.allowedAspectRatios = [.presetSquare]
                     cropViewController.aspectRatioLockEnabled = true
                     cropViewController.aspectRatioLockDimensionSwapEnabled = true
                     cropViewController.resetAspectRatioEnabled = false
                     cropViewController.delegate = self
                     self.navigationController?.pushViewController(cropViewController, animated: true)
                 case .video( _):
                     break
                 }
             }
            picker.dismiss(animated: true, completion: nil)
        }
        self.present(picker, animated: true, completion: nil)
    }
    
}

extension EditUserProfileViewController : CropViewControllerDelegate {
    
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        self.img_avatar.image = image
        self.hasChangedImage = true
        self.navigationController?.popViewController(animated: true)
    }
    
    func cropViewController1(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        
    }

}
