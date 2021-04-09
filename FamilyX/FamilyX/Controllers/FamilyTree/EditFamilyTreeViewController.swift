//
//  TestZoomViewController.swift
//  FamilyX
//
//  Created by Gia Huy on 10/03/2021.
//

import UIKit
import Loaf

class EditFamilyTreeViewController : UIViewController, NavigationControllerCustomDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var view_canvas: UIView!
    @IBOutlet weak var constraint_view_canvas_height: NSLayoutConstraint!
    @IBOutlet weak var constraint_view_canvas_width: NSLayoutConstraint!
    
    var zoomLevel = 1 {
        didSet {
            view_canvas.transform = CGAffineTransform(scaleX: zoomScale[zoomLevel - 1], y: zoomScale[zoomLevel - 1])
            view_canvas.frame.origin.x = 0
            view_canvas.frame.origin.y = 0
        }
    }
    var zoomScale:[CGFloat] = [1,2,3,4]

    var peopleViews = [PeopleView]()
//    var people = [People]()
    var lines = [CAShapeLayer]()
    
    var firstView = true

    override func viewDidLoad() {
        super.viewDidLoad()

        constraint_view_canvas_width.constant = self.view.frame.width * 4
        constraint_view_canvas_height.constant = self.view.frame.height * 4
        view_canvas.backgroundColor = .clear
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //custom navigation bar
        let navigationControllerCustom : NavigationControllerCustom = self.navigationController as! NavigationControllerCustom
        navigationControllerCustom.setUpNavigationBar(self, hideBackButton:true, hideFilterButton:true, title: "EDIT TREE")
        self.navigationItem.hidesBackButton = true
    
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //Add default node
        if firstView == true {
            firstView = false
            
            let people = People()
            people.id = 1
            people.fullName = "Default"
            people.birthday = "01/01/2000"
            people.image = UIImage(named: "male")!
            people.gender = GENDER_ID.MALE.rawValue

            let view = Bundle.main.loadNibNamed("PeopleView", owner: self, options: nil)?.first as! PeopleView

            view.frame.size = CGSize(width: _peopleNodeWidth, height: _peopleNodeHeight)
            view.frame.origin.x = 0
            view.frame.origin.x += CGFloat(_defaultPaddingLeft)
            view.frame.origin.y += CGFloat(_defaultPaddingTop)
            view.clipsToBounds = true
            view.layer.cornerRadius = 8

            view.people = people
            view.delegate = self

            view.lbl_name.text = people.fullName
            view.lbl_birthday.text = people.birthday
            view.lbl_name.font = UIFont(name: "Helvetica-Bold", size: 4)
            view.lbl_birthday.font = UIFont(name: "Helvetica", size: 4)
            view.constraint_height_avatar.constant = 25
            view.img_avatar.image = people.image
            view.setupView()
            if people.gender == GENDER_ID.MALE.rawValue {
                view.backgroundColor = ColorUtils.male_color()
            }
            else {
                view.backgroundColor = ColorUtils.female_color()
            }


            self.view_canvas.addSubview(view)
            
            
            self.peopleViews.append(view)
//            self.people.append(people)

            view_canvas.frame.origin.x = 0
            view_canvas.frame.origin.y = 0
        }
        
        
    }
    
    
    @IBAction func btn_zoom_in(_ sender: Any) {
        if zoomLevel < 4 {
            zoomLevel += 1
        }
    }
    
    @IBAction func btn_zoom_out(_ sender: Any) {
        if zoomLevel > 1 {
            zoomLevel -= 1
        }
    }
    
    
    func addWife(rootPeople:People, newPeople:People) {
        
        if newPeople.gender == GENDER_ID.MALE.rawValue {
            Loaf.init("Wife's gender must be female", state: .error, location: .bottom, presentingDirection: .left, dismissingDirection: .right, sender: self).show(.custom(2), completionHandler: nil)
        }
        else {
            var relativePeopleNode = PeopleView()
            //find relative people node
            for item in self.peopleViews {
                if item.people.id == rootPeople.id {
                    relativePeopleNode = item
                    break
                }
            }

            let view = Bundle.main.loadNibNamed("PeopleView", owner: self, options: nil)?.first as! PeopleView

            view.frame.size = CGSize(width: _peopleNodeWidth, height: _peopleNodeHeight)
            view.frame.origin.x = relativePeopleNode.frame.maxX + CGFloat(_nodeSpace)
            view.frame.origin.y = relativePeopleNode.frame.origin.y
            view.clipsToBounds = true
            view.layer.cornerRadius = 8

            view.people = newPeople
            view.delegate = self

            view.lbl_name.text = newPeople.fullName
            view.lbl_birthday.text = newPeople.birthday
            view.lbl_name.font = UIFont(name: "Helvetica-Bold", size: 4)
            view.lbl_birthday.font = UIFont(name: "Helvetica", size: 4)
            view.constraint_height_avatar.constant = 25
            view.img_avatar.image = newPeople.image
            view.setupView()
            if newPeople.gender == GENDER_ID.MALE.rawValue {
                view.backgroundColor = ColorUtils.male_color()
            }
            else {
                view.backgroundColor = ColorUtils.female_color()
            }
            
            
            let minY1 = relativePeopleNode.frame.minY
            let maxY1 = relativePeopleNode.frame.maxY
            let avgY = (minY1 + maxY1) / 2
            
            let line = drawLineFromPoint(start: CGPoint(x: relativePeopleNode.frame.maxX, y: avgY), toPoint: CGPoint(x:view.frame.minX, y: avgY), ofColor: .black, inView: view_canvas)
            lines.append(line)


            self.view_canvas.addSubview(view)
            self.peopleViews.append(view)
//            self.people.append(rootPeople)

            view_canvas.frame.origin.x = 0
            view_canvas.frame.origin.y = 0
        }
    }

    func addChild(rootPeople:People, newPeople:People) {
      
        if rootPeople.wifeId == 0 {
            Loaf.init("This person has not had wife yet", state: .error, location: .bottom, presentingDirection: .left, dismissingDirection: .right, sender: self).show(.custom(2), completionHandler: nil)
        }
        else {
            var fatherNode = PeopleView()
            var motherNode = PeopleView()
            
            for item in self.peopleViews {
                if item.people.id == rootPeople.id {
                    fatherNode = item
                }
                if item.people.id == rootPeople.wifeId {
                    motherNode = item
                }
            }
            
            if rootPeople.childrenId.count == 1 {
               
                let view = Bundle.main.loadNibNamed("PeopleView", owner: self, options: nil)?.first as! PeopleView
                
                let minX1 = fatherNode.frame.minX
                let maxX1 = fatherNode.frame.maxX
                let minX2 = motherNode.frame.minX
                let maxX2 = motherNode.frame.maxX

                let minY1 = fatherNode.frame.minY
                let maxY1 = fatherNode.frame.maxY

                view.frame.size = CGSize(width: _peopleNodeWidth, height: _peopleNodeHeight)
                view.frame.origin.x = (minX2 + maxX1 - CGFloat(_peopleNodeWidth)) / 2
                view.frame.origin.y = maxY1 + CGFloat(_childrenParentSpace)
                view.clipsToBounds = true
                view.layer.cornerRadius = 8

                view.people = newPeople
                view.delegate = self

                view.lbl_name.text = newPeople.fullName
                view.lbl_birthday.text = newPeople.birthday
                view.lbl_name.font = UIFont(name: "Helvetica-Bold", size: 4)
                view.lbl_birthday.font = UIFont(name: "Helvetica", size: 4)
                view.constraint_height_avatar.constant = 25
                view.img_avatar.image = newPeople.image
                view.setupView()
                if newPeople.gender == GENDER_ID.MALE.rawValue {
                    view.backgroundColor = ColorUtils.male_color()
                }
                else {
                    view.backgroundColor = ColorUtils.female_color()
                }
                           
                let line = drawLineFromPoint(start: CGPoint(x: (minX2 + maxX1) / 2, y: (maxY1 + minY1) / 2), toPoint:CGPoint(x: (minX2 + maxX1) / 2, y: view.frame.minY), ofColor: .black, inView: view_canvas)
                lines.append(line)


                self.view_canvas.addSubview(view)
                self.peopleViews.append(view)
//                self.people.append(newPeople)

                view_canvas.frame.origin.x = 0
                view_canvas.frame.origin.y = 0
            }
            else {
                
            }

        }
        
       
        
    }
    
}

