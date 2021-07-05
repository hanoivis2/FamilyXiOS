//
//  EditPeopleViewController.swift
//  FamilyX
//
//  Created by Gia Huy on 07/04/2021.
//

import UIKit
import DropDown
import CropViewController
import DatePickerDialog
import Loaf
import JGProgressHUD
import ObjectMapper

protocol EditPeopleDelegate {
    func editPeople(people:People, image:UIImage, hasChangeAvatar:Bool)
}

class EditPeopleViewController : UIViewController, NavigationControllerCustomDelegate {

    @IBOutlet weak var img_avatar: UIImageView!
    @IBOutlet weak var textfield_firstName: UITextField!
    @IBOutlet weak var textfield_lastName: UITextField!
    @IBOutlet weak var textfield_birthday: UITextField!
    @IBOutlet weak var textfield_deathday: UITextField!
    @IBOutlet weak var textfield_gender: UITextField!
    @IBOutlet weak var textfield_note: UITextField!
    @IBOutlet weak var textfield_tagUser: UITextField!
    @IBOutlet weak var image_avatar_tagUser: UIImageView!
    
    var delegate:EditPeopleDelegate?
    
    var relativePerson = People()
    var tagUser = Account()
    let dropDownGender = DropDown()
    var allGenderType: [GenderType] = [GenderType(id: GENDER_ID.MALE.rawValue, text: "Male"),
                                        GenderType(id: GENDER_ID.FEMALE.rawValue, text: "Female")]
    
    var genderSelected = 0
    
    var person = People()
    
    var hasChangedImage = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

        dropDownGender.anchorView = textfield_gender
        
        dropDownGender.dataSource = allGenderType.map(){$0.text}
        
        DropDown.appearance().selectedTextColor = ColorUtils.main_color()
        DropDown.appearance().textColor = UIColor.black
        DropDown.appearance().textFont = UIFont.systemFont(ofSize: 14)
        
        
        genderSelected = person.gender
        
        if person.gender == GENDER_ID.MALE.rawValue {
            dropDownGender.selectRow(at: 0)
        }
        else {
            dropDownGender.selectRow(at: 1)
        }
        
