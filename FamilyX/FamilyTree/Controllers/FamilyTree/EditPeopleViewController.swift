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


protocol EditPeopleDelegate {
    func editPeople(people:People)
}

class EditPeopleViewController : UIViewController, NavigationControllerCustomDelegate {

    @IBOutlet weak var img_avatar: UIImageView!
    @IBOutlet weak var textfield_id: UITextField!
    @IBOutlet weak var textfield_name: UITextField!
    @IBOutlet weak var textfield_birthday: UITextField!
    @IBOutlet weak var textfield_gender: UITextField!
    @IBOutlet weak var textfield_relationship: UITextField!
    
    var delegate:EditPeopleDelegate?
    
    let dropDownGender = DropDown()
    let dropDownRelationship = DropDown()
    var allGenderType: [GenderType] = [GenderType(id: 1, text: "Male"),
                                        GenderType(id: 0, text: "Female")]
    var allRelationshipType: [RelationshipType] = [RelationshipType(id: 0, text: "Wife"),
                                               RelationshipType(id: 1, text: "Children")]
    var genderSelected = 0
    var relationshipSelected = 0
    
    var people = People()

    override func viewDidLoad() {
        super.viewDidLoad()

        dropDownGender.anchorView = textfield_gender
        dropDownRelationship.anchorView = textfield_relationship
        
        dropDownGender.dataSource = allGenderType.map(){$0.text}
        dropDownRelationship.dataSource = allRelationshipType.map(){$0.text}
        
        DropDown.appearance().selectedTextColor = ColorUtils.main_color()
        DropDown.appearance().textColor = UIColor.black
        DropDown.appearance().textFont = UIFont.systemFont(ofSize: 14)
        dropDownGender.selectRow(at: 0)
        dropDownRelationship.selectRow(at: 0)
        
        self.textfield_id.text = String(people.id)
        self.textfield_name.text = people.fullName
        self.textfield_birthday.text = people.birthday
        self.textfield_gender.text = (people.gender == GENDER_ID.MALE.rawValue) ? "Male" : "Female"
        self.genderSelected = people.gender
        self.img_avatar.image = people.image

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //custom navigation bar
        let navigationControllerCustom : NavigationControllerCustom = self.navigationController as! NavigationControllerCustom
        navigationControllerCustom.setUpNavigationBar(self, hideBackButton: false, title: "EDIT NODE")
        navigationControllerCustom.touchTarget = self
        self.navigationItem.hidesBackButton = true
        
    }
    
    func backTap() {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btn_confirm(_ sender: Any) {
        
        let people = People()
        people.id = Int(textfield_id.text!)!
        people.fullName = textfield_name.text!
        people.birthday = textfield_birthday.text!
        people.gender = genderSelected
        people.image =  img_avatar.image!
        
        delegate?.editPeople(people: people)
        navigationController?.popViewController(animated: true)
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
            dateFormatter.dateFormat = "dd/MM/yyyy"
            currentDate = dateFormatter.date(from: self.textfield_birthday.text!)!
        }

        datePicker.show("Choose your birthday", doneButtonTitle: "Done", cancelButtonTitle: "Cancel", defaultDate: currentDate, minimumDate: Calendar.current.date(byAdding: dateComponents, to: Date()), maximumDate: Calendar.current.date(byAdding: dateComponentsFuture, to: Date()), datePickerMode: .date) { (date) in
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

extension EditPeopleViewController : CropViewControllerDelegate {
    
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        self.img_avatar.image = image
        self.navigationController?.popViewController(animated: true)
    }
    
    func cropViewController1(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        
    }

}