extension EditFamilyTreeViewController : AddPeopleDelegate {
    func addPeople(people:People, relativePeople:People, relationshipType:Int) {
        
        if relationshipType == 0 {
            
//            for i in 0..<self.people.count {
//                if self.people[i].id == relativePeople.id {
//                    self.people[i].wifeId = people.id
//                    break
//                }
//            }
            
            for i in 0..<self.peopleViews.count {
                if self.peopleViews[i].people.id == relativePeople.id {
                    self.peopleViews[i].people.wifeId = people.id
                    break
                }
            }
            
            addWife(rootPeople: relativePeople, newPeople: people)
        }
        else {
            
//            for i in 0..<self.people.count {
//                if self.people[i].id == relativePeople.id {
//                    self.people[i].childrenId.append(people.id)
//                    break
//                }
//            }
            
            for i in 0..<self.peopleViews.count {
                if self.peopleViews[i].people.id == relativePeople.id {
                    self.peopleViews[i].people.childrenId.append(people.id)
                    break
                }
            }
            
            addChild(rootPeople: relativePeople, newPeople: people)
        }
        
    }
    
    
    func drawLineFromPoint(start : CGPoint, toPoint end:CGPoint, ofColor lineColor: UIColor, inView view:UIView) -> CAShapeLayer {

        //design the path
        let path = UIBezierPath()
        path.move(to: start)
        path.addLine(to: end)

        //design path in layer
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = lineColor.cgColor
        shapeLayer.lineWidth = 1.0

        view.layer.addSublayer(shapeLayer)
        return shapeLayer
    }
    
