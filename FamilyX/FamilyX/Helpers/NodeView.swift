//
//  NodeView.swift
//  FamilyX
//
//  Created by Gia Huy on 19/03/2021.
//

import UIKit

class NodeView: UILabel {
    weak var containerView: UIView!

    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
}

private extension NodeView {
    func configure() {
        backgroundColor = UIColor.white
        layer.borderColor = UIColor.black.cgColor
        layer.borderWidth = 3
        textAlignment = .center
    }
}
