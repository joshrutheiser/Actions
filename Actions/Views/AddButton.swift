//
//  AddButton.swift
//  Action
//
//  Created by Josh Rutheiser on 5/31/22.
//

import Foundation
import UIKit

class AddButton: UIButton {
    
    init(_ view: UIView) {
        super.init(frame: .null)
        setup(view)
    }
    
    required init?(coder: NSCoder) {
        fatalError("unsupported")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.shadowColor = UIColor(named: "AddButtonShadow")!.cgColor
    }

    func setup(_ view: UIView) {
        let x = view.frame.width - 60 - 20
        let y = view.frame.height - 60 - 25
        frame = CGRect(x: x, y: y, width: 60, height: 60)

        layer.cornerRadius = 0.5 * bounds.size.width
        autoresizingMask = [.flexibleTopMargin, .flexibleRightMargin]
        backgroundColor = UIColor(named: "AddButton")
        
        let config = UIImage.SymbolConfiguration(
            pointSize: 22,
            weight: .regular,
            scale: .medium
        )
        let plus = UIImage(systemName: "plus", withConfiguration: config)
        setImage(plus, for: .normal)
        setImage(plus, for: .highlighted)
        tintColor = .white
        
        layer.shadowRadius = 3
        layer.shadowColor = UIColor(named: "AddButtonShadow")!.cgColor
        layer.shadowOpacity = 0.9
        layer.shadowOffset = CGSize.zero
        layer.zPosition = 1
    }
}
