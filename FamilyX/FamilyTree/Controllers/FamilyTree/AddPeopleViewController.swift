//
//  AddPeopleViewController.swift
//  FamilyX
//
//  Created by Gia Huy on 20/03/2021.
//

import UIKit
import DropDown
import CropViewController
import DatePickerDialog
import Loaf

struct GenderType {
    var id: Int
    var text: String
}

struct RelationshipType {
    var id: Int
    var text: String
}

protocol AddPeopleDelegate {
    func addPeople(people:People, relationshipType:Int, relativePersonId:Int, image:UIImage)
}

class AddPeopleViewController : UIViewController, NavigationControllerCustomDelegate {

    @IBOutlet weak var img_avatar: UIImageView!
    @IBOutlet weak var textfield_firstName: UITextField!
    @IBOutlet weak var textfield_lastName: UITextField!
    @IBOutlet weak var textfield_birthday: UITextField!
    @IBOutlet weak var textfield_deathday: UITextField!
    @IBOutlet weak var textfield_gender: UITextField!
    @IBOutlet weak var textfield_relationship: UITextField!
    @IBOutlet weak var textfield_relate: UITextField!
    @IBOutlet weak var textfield_note: UITextField!
    @IBOutlet weak var textfield_tagUser: UITextField!
    
    var delegate:AddPeopleDelegate?
    
    var relativePerson = People()
    var tagUser = Account()
    let dropDownGender = DropDown()
    let dropDownRelationship = DropDown()
    var allGenderType: [GenderType] = [GenderType(id: GENDER_ID.MALE.rawValue, text: "Male"),
                                        GenderType(id: GENDER_ID.FEMALE.rawValue, text: "Female")]
    var allRelationshipType: [RelationshipType] = [RelationshipType(id: 0, text: "Spouse"),
                                               RelationshipType(id: 1, text: "Child"),
                                               RelationshipType(id: 2, text: "Parent")]
    
    var genderSelected = 0
    var relationshipSelected = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        textfield_relate.text = relativePerson.firstName + " " + relativePerson.lastName

        dropDownGender.anchorView = textfield_gender
        dropDownRelationship.anchorView = textfield_relationship
        
        dropDownGender.dataSource = allGenderType.map(){$0.text}
        dropDownRelationship.dataSource = allRelationshipType.map(){$0.text}
        