    private func showPopup(_ controller: UIViewController, sourceView: UIView) {
      let presentationController = AlwaysPresentAsPopover.configurePresentation(forController: controller)
      presentationController.sourceView = sourceView
      presentationController.sourceRect = sourceView.bounds
      presentationController.permittedArrowDirections = [.down, .up]
      self.present(controller, animated: true)
    }
}

extension EditFamilyTreeViewController : PeopleViewDelegate {
    
    func nodeTapped(people: People, sourceView: UIView) {
        
        let listName = ["Edit node", "Add node"]
        let listIcon = ["editNode", "addNode"]
       
        let controller = ArrayChoiceReportViewController(Direction.allValues)
       
        controller.people = people
        controller.list_icons = listIcon
        controller.listString = listName
        controller.preferredContentSize = CGSize(width: 120, height: 90)
        controller.delegate = self
       
        showPopup(controller, sourceView: sourceView)
        
    }
}

extension EditFamilyTreeViewController : ArrayChoiceReportViewControllerDelegate {
    
    func selectAt(pos: Int, people:People) {
        if pos == 0 {
            let editPeopleViewController:EditPeopleViewController?
            editPeopleViewController = UIStoryboard.editPeopleViewController()
            editPeopleViewController?.delegate = self
            editPeopleViewController?.people = people
            navigationController?.pushViewController(editPeopleViewController!, animated: true)
        }
        else {
            
            if people.gender == GENDER_ID.FEMALE.rawValue {
                Loaf.init("You can only add node from male node", state: .warning, location: .bottom, presentingDirection: .left, dismissingDirection: .right, sender: self).show(.custom(2), completionHandler: nil)
            }
            else {
                let addPeopleViewController:AddPeopleViewController?
                addPeopleViewController = UIStoryboard.addPeopleViewController()
                addPeopleViewController?.relativePerson = people
                addPeopleViewController?.delegate = self
                navigationController?.pushViewController(addPeopleViewController!, animated: true)
            }
        }
    }
}

extension EditFamilyTreeViewController : EditPeopleDelegate {
    func editPeople(people:People) {
        for i in 0..<self.peopleViews.count {
            if peopleViews[i].people.id == people.id {
                
                let item = peopleViews[i]
                
                item.people.fullName = people.fullName
                item.people.birthday = people.birthday
                item.people.gender = people.gender
                item.people.image = people.image
                
                item.lbl_name.text = people.fullName
                item.lbl_birthday.text = people.birthday
                item.img_avatar.image = people.image
                if people.gender == GENDER_ID.MALE.rawValue {
                    item.backgroundColor = ColorUtils.male_color()
                }
                else {
                    item.backgroundColor = ColorUtils.female_color()
                }
                
//                self.people[i] = people
                
                break
            }
        }
    }
}

