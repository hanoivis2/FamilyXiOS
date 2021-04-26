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
    var people = [People]()
    var rootPeople = People()
    var lines = [CAShapeLayer]()
    var firstView = true

    override func viewDidLoad() {
        super.viewDidLoad()

        constraint_view_canvas_width.constant = self.view.frame.width * 4
        constraint_view_canvas_height.constant = self.view.frame.height * 4
        view_canvas.backgroundColor = .clear
        
        people.append(People(id: 1, fullName: "Trần Gia Huy", birthday: "17/09/1999", gender: GENDER_ID.MALE.rawValue, image: UIImage(), wifeId: 2, fatherId: 0))
        people.append(People(id: 2, fullName: "Nguyễn Phước Thanh Vy", birthday: "06/02/1998", gender: GENDER_ID.FEMALE.rawValue, image: UIImage(), wifeId: 0, fatherId: 0))
        people.append(People(id: 3, fullName: "Thi Quốc Hùng", birthday: "06/02/1998", gender: GENDER_ID.MALE.rawValue, image: UIImage(), wifeId: 4, fatherId: 1))
        people.append(People(id: 4, fullName: "Nguyễn Thị A", birthday: "06/02/1998", gender: GENDER_ID.FEMALE.rawValue, image: UIImage(), wifeId: 0, fatherId: 0))
        people.append(People(id: 5, fullName: "Huỳnh Đức Huy", birthday: "06/02/1998", gender: GENDER_ID.MALE.rawValue, image: UIImage(), wifeId: 9, fatherId: 1))
        people.append(People(id: 9, fullName: "Vũ Thị Hải Yến", birthday: "06/02/1998", gender: GENDER_ID.FEMALE.rawValue, image: UIImage(), wifeId: 0, fatherId: 0))
        people.append(People(id: 6, fullName: "Thi Quốc C", birthday: "06/02/1998", gender: GENDER_ID.MALE.rawValue, image: UIImage(), wifeId: 7, fatherId: 3))
        people.append(People(id: 7, fullName: "Trương Thị E", birthday: "06/02/1998", gender: GENDER_ID.FEMALE.rawValue, image: UIImage(), wifeId: 0, fatherId: 0))
        people.append(People(id: 8, fullName: "Thi Quốc D", birthday: "06/02/1998", gender: GENDER_ID.MALE.rawValue, image: UIImage(), wifeId: 0, fatherId: 3))
        people.append(People(id: 10, fullName: "Huỳnh Đức Tuấn", birthday: "06/02/1998", gender: GENDER_ID.MALE.rawValue, image: UIImage(), wifeId: 0, fatherId: 5))
        people.append(People(id: 11, fullName: "Huỳnh Đức Lợi", birthday: "06/02/1998", gender: GENDER_ID.FEMALE.rawValue, image: UIImage(), wifeId: 0, fatherId: 5))
        
        for person in people {
            if person.fatherId == 0 && person.gender == GENDER_ID.MALE.rawValue {
                self.rootPeople = person
                break
            }
        }
        
        
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
        
        
        renderTree()
    }
    
    func calcutlateSpaceToFirstPeople(people:People, firstPeople:People) -> Int {
        var result = 0
        
        if people.gender == GENDER_ID.FEMALE.rawValue {
            
            if people.fatherId == 0 {
                return calcutlateSpaceToFirstPeople(people: getHusband(people: people), firstPeople: firstPeople)
            }

        }
        
        var postMan = people
        
        while (postMan.id != firstPeople.id) {
            result += 1
            postMan = getFather(people: postMan)
            if postMan.fatherId == 0 {
                
            }
        }
        
        
        return result
    }
    
    func getFather(people:People) -> People {
        for item in self.people {
            if item.id == people.fatherId {
                return item
            }
        }
        return People()
    }
    
    func getHusband(people:People) -> People {
        for item in self.people {
            if item.wifeId == people.id {
                return item
            }
        }
        return People()
    }
    
    func getWife(people:People) -> People {
        for item in self.people {
            if item.id == people.wifeId {
                return item
            }
        }
        return People()
    }
    
    func getPeopleView(people:People) -> PeopleView {
        for view in self.peopleViews {
            if view.people.id == people.id {
                return view
            }
        }
        return PeopleView()
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
    
    func drawSiblingsLine(siblings:[People]) {
        let firstSiblingView = getPeopleView(people: siblings.first!)
        let lastSiblingView = getPeopleView(people: siblings.last!)
        
        let firstSiblingMinX = firstSiblingView.frame.minX
        let firstSiblingMinY = firstSiblingView.frame.minY
        let lastSiblingMinX = lastSiblingView.frame.minX
        
        let line1 = drawLineFromPoint(start: CGPoint(x: firstSiblingMinX + (_peopleNodeWidth / 2), y: firstSiblingMinY), toPoint: CGPoint(x: firstSiblingMinX + (_peopleNodeWidth / 2), y: firstSiblingMinY - _siblingsLineHeight), ofColor: .black, inView: view_canvas)
        lines.append(line1)
        
        let line2 = drawLineFromPoint(start: CGPoint(x: lastSiblingMinX + (_peopleNodeWidth / 2), y: firstSiblingMinY), toPoint: CGPoint(x: lastSiblingMinX + (_peopleNodeWidth / 2), y: firstSiblingMinY - _siblingsLineHeight), ofColor: .black, inView: view_canvas)
        lines.append(line2)
        
        let line3 = drawLineFromPoint(start: CGPoint(x: firstSiblingMinX + (_peopleNodeWidth / 2), y: firstSiblingMinY - _siblingsLineHeight), toPoint: CGPoint(x: lastSiblingMinX + (_peopleNodeWidth / 2), y: firstSiblingMinY - _siblingsLineHeight), ofColor: .black, inView: view_canvas)
        lines.append(line3)
    }
    

    
    func addWife(rootPeople:People, newPeople:People) {
        
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
        view.frame.origin.x = relativePeopleNode.frame.maxX + _nodeHorizontalSpace
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

        view_canvas.frame.origin.x = 0
        view_canvas.frame.origin.y = 0
    }
    
    
    
    func renderTree() {
        
        var treeHeight = 0
        
        for item in self.people {
            let tempHeight = calcutlateSpaceToFirstPeople(people: item, firstPeople: rootPeople)
            if  tempHeight > treeHeight {
                treeHeight = tempHeight
            }
        }
        
        treeHeight += 1
        
        //draw people at same level
        for i in  stride(from: treeHeight - 1, through: 0, by: -1) {
            
            var peopleInSameLevel = [People]()
            
            for person in people {
                if calcutlateSpaceToFirstPeople(people: person, firstPeople: rootPeople) == i && (person.fatherId != 0 || person.id == rootPeople.id) {
                    peopleInSameLevel.append(person)
                }
            }
                   
            var maxX = _defaultPaddingLeft
            var currentFatherId = 0
            var siblings = [People]()
            
            for person in peopleInSameLevel {
                let view = Bundle.main.loadNibNamed("PeopleView", owner: self, options: nil)?.first as! PeopleView

                view.frame.size = CGSize(width: _peopleNodeWidth, height: _peopleNodeHeight)
            
                
                if person.maxX != 0 {
                    view.frame.origin.x = person.maxX - _peopleNodeWidth - (_nodeHorizontalSpace / 2)
                }
                else {
                    view.frame.origin.x = maxX + _nodeHorizontalSpace
                }
                
                view.frame.origin.y = _defaultPaddingTop + CGFloat(i)*(_peopleNodeHeight + _nodeVerticalSpace)
                
                
                view.clipsToBounds = true
                view.layer.cornerRadius = 8

                view.people = person
                view.delegate = self

                view.lbl_name.text = person.fullName
                view.lbl_birthday.text = person.birthday
                view.lbl_name.font = UIFont(name: "Helvetica-Bold", size: 4)
                view.lbl_birthday.font = UIFont(name: "Helvetica", size: 4)
                view.constraint_height_avatar.constant = 25
                view.img_avatar.image = person.image
                view.setupView()
                if person.gender == GENDER_ID.MALE.rawValue {
                    view.backgroundColor = ColorUtils.male_color()
                }
                else {
                    view.backgroundColor = ColorUtils.female_color()
                }
                

                self.view_canvas.addSubview(view)
                self.peopleViews.append(view)

                
                if person.wifeId != 0 {
                    addWife(rootPeople: person, newPeople: getWife(people: person))
                    maxX = view.frame.maxX + _peopleNodeWidth + _nodeHorizontalSpace
                }
                else {
                    maxX = view.frame.maxX
                }
              
                if currentFatherId == 0 {
                    currentFatherId = person.fatherId
                    siblings.append(person)
                }
                else if currentFatherId != person.fatherId {
                    
                    if siblings.count > 1 {
                        drawSiblingsLine(siblings: siblings)
                        
                        
                        let firstSiblingView = getPeopleView(people: siblings.first!)
                        let lastSiblingView = getPeopleView(people: siblings.last!)
                        
                        let firstSiblingMinX = firstSiblingView.frame.minX
                        let firstSiblingMinY = firstSiblingView.frame.minY
                        let lastSiblingMinX = lastSiblingView.frame.minX
                        
                        let centerX = (firstSiblingMinX + (_peopleNodeWidth / 2) + lastSiblingMinX + (_peopleNodeWidth / 2)) / 2
                        
                        getFather(people: siblings[0]).maxX = centerX
                        
                        let line = drawLineFromPoint(start: CGPoint(x: centerX, y: firstSiblingMinY - _siblingsLineHeight), toPoint: CGPoint(x: centerX, y: firstSiblingMinY - _nodeVerticalSpace - _peopleNodeHeight/2), ofColor: .black, inView: view_canvas)
                        lines.append(line)
                        
                    }
                    else {
                        let childView = getPeopleView(people: siblings[0])
                        getFather(people: siblings[0]).maxX = childView.frame.maxX
                        
                        let line = drawLineFromPoint(start: CGPoint(x: childView.centerX(), y: childView.frame.minY), toPoint: CGPoint(x: childView.centerX(), y: childView.frame.minY - _nodeVerticalSpace - _peopleNodeHeight/2), ofColor: .black, inView: view_canvas)
                        lines.append(line)
                    }
                    
                    
                    siblings.removeAll()
                    siblings.append(person)
                    currentFatherId = person.fatherId
                }
                else if peopleInSameLevel.last?.id == person.id {
                    siblings.append(person)
                    
                    if siblings.count > 1 {
                        drawSiblingsLine(siblings: siblings)
                        
                        
                        let firstSiblingView = getPeopleView(people: siblings.first!)
                        let lastSiblingView = getPeopleView(people: siblings.last!)
                        
                        let firstSiblingMinX = firstSiblingView.frame.minX
                        let firstSiblingMinY = firstSiblingView.frame.minY
                        let lastSiblingMinX = lastSiblingView.frame.minX
                        
                        let centerX = (firstSiblingMinX + (_peopleNodeWidth / 2) + lastSiblingMinX + (_peopleNodeWidth / 2)) / 2
                        
                        getFather(people: siblings[0]).maxX = centerX
                        
                        let line = drawLineFromPoint(start: CGPoint(x: centerX, y: firstSiblingMinY - _siblingsLineHeight), toPoint: CGPoint(x: centerX, y: firstSiblingMinY - _nodeVerticalSpace - _peopleNodeHeight/2), ofColor: .black, inView: view_canvas)
                        lines.append(line)
                        
                    }
                    else {
                        let childView = getPeopleView(people: siblings[0])
                        getFather(people: siblings[0]).maxX = childView.frame.maxX
                        
                        let line = drawLineFromPoint(start: CGPoint(x: childView.centerX(), y: childView.frame.minY), toPoint: CGPoint(x: childView.centerX(), y: childView.frame.minY - _nodeVerticalSpace - _peopleNodeHeight/2), ofColor: .black, inView: view_canvas)
                        lines.append(line)
                    }
                    
                    siblings.removeAll()
                }
                else {
                    siblings.append(person)
                    
                }
            }
        }
        
        view_canvas.frame.origin.x = 0
        view_canvas.frame.origin.y = 0
        
        
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
    
}

extension EditFamilyTreeViewController : AddPeopleDelegate {
    func addPeople(people:People, relativePeople:People, relationshipType:Int) {
        

        
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
                
                break
            }
        }
    }
}

