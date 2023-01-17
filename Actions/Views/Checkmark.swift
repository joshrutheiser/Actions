//
//  Checkmark.swift
//  Actions
//
//  Created by Josh Rutheiser on 1/13/23.
//

import Foundation
import UIKit

@IBDesignable
class Checkmark: UIButton {
    
    //MARK: - Setup
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setup()
    }
    
    func reset() {
        setup()
    }

    private func setup() {
        setImage(UIImage(systemName: "circle"), for: .normal)
    }
    
    //MARK: - Animate
    
    override func sendAction(_ action: Selector, to target: Any?, for event: UIEvent?) {
        animate() {
            super.sendAction(action, to: target, for: event)
        }
    }
    
    private func animate(_ handler: @escaping () -> Void) {
        let i = 0.5, a = i * 1/3, b = i * 2/3
        
        UIView.animateKeyframes(withDuration: i, delay: 0, options: .calculationModeCubic) {
            let generator = UIImpactFeedbackGenerator(style: .medium)

            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: a) {
                self.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
                generator.impactOccurred()
                self.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
            }
            UIView.addKeyframe(withRelativeStartTime: a, relativeDuration: b) {
                self.transform = CGAffineTransform(scaleX: 1, y: 1)
            }
        } completion: { complete in
            handler()
        }
    }
}
