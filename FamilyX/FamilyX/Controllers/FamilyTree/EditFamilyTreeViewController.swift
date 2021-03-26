//
//  TestZoomViewController.swift
//  FamilyX
//
//  Created by Gia Huy on 10/03/2021.
//

import UIKit

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
    var peopleCount = 0
    
    var peopleView = [PeopleView]()
    var lines = [CAShapeLayer]()

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
    
    
    @IBAction func btn_zoom_in(_ sender: Any) {
        if zoomLevel < 4 {
            zoomLevel += 1
        }
    }
    
    @IBAction func btn_zoom_out(_ sender: Any) {
        if zoomLevel > 2 {
            zoomLevel -= 1
        }
    }
    
    @IBAction func btn_add_node(_ sender: Any) {
        let addPeopleViewController:AddPeopleViewController?
        addPeopleViewController = UIStoryboard.addPeopleViewController()
        addPeopleViewController?.delegate = self
//        present(addPeopleViewController!, animated: true, completion: nil)
        navigationController?.pushViewController(addPeopleViewController!, animated: true)
    }
}

extension EditFamilyTreeViewController : AddPeopleDelegate {
    func addPeople(name: String, birthday: String, gender: Int, phone: String, avatar: UIImage) {
        view_canvas.transform = CGAffineTransform(scaleX: 2, y: 2)
        
        
        peopleCount += 1
     
        let view = Bundle.main.loadNibNamed("PeopleView", owner: self, options: nil)?.first as! PeopleView
        view.lbl_name.text = name
        view.lbl_birthday.text = birthday
        view.lbl_phone.text = phone
        view.frame.size = CGSize(width: 40, height: 50)
        view.frame.origin.x = CGFloat((peopleCount - 1)*50)
        
        view.frame.origin.x += 20
        view.frame.origin.y = 20
        
        view.clipsToBounds = true
        view.layer.cornerRadius = 8
        
        view.lbl_name.font = UIFont(name: "Helvetica", size: 4)
        view.lbl_birthday.font = UIFont(name: "Helvetica", size: 4)
        view.constraint_height_avatar.constant = 25
        view.img_avatar.image = avatar
        if gender == GENDER_ID.MALE.rawValue {
            view.backgroundColor = ColorUtils.male_color()
        }
        else {
            view.backgroundColor = ColorUtils.female_color()
        }
        
        self.view_canvas.addSubview(view)
        self.peopleView.append(view)
        
        if peopleView.count > 1 {
            
            let line = drawLineFromPoint(start: CGPoint(x:peopleView[peopleCount - 2].frame.maxX, y:peopleView[peopleCount - 2].frame.maxY / 2), toPoint: CGPoint(x:peopleView[peopleCount - 1].frame.minX, y:peopleView[peopleCount - 1].frame.maxY / 2), ofColor: .black, inView: view_canvas)
            lines.append(line)
        }
        
        view_canvas.frame.origin.x = 0
        view_canvas.frame.origin.y = 0
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
}

