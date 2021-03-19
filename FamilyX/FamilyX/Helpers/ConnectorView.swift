//
//  ConnectorView.swift
//  FamilyX
//
//  Created by Gia Huy on 19/03/2021.
//

import UIKit

class ConnectorView: UIView {
    enum ConnectorType {
        case upperRightToLowerLeft
        case upperLeftToLowerRight
        case vertical
    }

    var connectorType: ConnectorType = .upperLeftToLowerRight { didSet { layoutIfNeeded() } }

    override class var layerClass: AnyClass { return CAShapeLayer.self }
    var shapeLayer: CAShapeLayer { return layer as! CAShapeLayer }

    convenience init(connectorType: ConnectorType) {
        self.init()
        self.connectorType = connectorType
    }

    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }

    override func layoutSubviews() {
        let path = UIBezierPath()

        switch connectorType {
        case .upperLeftToLowerRight:
            path.move(to: CGPoint(x: bounds.minX, y: bounds.minY))
            path.addLine(to: CGPoint(x: bounds.maxX, y: bounds.maxY))

        case .upperRightToLowerLeft:
            path.move(to: CGPoint(x: bounds.maxX, y: bounds.minY))
            path.addLine(to: CGPoint(x: bounds.minX, y: bounds.maxY))

        case .vertical:
            path.move(to: CGPoint(x: bounds.midX, y: bounds.minY))
            path.addLine(to: CGPoint(x: bounds.midX, y: bounds.maxY))
        }

        shapeLayer.path = path.cgPath
    }

}

private extension ConnectorView {
    func configure() {
        shapeLayer.lineWidth = 3
        shapeLayer.strokeColor = UIColor.black.cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
    }
}