        DropDown.appearance().selectedTextColor = ColorUtils.main_color()
        DropDown.appearance().textColor = UIColor.black
        DropDown.appearance().textFont = UIFont.systemFont(ofSize: 14)
        dropDownGender.selectRow(at: 0)
        dropDownRelationship.selectRow(at: 0)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let navigationControllerCustom : NavigationControllerCustom = self.navigationController as! NavigationControllerCustom
        navigationControllerCustom.setUpNavigationBar(self, hideBackButton: false, title: "ADD NODE")
        navigationControllerCustom.touchTarget = self
        self.navigationItem.hidesBackButton = true
        
    }
    
    func backTap() {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btn_close(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btn_confirm(_ sender: Any) {
        
        if relationshipSelected == 1 {              //Child
            if textfield_firstName.text!.isEmpty || textfield_lastName.text!.isEmpty {
                Loaf.init("Please fill out first name and last name!", state: .warning, location: .bottom, presentingDirection: .left, dismissingDirection: .vertical, sender: self).show(.custom(3), completionHandler: nil)
            }
            else if textfield_birthday.text!.isEmpty {
                Loaf.init("Please choose birthday!", state: .warning, location: .bottom, presentingDirection: .left, dismissingDirection: .vertical, sender: self).show(.custom(3), completionHandler: nil)
            }
            else if relativePerson.spouse.count != 1 {
                Loaf.init("This person has not have spouse yet!", state: .warning, location: .bottom, presentingDirection: .left, dismissingDirection: .vertical, sender: self).show(.custom(3), completionHandler: nil)
            }
            else {
                let newPeople = People()
                
                if relativePerson.gender == GENDER_ID.MALE.rawValue {
                    newPeople.fatherId = relativePerson.id
                    newPeople.motherId = relativePerson.spouse[0].id
                }
                else {
                    newPeople.fatherId = relativePerson.spouse[0].id
                    newPeople.motherId = relativePerson.id
                }
                
                newPeople.gender = genderSelected
                newPeople.firstName = textfield_firstName.text!
                newPeople.lastName = textfield_lastName.text!
                newPeople.birthday = textfield_birthday.text!
                newPeople.deathday = textfield_deathday.text ?? ""
                newPeople.note = textfield_note.text ?? ""
                
                if tagUser.id == "" {
                    newPeople.userId = nil
                }
                else {
                    newPeople.userId = tagUser.id
                }
                
                delegate?.addPeople(people: newPeople, relationshipType: relationshipSelected, relativePersonId: relativePerson.id, image: self.img_avatar.image ?? UIImage())
                self.navigationController?.popViewController(animated: true)
            }
        }
        else if relationshipSelected == 0 {                                      //Spouse
            if textfield_firstName.text!.isEmpty || textfield_lastName.text!.isEmpty {
                Loaf.init("Please fill out first name and last name!", state: .warning, location: .bottom, presentingDirection: .left, dismissingDirection: .vertical, sender: self).show(.custom(3), completionHandler: nil)
            }
            else if textfield_birthday.text!.isEmpty {
                Loaf.init("Please choose birthday!", state: .warning, location: .bottom, presentingDirection: .left, dismissingDirection: .vertical, sender: self).show(.custom(3), completionHandler: nil)
            }
            else if relativePerson.spouse.count > 0 {
                Loaf.init("This person has already had spouse!", state: .error, location: .bottom, presentingDirection: .left, dismissingDirection: .vertical, sender: self).show(.custom(3), completionHandler: nil)
            }
            else if relativePerson.gender == genderSelected {
                Loaf.init("Spouses has the same gender!", state: .error, location: .bottom, presentingDirection: .left, dismissingDirection: .vertical, sender: self).show(.custom(3), completionHandler: nil)
            }
            else {
                let newPeople = People()
                
                newPeople.fatherId = 0
                newPeople.motherId = 0
                
                newPeople.gender = genderSelected
                newPeople.firstName = textfield_firstName.text!
                newPeople.lastName = textfield_lastName.text!
                newPeople.birthday = textfield_birthday.text!
                newPeople.deathday = textfield_deathday.text ?? ""
                newPeople.note = textfield_note.text ?? ""
                
                if tagUser.id == "" {
                    newPeople.userId = nil
                }
                else {
                    newPeople.userId = tagUser.id
                }
                
                delegate?.addPeople(people: newPeople, relationshipType: relationshipSelected, relativePersonId: relativePerson.id, image: img_avatar.image ?? UIImage())
                self.navigationController?.popViewController(animated: true)
            }
        }
        else {
            if textfield_firstName.text!.isEmpty || textfield_lastName.text!.isEmpty {
                Loaf.init("Please fill out first name and last name!", state: .warning, location: .bottom, presentingDirection: .left, dismissingDirection: .vertical, sender: self).show(.custom(3), completionHandler: nil)
            }
            else if textfield_birthday.text!.isEmpty {
                Loaf.init("Please choose birthday!", state: .warning, location: .bottom, presentingDirection: .left, dismissingDirection: .vertical, sender: self).show(.custom(3), completionHandler: nil)
            }
            else if relativePerson.fatherId > 0 || relativePerson.motherId > 0 {
                Loaf.init("This person has already had parent!", state: .error, location: .bottom, presentingDirection: .left, dismissingDirection: .vertical, sender: self).show(.custom(3), completionHandler: nil)
            }
            else {
                let newPeople = People()
                
                newPeople.fatherId = 0
                newPeople.motherId = 0
                
                newPeople.gender = genderSelected
                newPeople.firstName = textfield_firstName.text!
                newPeople.lastName = textfield_lastName.text!
                newPeople.birthday = textfield_birthday.text!
                newPeople.deathday = textfield_deathday.text ?? ""
                newPeople.note = textfield_note.text ?? ""
                
                if tagUser.id == "" {
                    newPeople.userId = nil
                }
                else {
                    newPeople.userId = tagUser.id
                }
                
                delegate?.addPeople(people: newPeople, relationshipType: relationshipSelected, relativePersonId: relativePerson.id, image: img_avatar.image ?? UIImage())
                self.navigationController?.popViewController(animated: true)
            }
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
    
    @IBAction func btn_tagUser(_ sender: Any) {
        let listUserToTagViewController:ListUserToTagViewController?
        listUserToTagViewController = UIStoryboard.listUserToTagViewController()
        listUserToTagViewController?.delegate = self
        navigationController?.pushViewController(listUserToTagViewController!, animated: true)
    }
    
    @IBAction func btn_choose_gender(_ sender: Any) {
        dropDownGender.show()
        dropDownGender.selectionAction = { [unowned self] (index: Int, item: String) in
            self.textfield_gender.text = item
            self.genderSelected = self.allGenderType[index].id
        }
    }
    
    @IBAction func btn_choose_relationship(_ sender: Any) {
        dropDownRelationship.show()
        dropDownRelationship.selectionAction = { [unowned self] (index: Int, item: String) in
            self.textfield_relationship.text = item
            self.relationshipSelected = self.allRelationshipType[index].id
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

extension AddPeopleViewController : CropViewControllerDelegate {
    
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        self.img_avatar.image = image
        self.navigationController?.popViewController(animated: true)
    }
    
    func cropViewController1(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        
    }

}

extension AddPeopleViewController : ListUserToTagDelegate {
    func tag(user: Account) {
        tagUser = user
        textfield_tagUser.text = user.firstName + " " + user.midName + " " + user.lastName
    }
}