        if let userId = person.userId {
            getUserProfile(userId: userId)
        }
        
        
        let imageView = UIImageView()
        if let url = URL(string: person.imageUrl) {
            
            
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
        textfield_lastName.text = person.lastName
        textfield_birthday.text = person.birthday
        textfield_gender.text = (person.gender == GENDER_ID.MALE.rawValue) ? "Male" : "Female"
        textfield_note.text = person.note
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
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    @IBAction func btn_confirm(_ sender: Any) {
        
        if textfield_firstName.text!.isEmpty || textfield_lastName.text!.isEmpty {
            Loaf.init("Please fill out first name and last name!", state: .warning, location: .bottom, presentingDirection: .left, dismissingDirection: .vertical, sender: self).show(.custom(3), completionHandler: nil)
        }
        else if textfield_birthday.text!.isEmpty {
            Loaf.init("Please choose birthday!", state: .warning, location: .bottom, presentingDirection: .left, dismissingDirection: .vertical, sender: self).show(.custom(3), completionHandler: nil)
        }
        else {
            let newPeople = People()
            
            newPeople.fatherId = person.fatherId
            newPeople.motherId = person.motherId
            newPeople.id = person.id
            newPeople.gender = genderSelected
            newPeople.firstName = textfield_firstName.text!
            newPeople.lastName = textfield_lastName.text!
            newPeople.birthday = textfield_birthday.text!
            newPeople.deathday = textfield_deathday.text ?? ""
            newPeople.note = textfield_note.text ?? ""
            newPeople.imageUrl = person.imageUrl
            if tagUser.id == "" {
                newPeople.userId = nil
            }
            else {
                newPeople.userId = tagUser.id
            }
            
            delegate?.editPeople(people: newPeople, image: img_avatar.image ?? UIImage(), hasChangeAvatar: hasChangedImage)
            self.navigationController?.popViewController(animated: true)
        }
        
    }
    
    @IBAction func btn_tagUser(_ sender: Any) {
        let listUserToTagViewController:ListUserToTagViewController?
        listUserToTagViewController = UIStoryboard.listUserToTagViewController()
        listUserToTagViewController?.delegate = self
        navigationController?.pushViewController(listUserToTagViewController!, animated: true)
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
    
    @IBAction func btn_choose_deathday(_ sender: Any) {
        
        var dateComponents = DateComponents()
        dateComponents.year = -100
        
        var dateComponentsFuture = DateComponents()
        dateComponentsFuture.year = 100


        let datePicker = DatePickerDialog(textColor: .black, buttonColor: .darkGray, font: UIFont(name: "Helvetica", size: 14.0)!, locale: Locale(identifier: "vi_VN"), showCancelButton: true)
        self.view.addSubview(datePicker)
        
        var currentDate = Date()
        if !self.textfield_deathday.text!.isEmpty {
            let dateFormatter = DateFormatter()
            dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
            dateFormatter.dateFormat = "dd/MM/yyyy"
            currentDate = dateFormatter.date(from: self.textfield_deathday.text!)!
        }

        datePicker.show("Choose deathday", doneButtonTitle: "Done", cancelButtonTitle: "Cancel", defaultDate: currentDate, minimumDate: Calendar.current.date(byAdding: dateComponents, to: Date()), maximumDate: Calendar.current.date(byAdding: dateComponentsFuture, to: Date()), datePickerMode: .date) { (date) in
            if let dt = date {
                let formatter = DateFormatter()
                formatter.dateFormat = "dd/MM/yyyy"
                self.textfield_deathday.text = formatter.string(from: dt)
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
    
    
    func getUserProfile(userId:String){
        
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Please wait..."
        hud.show(in: self.view)
        
        ResAPI.sharedInstance.getUserProfile(userId: userId, { (data, message) -> Void in
            
          switch message {
            case "SUCCESS":
                if(data != nil){

                    let response:ResResponse = data as! ResResponse

                    if let usersRes = Mapper<Account>().map(JSONObject: response.data) {
                        self.tagUser = usersRes
                        self.textfield_tagUser.text = self.tagUser.firstName + " " + self.tagUser.midName + " " + self.tagUser.lastName
                        
                        let imageView = UIImageView()
                        var imageHolder = UIImage()
                        imageHolder = UIImage(named: "no_image")!
                        
                        if let url = URL(string: usersRes.avatarUrl) {
                            
                            
                            imageView.kf.setImage(with: url, placeholder: imageHolder, options: [.cacheOriginalImage], progressBlock: { receivedSize, totalSize in
                                // Progress updated
                            }, completionHandler: { result in
                                if let image = imageView.image {
                                    self.image_avatar_tagUser.image = image
                                }
                            })
                            
                        } else {
                            
                            self.image_avatar_tagUser.image = imageHolder
                        }
                        
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
            self.getUserProfile(userId:userId)
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
        hud.dismiss()
    }
}

extension EditPeopleViewController : CropViewControllerDelegate {
    
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        self.img_avatar.image = image
        self.hasChangedImage = true
        self.navigationController?.popViewController(animated: true)
    }
    
    func cropViewController1(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        
    }

}

extension EditPeopleViewController : ListUserToTagDelegate {
    func tag(user: Account) {
        tagUser = user
        textfield_tagUser.text = user.firstName + " " + user.midName + " " + user.lastName
        
        let imageView = UIImageView()
        var imageHolder = UIImage()
        imageHolder = UIImage(named: "no_image")!
        
        if let url = URL(string: user.avatarUrl) {
            
            
            imageView.kf.setImage(with: url, placeholder: imageHolder, options: [.cacheOriginalImage], progressBlock: { receivedSize, totalSize in
                // Progress updated
            }, completionHandler: { result in
                if let image = imageView.image {
                    self.image_avatar_tagUser.image = image
                }
            })
            
        } else {
            
            self.image_avatar_tagUser.image = imageHolder
        }
       
    }
}

