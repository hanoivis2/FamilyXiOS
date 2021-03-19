//
//  TestZoomViewController.swift
//  FamilyX
//
//  Created by Gia Huy on 10/03/2021.
//

import UIKit

class EditFamilyTreeViewController : UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var view_canvas: UIView!
    @IBOutlet weak var constraint_view_canvas_height: NSLayoutConstraint!
    @IBOutlet weak var constraint_view_canvas_width: NSLayoutConstraint!
    
    var zoomLevel = 1
    var peopleCount = 0
    
    var peopleView = [PeopleView]()
    var lines = [CAShapeLayer]()

    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    
    
    @IBAction func btn_zoom_in(_ sender: Any) {
//        if zoomLevel < 4 {

//
//            for item in self.peopleView {
//                item.removeFromSuperview()
//            }
//
//            for item in self.lines {
//                item.removeFromSuperlayer()
//            }
//
//            for item in self.peopleView {
//                item.frame.size = CGSize(width: 100, height: 200)
//                item.frame.origin.x = CGFloat((peopleCount - 1)*150*2)
//                view_canvas.addSubview(item)
//            }
//
//            let line = drawLineFromPoint(start: CGPoint(x:peopleView[peopleCount - 2].frame.maxX, y:peopleView[peopleCount - 2].frame.maxY / 2), toPoint: CGPoint(x:peopleView[peopleCount - 1].frame.minX, y:peopleView[peopleCount - 1].frame.maxY / 2), ofColor: .black, inView: view_canvas)
//            lines.append(line)
//
//            zoomLevel += 1
//        }
        
        view_canvas.transform = CGAffineTransform(scaleX: 2, y: 2)
        view_canvas.frame.origin.x = 0
        view_canvas.frame.origin.y = 0
    }
    
    @IBAction func btn_zoom_out(_ sender: Any) {
//        if zoomLevel > 1 {
//            constraint_view_canvas_height.constant /= 2
//            constraint_view_canvas_width.constant /= 2
//
//            view_canvas.contentScaleFactor = 0.5
//
//            zoomLevel -= 1
//        }
        view_canvas.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        view_canvas.frame.origin.x = 0
        view_canvas.frame.origin.y = 0
    }
    
    @IBAction func btn_add_node(_ sender: Any) {
        
        
        let addPeopleViewController:AddPeopleViewController?
        addPeopleViewController = UIStoryboard.addPeopleViewController()
        addPeopleViewController?.delegate = self
        present(addPeopleViewController!, animated: true, completion: nil)
    }
}

extension EditFamilyTreeViewController : AddPeopleDelegate {
    func addPeople(name: String, birthday: String) {
        
        peopleCount += 1
     
        let view = Bundle.main.loadNibNamed("PeopleView", owner: self, options: nil)?.first as! PeopleView
        view.lbl_name.text = name
        view.lbl_birthday.text = birthday
        view.frame.size = CGSize(width: 100, height: 200)
        view.frame.origin.x = CGFloat((peopleCount - 1)*150)
        
        self.view_canvas.addSubview(view)
        self.peopleView.append(view)
        
        if peopleView.count > 1 {
            
            let line = drawLineFromPoint(start: CGPoint(x:peopleView[peopleCount - 2].frame.maxX, y:peopleView[peopleCount - 2].frame.maxY / 2), toPoint: CGPoint(x:peopleView[peopleCount - 1].frame.minX, y:peopleView[peopleCount - 1].frame.maxY / 2), ofColor: .black, inView: view_canvas)
            lines.append(line)
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
}

