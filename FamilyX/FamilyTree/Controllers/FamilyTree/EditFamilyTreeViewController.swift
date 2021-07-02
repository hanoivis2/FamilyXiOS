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

protocol EditFamilyTreeViewControllerDelegate {
    func reload()
    func logoutFromEditFamilyTree()
}

class EditFamilyTreeViewController : UIViewController, NavigationControllerCustomDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var view_canvas: UIView!
    @IBOutlet weak var constraint_view_canvas_height: NSLayoutConstraint!
    @IBOutlet weak var constraint_view_canvas_width: NSLayoutConstraint!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var view_search: UIView!
    @IBOutlet weak var tbl_searchResult: UITableView!
    @IBOutlet weak var btn_close_search: UIButton!
    @IBOutlet weak var constraint_left_searchbar: NSLayoutConstraint!
    
    var delegate:EditFamilyTreeViewControllerDelegate?
    
    var zoomLevel = 1 {
        didSet {
            let point = CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2)
            view_canvas.transform = CGAffineTransform(scaleX: zoomScale[zoomLevel - 1], y: zoomScale[zoomLevel - 1])
            view_canvas.frame.origin.x = 0
            view_canvas.frame.origin.y = 0
            scrollView.setContentOffset(point, animated: true)
        }
    }
    var zoomScale:[CGFloat] = [1,2,3,4]
    var peopleViews = [PeopleView]()
    var peopleViewsFilter = [PeopleView]()
    var focusView = PeopleView()
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
        
        view_search.isHidden = true
        btn_close_search.isHidden = true
        constraint_left_searchbar.constant = 0
        searchBar.backgroundImage = UIImage()
        searchBar.addDoneButtonOnKeyboard()
        tbl_searchResult.separatorStyle = .none
        
        getTreeInfo()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let navigationControllerCustom : NavigationControllerCustom = self.navigationController as! NavigationControllerCustom
        navigationControllerCustom.setUpNavigationBar(self, hideBackButton: false, hideAddButton: true, title: "FAMILY TREE")
        navigationControllerCustom.touchTarget = self
        navigationControllerCustom.navigationBar.barTintColor = ColorUtils.toolbar()
        navigationControllerCustom.navigationBar.isHidden = false
        
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.navigationController?.navigationItem.backBarButtonItem?.isEnabled = false
        
    }
    
    func backTap() {
        navigationController?.popViewController(animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        
    }
    
    @IBAction func btn_closeSearch(_ sender: Any) {
        self.dismissKeyboard()
        self.searchBar.text = ""
        self.view_search.isHidden = true
        constraint_left_searchbar.constant = 0
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
            self.btn_close_search.isHidden = true
        }
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
    
    func getPeopleView(person:People) -> PeopleView {
        for view in self.peopleViews {
            if view.people.id == person.id {
                return view
            }
        }
        return PeopleView()
    }
    
    func getChildrenAmount(person:People) -> Int {
        var count = 0
        for item in  people {
            if item.fatherId == person.id || item.motherId == person.id {
                count += 1
            }
        }
        return count
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
        var firstSiblingView = getPeopleView(person: siblings.first!)
        var lastSiblingView = getPeopleView(person: siblings.last!)
        
        var minMaxX = firstSiblingView.frame.maxX
        var maxMaxX = firstSiblingView.frame.maxX
        
        for item in siblings {
            let tempView = getPeopleView(person: item)
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
            let firstSiblingView = getPeopleView(person: item)
            
            let firstSiblingMinX = firstSiblingView.frame.minX
            let firstSiblingMinY = firstSiblingView.frame.minY
            let line = drawLineFromPoint(start: CGPoint(x: firstSiblingMinX + (_peopleNodeWidth / 2), y: firstSiblingMinY), toPoint: CGPoint(x: firstSiblingMinX + (_peopleNodeWidth / 2), y: firstSiblingMinY - _siblingsLineHeight), ofColor: .black, inView: view_canvas)
            lines.append(line)
        }
        
        let line3 = drawLineFromPoint(start: CGPoint(x: firstSiblingMinX + (_peopleNodeWidth / 2), y: firstSiblingMinY - _siblingsLineHeight), toPoint: CGPoint(x: lastSiblingMinX + (_peopleNodeWidth / 2), y: firstSiblingMinY - _siblingsLineHeight), ofColor: .black, inView: view_canvas)
        lines.append(line3)
    }
    

    
    func addSpouseView(rootPeople:People, newPeople:People) {
        
        let relativePeopleNode = getPeopleView(person: rootPeople)

        let view = Bundle.main.loadNibNamed("PeopleView", owner: self, options: nil)?.first as! PeopleView

        view.frame.size = CGSize(width: _peopleNodeWidth, height: _peopleNodeHeight)
        view.frame.origin.x = relativePeopleNode.frame.maxX + _nodeHorizontalSpace
        view.frame.origin.y = relativePeopleNode.frame.origin.y
        view.clipsToBounds = true
        view.layer.cornerRadius = 8

        view.people = newPeople
        view.delegate = self
        
        let imageView = UIImageView()
        var imageHolder = UIImage()
        if view.people.gender == GENDER_ID.MALE.rawValue {
            imageHolder = UIImage(named: "male")!
        }
        else {
            imageHolder = UIImage(named: "female")!
        }
        if let url = URL(string: newPeople.imageUrl) {
            
            
            imageView.kf.setImage(with: url, placeholder: imageHolder, options: [.cacheOriginalImage], progressBlock: { receivedSize, totalSize in
                // Progress updated
            }, completionHandler: { result in
                if let image = imageView.image {
                    view.img_avatar.image = image
                }
            })
            
        } else {
            
            view.img_avatar.image = imageHolder
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
        
        tbl_searchResult.reloadData()
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
                if calcutlateSpaceToFirstPeople(people: person, firstPeople: rootPeople) == i
                    && (person.fatherId != 0 || person.motherId != 0 || person.id == rootPeople.id) {
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
                    
                    if person.spouse.count > 0 {
                        
                        if getChildrenAmount(person: person) > 1 {
                            view.frame.origin.x = person.maxX - _peopleNodeWidth - (_nodeHorizontalSpace / 2)
                        }
                        else {
                            view.frame.origin.x = person.maxX - (_peopleNodeWidth * 3/2) - (_nodeHorizontalSpace / 2)
                        }
                        
                    }
                    else {
                        view.frame.origin.x = person.maxX - (_peopleNodeWidth)
                    }
                    
                }
                else {
                    view.frame.origin.x = maxX + _nodeHorizontalSpace
                }
                
                if !(person.fatherId == currentFatherId || person.motherId == currentFatherId || currentFatherId == 0) {
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
                var imageHolder = UIImage()
                if view.people.gender == GENDER_ID.MALE.rawValue {
                    imageHolder = UIImage(named: "male")!
                }
                else {
                    imageHolder = UIImage(named: "female")!
                }
                if let url = URL(string: view.people.imageUrl) {
                    
                    
                    imageView.kf.setImage(with: url, placeholder: imageHolder, options: [.cacheOriginalImage], progressBlock: { receivedSize, totalSize in
                        // Progress updated
                    }, completionHandler: { result in
                        if let image = imageView.image {
                            view.img_avatar.image = image
                        }
                    })
                    
                } else {
                    
                    view.img_avatar.image = imageHolder
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
                
                let father = getFather(people: person)
                let mother = getMother(people: person)

                
                if person.spouse.count > 0 {
                    addSpouseView(rootPeople: person, newPeople: getSpouse(people: person))
                    maxX = view.frame.maxX + _peopleNodeWidth + _nodeHorizontalSpace
                }
                else {
                    maxX = view.frame.maxX
                }
              
                if currentFatherId == 0 {
                    
                    //Nếu không có cha hoặc cha là con rể
                    if (father.fatherId == 0 && father.motherId == 0
                        && mother.fatherId != 0 && mother.motherId != 0
                        && father.id != rootPeople.id )
                        || (person.fatherId == 0 && person.motherId != 0) {
                        
                        getMother(people: person).firstChildMaxX = view.frame.maxX
                        currentFatherId = person.motherId
                    }
                    else {
                        getFather(people: person).firstChildMaxX = view.frame.maxX
                        currentFatherId = person.fatherId
                    }
                    siblings.append(person)
                }
                //Nếu có cha và cha không phải con rể thì dùng id của cha
                //Ngược lại dùng id của mẹ
                else if (person.fatherId != 0) && (father.fatherId != 0 && father.motherId != 0 || father.id == rootPeople.id) && (currentFatherId != person.fatherId)
                    || (person.fatherId == 0 && person.motherId != 0 && currentFatherId != person .motherId) {
                    
                    if siblings.count > 1 {
                        drawSiblingsLine(siblings: siblings)
                        
                        
                        let firstSiblingView = getPeopleView(person: siblings.first!)
                        let lastSiblingView = getPeopleView(person: siblings.last!)
                        
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
                        let childView = getPeopleView(person: siblings[0])
                        let father = getFather(people: siblings[0])
                        let mother = getMother(people: siblings[0])
                        //Nếu không có cha hoặc cha là con rể
                        if (father.fatherId == 0 && father.motherId == 0
                            && mother.fatherId != 0 && mother.motherId != 0
                            && father.id != rootPeople.id )
                            || (person.fatherId == 0 && person.motherId != 0) {
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
                        currentFatherId = person.motherId
                    }
                    else {
                        getFather(people: person).firstChildMaxX = view.frame.maxX
                        currentFatherId = person.fatherId
                    }
                    
                }
                else {
                    siblings.append(person)
                }
                
                if (peopleInSameLevel.last?.id == person.id)
                    && (person.fatherId != 0 || person.motherId != 0) {
                    
                    if !siblings.contains(where: { people in return people.id == person.id }) {
                        siblings.append(person)
                    }
                    
                    
                    if siblings.count > 1 {
                        drawSiblingsLine(siblings: siblings)
                        
                        
                        let firstSiblingView = getPeopleView(person: siblings.first!)
                        let lastSiblingView = getPeopleView(person: siblings.last!)
                        
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
                        let childView = getPeopleView(person: siblings[0])
                        
                        let father = getFather(people: siblings[0])
                        let mother = getMother(people: siblings[0])
                        //Nếu không có cha hoặc cha là con rể
                        if (father.fatherId == 0 && father.motherId == 0
                            && mother.fatherId != 0 && mother.motherId != 0
                            && father.id != rootPeople.id )
                            || (person.fatherId == 0 && person.motherId != 0) {
                            getMother(people: siblings[0]).maxX = childView.frame.maxX
                        }
                        else {
                            getFather(people: siblings[0]).maxX = childView.frame.maxX
                        }
                        
                        let line = drawLineFromPoint(start: CGPoint(x: childView.centerX(), y: childView.frame.minY), toPoint: CGPoint(x: childView.centerX(), y: childView.frame.minY - _nodeVerticalSpace - _peopleNodeHeight/2), ofColor: .black, inView: view_canvas)
                        lines.append(line)
                    }
                    
                    siblings.removeAll()
                    currentFatherId = 0
                }
 
            }
        }
        
        view_canvas.frame.origin.x = 0
        view_canvas.frame.origin.y = 0
        view_canvas.reloadInputViews()
        self.peopleViewsFilter = self.peopleViews
        tbl_searchResult.reloadData()
        
        

    }

    func focusView(view:PeopleView) {
        let centerPointX = view.centerX()
        let centerPointY = view.centerY()
        var scrollPoint = CGPoint()
        
        if centerPointX < UIScreen.main.bounds.width / 2 {
            scrollPoint.x = 0
        }
        else if centerPointX > view_canvas.frame.width - (UIScreen.main.bounds.width / 2){
            scrollPoint.x = view_canvas.frame.width - UIScreen.main.bounds.width
        }
        else {
            scrollPoint.x = centerPointX - (UIScreen.main.bounds.width / 2)
        }
        
        if centerPointY < UIScreen.main.bounds.height / 2 {
            scrollPoint.y = 0
        }
        else if centerPointY > view_canvas.frame.height - (UIScreen.main.bounds.height / 2){
            scrollPoint.y = view_canvas.frame.height - UIScreen.main.bounds.height
        }
        else {
            scrollPoint.y = centerPointY - (UIScreen.main.bounds.height / 2)
        }
        
        zoomLevel = 1
        scrollView.setContentOffset(scrollPoint, animated: true)
        view.borderWidth = 1.5
        view.borderColor = .black
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
                            if person.fatherId == 0 && person.motherId == 0 {
                                if  person.spouse.count == 0 {
                                    self.rootPeople = person
                                    break
                                }
                                else {
                                    if person.spouse[0].fatherId == 0 && person.spouse[0].motherId == 0 {
                                        if person.gender == GENDER_ID.MALE.rawValue {
                                            self.rootPeople = person
                                            break
                                        }
                                    }
                                }
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
                        self.view_canvas.reloadInputViews()
                        self.renderTree()
                    }
                    
                }
            case "UNAUTHORIZED":
                self.delegate?.logoutFromEditFamilyTree()
            case "RECALL":
                self.getTreeInfo()
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
                self.delegate?.reload()
            case "UNAUTHORIZED":
                self.delegate?.logoutFromEditFamilyTree()
            case "RECALL":
                self.addChild(child: child)
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
                self.delegate?.reload()
            case "UNAUTHORIZED":
                self.delegate?.logoutFromEditFamilyTree()
            case "RECALL":
                self.addSpouse(spouse: spouse, relativePeopleId: relativePeopleId)
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
                self.delegate?.reload()
            case "UNAUTHORIZED":
                self.delegate?.logoutFromEditFamilyTree()
            case "RECALL":
                self.addParent(parent: parent, relativePeopleId: relativePeopleId)
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
                self.delegate?.reload()
            case "UNAUTHORIZED":
                self.delegate?.logoutFromEditFamilyTree()
            case "RECALL":
                self.editNode(person: person)
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
    
    func deleteNode(personId:Int){
        
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Please wait..."
        hud.show(in: self.view)
        

        
        ResAPI.sharedInstance.deleteNode(personId: personId, { (data, message) -> Void in
          
            switch message {
            case "SUCCESS":
                self.delegate?.reload()
            case "UNAUTHORIZED":
                self.delegate?.logoutFromEditFamilyTree()
            case "RECALL":
                self.deleteNode(personId: personId)
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
                if let url = res.data as? String {
                    completion!(url)
                }
                else {
                    completion!("")
                    Loaf.init("Your image is too large to upload, please try another by edit your node!", state: .warning, location: .bottom, presentingDirection: .left, dismissingDirection: .vertical, sender: self).show(.custom(5), completionHandler: nil)
                }
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
        var imageData: Data = item.pngData()!
        imageData = Utils.bestImageDataForUpload(data: imageData, item: item)
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
            
            if people.spouse.count == 0 && getChildrenAmount(person: people) > 0 {
                Loaf.init("You cannot add node this node!", state: .info, location: .bottom, presentingDirection: .left, dismissingDirection: .vertical, sender: self).show(.custom(3), completionHandler: nil)
            }
            else {
                let addPeopleViewController:AddPeopleViewController?
                addPeopleViewController = UIStoryboard.addPeopleViewController()
                addPeopleViewController?.relativePerson = people
                addPeopleViewController?.delegate = self
                navigationController?.pushViewController(addPeopleViewController!, animated: true)
            }
            

        }
        else {
            
            if people.spouse.count == 0 && getChildrenAmount(person: people) == 0
                || people.spouse.count == 0 && people.fatherId == 0 && people.motherId == 0 && getChildrenAmount(person: people) <= 1
                || people.spouse.count == 1 && people.fatherId == 0 && people.motherId == 0 && getChildrenAmount(person: people) <= 1
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
            var imageData: Data = item.pngData()!
            imageData = Utils.bestImageDataForUpload(data: imageData, item: item)
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

extension EditFamilyTreeViewController : UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.view_search.isHidden = false
        constraint_left_searchbar.constant = 50
        UIView.animate(withDuration: 0.3, delay: 0, options: .transitionCrossDissolve, animations: {
            self.view.layoutIfNeeded()
            
        },
        completion: {res in
            self.btn_close_search.isHidden = false
        })
        
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {

    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
       
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        self.searchBar.text = searchText
        self.peopleViewsFilter = self.searchBar.text!.lowercased().isEmpty ? peopleViews : peopleViews.filter { (item: PeopleView) -> Bool in

            return item.people.firstName.lowercased().range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
                || item.people.lastName.lowercased().range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
                || item.people.birthday.lowercased().range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
        }
        
        tbl_searchResult.reloadData()
    }
}

extension EditFamilyTreeViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return peopleViewsFilter.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserNodeInfoTableViewCell") as! UserNodeInfoTableViewCell
        
        let item = peopleViewsFilter[indexPath.row].people
        
        cell.lbl_name.text = item.firstName + " " + item.lastName
        cell.lbl_username.text = item.birthday
        cell.pos = indexPath.row
        cell.delegate = self
        
        let imageView = UIImageView()
        var imageHolder = UIImage()
        if item.gender == GENDER_ID.MALE.rawValue {
            imageHolder = UIImage(named: "male")!
        }
        else {
            imageHolder = UIImage(named: "female")!
        }
        if let url = URL(string: item.imageUrl) {
            
            
            imageView.kf.setImage(with: url, placeholder: imageHolder, options: [.cacheOriginalImage], progressBlock: { receivedSize, totalSize in
                // Progress updated
            }, completionHandler: { result in
                if let image = imageView.image {
                    cell.img_avatar.image = image
                }
            })
            
        } else {
            
            cell.img_avatar.image = imageHolder
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
}

extension EditFamilyTreeViewController : UserNodeInfoDelegate {
    func selectRow(at: Int) {
        focusView.borderWidth = 0
        focusView(view: peopleViewsFilter[at])
        self.dismissKeyboard()
        self.searchBar.text = ""
        self.view_search.isHidden = true
        self.btn_close_search.isHidden = true
        constraint_left_searchbar.constant = 0
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
            
        }
        focusView = peopleViewsFilter[at]
    }
}

protocol UserNodeInfoDelegate {
    func selectRow(at:Int)
}

class UserNodeInfoTableViewCell : UITableViewCell {
    
    @IBOutlet weak var img_avatar:UIImageView!
    @IBOutlet weak var lbl_name:UILabel!
    @IBOutlet weak var lbl_username:UILabel!
    
    var delegate:UserNodeInfoDelegate?
    var pos = 0
    
    @IBAction func btn_selectRow(_ sender:Any) {
        delegate?.selectRow(at: pos)
    }
    
}
