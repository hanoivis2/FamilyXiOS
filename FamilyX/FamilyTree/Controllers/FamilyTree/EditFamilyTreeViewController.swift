//
//  TestZoomViewController.swift
//  FamilyX
//
//  Created by Gia Huy on 10/03/2021.
//

import UIKit
import Loaf
import JGProgressHUD
import ObjectMapper
import Alamofire
import Kingfisher

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
    var treeId = 0
    var selectedDeletePersonId = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        constraint_view_canvas_width.constant = self.view.frame.width * 4
        constraint_view_canvas_height.constant = self.view.frame.height * 4
        view_canvas.backgroundColor = .clear
        
        zoomLevel = 1
        
        getTreeInfo()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        
    }
    
    func calcutlateSpaceToFirstPeople(people:People, firstPeople:People) -> Int {
        var result = 0

        
        var postMan = people
        
        while (postMan.id != firstPeople.id) {
            result += 1
            
            let father = getFather(people: postMan)
            let mother = getMother(people: postMan)
            
            if father.fatherId == 0 && father.motherId == 0
                && mother.fatherId == 0 && mother.motherId == 0 {
                break
            }
            else if father.fatherId == 0 && father.motherId == 0
                        && mother.fatherId != 0 && mother.motherId != 0 {
                postMan = mother
            }
            else {
                postMan = father
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
    
    func getMother(people:People) -> People {
        for item in self.people {
            if item.id == people.motherId {
                return item
            }
        }
        return People()
    }
    
    func getSpouse(people:People) -> People {
        for item in self.people {
            if people.spouse.count > 0 {
                if item.id == people.spouse[0].id {
                    return item
                }
            }
        }
        return People()
    }
    
    func getChildren(people:People) -> [People] {
        
        var results = [People]()
        
        for item in self.people {
            if item.fatherId == people.id || item.motherId == people.id {
                results.append(item)
            }
        }
        return results
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
        var firstSiblingView = getPeopleView(people: siblings.first!)
        var lastSiblingView = getPeopleView(people: siblings.last!)
        
        var minMaxX = firstSiblingView.frame.maxX
        var maxMaxX = firstSiblingView.frame.maxX
        
        for item in siblings {
            let tempView = getPeopleView(people: item)
            if tempView.frame.maxX < minMaxX {
                firstSiblingView = tempView
                minMaxX = tempView.frame.maxX
            }
            if tempView.frame.maxX > maxMaxX {
                lastSiblingView = tempView
                maxMaxX = tempView.frame.maxX
            }
        }
        
        let firstSiblingMinX = firstSiblingView.frame.minX
        let firstSiblingMinY = firstSiblingView.frame.minY
        let lastSiblingMinX = lastSiblingView.frame.minX
        
        for item in siblings {
            let firstSiblingView = getPeopleView(people: item)
            
            let firstSiblingMinX = firstSiblingView.frame.minX
            let firstSiblingMinY = firstSiblingView.frame.minY
            let line = drawLineFromPoint(start: CGPoint(x: firstSiblingMinX + (_peopleNodeWidth / 2), y: firstSiblingMinY), toPoint: CGPoint(x: firstSiblingMinX + (_peopleNodeWidth / 2), y: firstSiblingMinY - _siblingsLineHeight), ofColor: .black, inView: view_canvas)
            lines.append(line)
        }
        
        let line3 = drawLineFromPoint(start: CGPoint(x: firstSiblingMinX + (_peopleNodeWidth / 2), y: firstSiblingMinY - _siblingsLineHeight), toPoint: CGPoint(x: lastSiblingMinX + (_peopleNodeWidth / 2), y: firstSiblingMinY - _siblingsLineHeight), ofColor: .black, inView: view_canvas)
        lines.append(line3)
    }
    

    
    func addSpouseView(rootPeople:People, newPeople:People) {
        
        let relativePeopleNode = getPeopleView(people: rootPeople)

        let view = Bundle.main.loadNibNamed("PeopleView", owner: self, options: nil)?.first as! PeopleView

        view.frame.size = CGSize(width: _peopleNodeWidth, height: _peopleNodeHeight)
        view.frame.origin.x = relativePeopleNode.frame.maxX + _nodeHorizontalSpace
        view.frame.origin.y = relativePeopleNode.frame.origin.y
        view.clipsToBounds = true
        view.layer.cornerRadius = 8

        view.people = newPeople
        view.delegate = self
        
        let imageView = UIImageView()
        if let url = URL(string: newPeople.imageUrl) {
            
            
            imageView.kf.setImage(with: url, placeholder: UIImage(named: "female"), options: [.cacheOriginalImage], progressBlock: { receivedSize, totalSize in
                // Progress updated
            }, completionHandler: { result in
                if let image = imageView.image {
                    view.img_avatar.image = image
                }
            })
            
        } else {
            view.img_avatar.image = UIImage(named: "male")!
        }

        view.lbl_name.text = newPeople.firstName + " " + newPeople.lastName
        view.lbl_birthday.text = newPeople.birthday
        view.lbl_name.font = UIFont(name: "Helvetica-Bold", size: 4)
        view.lbl_birthday.font = UIFont(name: "Helvetica", size: 4)
        view.constraint_height_avatar.constant = 25
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
        for i in stride(from: treeHeight - 1, through: 0, by: -1) {
            
            var peopleInSameLevel = [People]()
            
            for person in people {
                if calcutlateSpaceToFirstPeople(people: person, firstPeople: rootPeople) == i && (person.fatherId != 0 || person.id == rootPeople.id) {
                    peopleInSameLevel.append(person)
                }
            }
                   
            var maxX = _defaultPaddingLeft
            var currentFatherId = 0
            var siblings = [People]()
            
            peopleInSameLevel = peopleInSameLevel.sorted { (a, b) -> Bool in
                
                if a.fatherId < b.fatherId {
                    return false
                }
                else {
                    return true
                }

            }
            
            peopleInSameLevel = peopleInSameLevel.sorted { (a, b) -> Bool in
                
                return a.firstChildMaxX < b.firstChildMaxX

            }
            
            for person in peopleInSameLevel {
                
                let view = Bundle.main.loadNibNamed("PeopleView", owner: self, options: nil)?.first as! PeopleView

                view.frame.size = CGSize(width: _peopleNodeWidth, height: _peopleNodeHeight)
            
                
                if person.maxX != 0 {
                    view.frame.origin.x = person.maxX - _peopleNodeWidth - (_nodeHorizontalSpace / 2)
                }
                else {
                    view.frame.origin.x = maxX + _nodeHorizontalSpace
                }
                
                if person.fatherId != currentFatherId && currentFatherId != 0 {
                    view.frame.origin.x = maxX + 2*_peopleNodeWidth
                }
                
                if view.frame.origin.x < 0 {
                    let space = (_defaultPaddingLeft - view.frame.origin.x)
                    view.frame.origin.x += space
                    for otherView in self.peopleViews {
                        otherView.frame.origin.x += space
                    }
                    
                    for line in self.lines {
                        line.position = CGPoint(x:line.position.x + space, y:line.position.y)
                    }
                }
                
                view.frame.origin.y = _defaultPaddingTop + CGFloat(i)*(_peopleNodeHeight + _nodeVerticalSpace)
                
                
                view.clipsToBounds = true
                view.layer.cornerRadius = 8

                view.people = person
                view.delegate = self
                
                let imageView = UIImageView()
                if let url = URL(string: person.imageUrl) {
                    
                    
                    imageView.kf.setImage(with: url, placeholder: UIImage(named: "male"), options: [.cacheOriginalImage], progressBlock: { receivedSize, totalSize in
                        // Progress updated
                    }, completionHandler: { result in
                        if let image = imageView.image {
                            view.img_avatar.image = image
                        }
                    })
                    
                } else {
                    view.img_avatar.image = UIImage(named: "male")!
                }

                view.lbl_name.text = person.firstName + " " + person.lastName
                view.lbl_birthday.text = person.birthday
                view.lbl_name.font = UIFont(name: "Helvetica-Bold", size: 4)
                view.lbl_birthday.font = UIFont(name: "Helvetica", size: 4)
                view.constraint_height_avatar.constant = 25
                view.setupView()
                if person.gender == GENDER_ID.MALE.rawValue {
                    view.backgroundColor = ColorUtils.male_color()
                }
                else {
                    view.backgroundColor = ColorUtils.female_color()
                }
                

                self.view_canvas.addSubview(view)
                self.peopleViews.append(view)

                
                if person.spouse.count > 0 {
                    addSpouseView(rootPeople: person, newPeople: getSpouse(people: person))
                    maxX = view.frame.maxX + _peopleNodeWidth + _nodeHorizontalSpace
                }
                else {
                    maxX = view.frame.maxX
                }
              
                if currentFatherId == 0 {
                    currentFatherId = person.fatherId
                    
                    if getFather(people: person).fatherId == 0 && getFather(people: person).motherId == 0
                                && getMother(people: person).fatherId != 0 && getMother(people: person).motherId != 0 {
                        getMother(people: person).firstChildMaxX = view.frame.maxX
                    }
                    else {
                        getFather(people: person).firstChildMaxX = view.frame.maxX
                    }
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
                        
                        if getFather(people: siblings[0]).fatherId == 0 && getFather(people: siblings[0]).motherId == 0
                                    && getMother(people: siblings[0]).fatherId != 0 && getMother(people: siblings[0]).motherId != 0 {
                            getMother(people: siblings[0]).maxX = centerX
                        }
                        else {
                            getFather(people: siblings[0]).maxX = centerX
                        }
                        
                        
                        
                        let line = drawLineFromPoint(start: CGPoint(x: centerX, y: firstSiblingMinY - _siblingsLineHeight), toPoint: CGPoint(x: centerX, y: firstSiblingMinY - _nodeVerticalSpace - _peopleNodeHeight/2), ofColor: .black, inView: view_canvas)
                        lines.append(line)
                        
                    }
                    else {
                        let childView = getPeopleView(people: siblings[0])
                        
                        if getFather(people: siblings[0]).fatherId == 0 && getFather(people: siblings[0]).motherId == 0
                                    && getMother(people: siblings[0]).fatherId != 0 && getMother(people: siblings[0]).motherId != 0 {
                            getMother(people: siblings[0]).maxX = childView.frame.maxX
                        }
                        else {
                            getFather(people: siblings[0]).maxX = childView.frame.maxX
                        }
                        
                        let line = drawLineFromPoint(start: CGPoint(x: childView.centerX(), y: childView.frame.minY), toPoint: CGPoint(x: childView.centerX(), y: childView.frame.minY - _nodeVerticalSpace - _peopleNodeHeight/2), ofColor: .black, inView: view_canvas)
                        lines.append(line)
                    }
                    
                    
                    siblings.removeAll()
                    siblings.append(person)
                    if getFather(people: person).fatherId == 0 && getFather(people: person).motherId == 0
                                && getMother(people: person).fatherId != 0 && getMother(people: person).motherId != 0 {
                        getMother(people: person).firstChildMaxX = view.frame.maxX
                    }
                    else {
                        getFather(people: person).firstChildMaxX = view.frame.maxX
                    }
                    currentFatherId = person.fatherId
                }
                
                if peopleInSameLevel.last?.id == person.id && person.fatherId != 0 {
                    siblings.append(person)
                    
                    if siblings.count > 1 {
                        drawSiblingsLine(siblings: siblings)
                        
                        
                        let firstSiblingView = getPeopleView(people: siblings.first!)
                        let lastSiblingView = getPeopleView(people: siblings.last!)
                        
                        let firstSiblingMinX = firstSiblingView.frame.minX
                        let firstSiblingMinY = firstSiblingView.frame.minY
                        let lastSiblingMinX = lastSiblingView.frame.minX
                        
                        let centerX = (firstSiblingMinX + (_peopleNodeWidth / 2) + lastSiblingMinX + (_peopleNodeWidth / 2)) / 2
                        
                        if getFather(people: siblings[0]).fatherId == 0 && getFather(people: siblings[0]).motherId == 0
                                    && getMother(people: siblings[0]).fatherId != 0 && getMother(people: siblings[0]).motherId != 0 {
                            getMother(people: siblings[0]).maxX = centerX
                        }
                        else {
                            getFather(people: siblings[0]).maxX = centerX
                        }
                        
                        let line = drawLineFromPoint(start: CGPoint(x: centerX, y: firstSiblingMinY - _siblingsLineHeight), toPoint: CGPoint(x: centerX, y: firstSiblingMinY - _nodeVerticalSpace - _peopleNodeHeight/2), ofColor: .black, inView: view_canvas)
                        lines.append(line)
                        
                    }
                    else {
                        let childView = getPeopleView(people: siblings[0])
                        
                        
                        if getFather(people: siblings[0]).fatherId == 0 && getFather(people: siblings[0]).motherId == 0
                                    && getMother(people: siblings[0]).fatherId != 0 && getMother(people: siblings[0]).motherId != 0 {
                            getMother(people: siblings[0]).maxX = childView.frame.maxX
                        }
                        else {
                            getFather(people: siblings[0]).maxX = childView.frame.maxX
                        }
                        
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
    
    func getTreeInfo(){
        
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Please wait..."
        hud.show(in: self.view)
        
        ResAPI.sharedInstance.getFamilyTreeInfo(treeId: treeId, { (data, message) -> Void in
           
            switch message {
            case "SUCCESS":
                if(data != nil){
                    
                    let response:ResResponse = data as! ResResponse

                    if let treeInfo = Mapper<FamilyTree>().map(JSONObject: response.data) {
                        self.people.removeAll()
                        self.people = treeInfo.people
                        
                        
                        for person in self.people {
                            let dateFormatter = DateFormatter()
                            dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
                            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                            let date = dateFormatter.date(from: person.birthday)
                            dateFormatter.dateFormat = "dd/MM/yyyy"
                            person.birthday = dateFormatter.string(from: date ?? Date())
                        }
                        
                        for person in self.people {
                            if person.fatherId == 0 && person.gender == GENDER_ID.MALE.rawValue {
                                self.rootPeople = person
                                break
                            }
                        }
                        
                        for item in self.peopleViews {
                            item.removeFromSuperview()
                        }
                        for item in self.lines {
                            item.removeFromSuperlayer()
                        }
                        self.peopleViews.removeAll()
                        self.lines.removeAll()
                        self.renderTree()
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
                self.getTreeInfo()
            case "NOTFOUND":
                Loaf.init("Request not found", state: .error, location: .bottom, presentingDirection: .left, dismissingDirection: .vertical, sender: self).show(.custom(2.5), completionHandler: nil)
            case "DATA":
                Loaf.init("Data error", state: .error, location: .bottom, presentingDirection: .left, dismissingDirection: .vertical, sender: self).show(.custom(2.5), completionHandler: nil)
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
    
    func addChild(child:People){
        
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Please wait..."
        hud.show(in: self.view)
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let date = dateFormatter.date(from: child.birthday)
        dateFormatter.dateFormat = "yyyy-MM-ddThh:mm:ss.s+zzzzzz"
        child.birthday = dateFormatter.string(from: date!)
        
        ResAPI.sharedInstance.addChild(child: child,  { (data, message) -> Void in
            
            switch message {
            case "SUCCESS":
                self.getTreeInfo()
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
                self.addChild(child: child)
            case "NOTFOUND":
                Loaf.init("Request not found", state: .error, location: .bottom, presentingDirection: .left, dismissingDirection: .vertical, sender: self).show(.custom(2.5), completionHandler: nil)
            case "DATA":
                Loaf.init("Data error", state: .error, location: .bottom, presentingDirection: .left, dismissingDirection: .vertical, sender: self).show(.custom(2.5), completionHandler: nil)
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

    func addSpouse(spouse:People, relativePeopleId:Int){
        
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Please wait..."
        hud.show(in: self.view)
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let date = dateFormatter.date(from: spouse.birthday)
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        spouse.birthday = dateFormatter.string(from: date!)
        
        ResAPI.sharedInstance.addSpouse(spouse: spouse, relativePeopleId: relativePeopleId, { (data, message) -> Void in
            
            switch message {
            case "SUCCESS":
                self.getTreeInfo()
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
                self.addSpouse(spouse: spouse, relativePeopleId: relativePeopleId)
            case "NOTFOUND":
                Loaf.init("Request not found", state: .error, location: .bottom, presentingDirection: .left, dismissingDirection: .vertical, sender: self).show(.custom(2.5), completionHandler: nil)
            case "DATA":
                Loaf.init("Data error", state: .error, location: .bottom, presentingDirection: .left, dismissingDirection: .vertical, sender: self).show(.custom(2.5), completionHandler: nil)
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
    
    func addParent(parent:People, relativePeopleId:Int){
        
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Please wait..."
        hud.show(in: self.view)
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let date = dateFormatter.date(from: parent.birthday)
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        parent.birthday = dateFormatter.string(from: date!)
        
        ResAPI.sharedInstance.addParent(parent: parent, relativePeopleId: relativePeopleId, { (data, message) -> Void in
            
            switch message {
            case "SUCCESS":
                self.getTreeInfo()
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
                self.addParent(parent: parent, relativePeopleId: relativePeopleId)
            case "NOTFOUND":
                Loaf.init("Request not found", state: .error, location: .bottom, presentingDirection: .left, dismissingDirection: .vertical, sender: self).show(.custom(2.5), completionHandler: nil)
            case "DATA":
                Loaf.init("Data error", state: .error, location: .bottom, presentingDirection: .left, dismissingDirection: .vertical, sender: self).show(.custom(2.5), completionHandler: nil)
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
    
    func editNode(person:People){
        
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Please wait..."
        hud.show(in: self.view)
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let date = dateFormatter.date(from: person.birthday)
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        person.birthday = dateFormatter.string(from: date!)
        
        ResAPI.sharedInstance.updateNode(person: person, { (data, message) -> Void in
           
            switch message {
            case "SUCCESS":
                self.getTreeInfo()
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
                self.editNode(person: person)
            case "NOTFOUND":
                Loaf.init("Request not found", state: .error, location: .bottom, presentingDirection: .left, dismissingDirection: .vertical, sender: self).show(.custom(2.5), completionHandler: nil)
            case "DATA":
                Loaf.init("Data error", state: .error, location: .bottom, presentingDirection: .left, dismissingDirection: .vertical, sender: self).show(.custom(2.5), completionHandler: nil)
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
    
    func deleteNode(personId:Int){
        
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Please wait..."
        hud.show(in: self.view)
        

        
        ResAPI.sharedInstance.deleteNode(personId: personId, { (data, message) -> Void in
          
            switch message {
            case "SUCCESS":
                self.getTreeInfo()
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
                self.deleteNode(personId: personId)
            case "NOTFOUND":
                Loaf.init("Request not found", state: .error, location: .bottom, presentingDirection: .left, dismissingDirection: .vertical, sender: self).show(.custom(2.5), completionHandler: nil)
            case "DATA":
                Loaf.init("Data error", state: .error, location: .bottom, presentingDirection: .left, dismissingDirection: .vertical, sender: self).show(.custom(2.5), completionHandler: nil)
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
}

extension EditFamilyTreeViewController : AddPeopleDelegate {
    func addPeople(people:People, relationshipType:Int, relativePersonId:Int, image:UIImage) {
        
        let item = image
        let parameters = [String:AnyObject]()
        let imageData: Data = item.jpegData(compressionQuality: 0.5)!
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-ddHH:mm:ss"
        let result = formatter.string(from: date)
        let randomString = String((0..<15).map{ _ in result.randomElement()! })
        let file_name = String(format: "avatar_%@.%@", randomString, "jpg")
        
        
        uploadPhotoToServer(parameters: parameters, imageData: imageData, fileName: file_name) { (url) in
            if relationshipType == 1 {
                people.imageUrl = url
                self.addChild(child: people)
            }
            else if relationshipType == 0 {
                people.imageUrl = url
                self.addSpouse(spouse: people, relativePeopleId: relativePersonId)
            }
            else {
                people.imageUrl = url
                self.addParent(parent: people, relativePeopleId: relativePersonId)
            }
        }
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
        
        let listName = ["Edit node", "Add node", "Delete node"]
        let listIcon = ["editNode", "addNode", "close"]
       
        let controller = ArrayChoiceReportViewController(Direction.allValues)
       
        controller.people = people
        controller.list_icons = listIcon
        controller.listString = listName
        controller.preferredContentSize = CGSize(width: 120, height: 135)
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
            editPeopleViewController?.person = people
            navigationController?.pushViewController(editPeopleViewController!, animated: true)
        }
        else if pos == 1 {
            

                let addPeopleViewController:AddPeopleViewController?
                addPeopleViewController = UIStoryboard.addPeopleViewController()
                addPeopleViewController?.relativePerson = people
                addPeopleViewController?.delegate = self
                navigationController?.pushViewController(addPeopleViewController!, animated: true)

        }
        else {
            
            if people.spouse.count == 0 && getChildren(people: people).count == 0
                || people.spouse.count == 0 && people.fatherId == 0 && people.motherId == 0 && getChildren(people: people).count <= 1
                || people.spouse.count == 1 && people.fatherId == 0 && people.motherId == 0
            {
                self.selectedDeletePersonId = people.id
                let dialogConfirmViewController:DialogConfirmViewController?
                dialogConfirmViewController = UIStoryboard.dialogConfirmViewController()
                dialogConfirmViewController?.delegate = self
                dialogConfirmViewController?.dialogTitle = "Confirm"
                dialogConfirmViewController?.content = "Are you sure to delete this node?"
                self.present(dialogConfirmViewController!, animated: false, completion: nil)
            }
            else {
                Loaf.init("You cannot delete this node!", state: .info, location: .bottom, presentingDirection: .left, dismissingDirection: .vertical, sender: self).show(.custom(3), completionHandler: nil)
            }
           
        }
    }
}

extension EditFamilyTreeViewController : DialogConfirmDelegate {
    func accept() {
        deleteNode(personId: selectedDeletePersonId)
    }
    
    func deny() {
        
    }
}

extension EditFamilyTreeViewController : EditPeopleDelegate {
    func editPeople(people: People, image: UIImage, hasChangeAvatar:Bool) {
        
        if hasChangeAvatar == false {
            self.editNode(person: people)
        }
        else {
            let item = image
            let parameters = [String:AnyObject]()
            let imageData: Data = item.jpegData(compressionQuality: 0.5)!
            let date = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-ddHH:mm:ss"
            let result = formatter.string(from: date)
            let randomString = String((0..<15).map{ _ in result.randomElement()! })
            let file_name = String(format: "avatar_%@.%@", randomString, "jpg")
            
            
            uploadPhotoToServer(parameters: parameters, imageData: imageData, fileName: file_name) { (url) in
                people.imageUrl = url
                self.editNode(person: people)
            }
        }
    }
}

