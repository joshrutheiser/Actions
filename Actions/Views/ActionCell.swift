//
//  ActionCell.swift
//  Actions
//
//  Created by Josh Rutheiser on 1/8/23.
//

import UIKit

protocol ActionCellDelegate {
    func handleEditEvent(_ actionId: String, _ event: EditEvent)
}

//MARK: - Action Cell

class ActionCell: UITableViewCell {
    @IBOutlet weak var checkmark: UIButton!
    @IBOutlet weak var editText: EditableText!
    var id: String?
    var delegate: ActionCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        editText.translatesAutoresizingMaskIntoConstraints = false
        editText.editDelegate = self
    }

    override func prepareForReuse() {
        checkmark.setImage(UIImage(systemName: "circle"), for: .normal)
        editText.reset()
        id = nil
        delegate = nil
    }
    
    func setText(_ text: String) {
        editText.text = text
    }
    
    func getText() -> String {
        return editText.text.trim()
    }
    
    func stopEditing() {
        editText.stopEditing()
    }
    
    func startEditing(_ index: Int) {
        editText.startEditing(index)
    }
}

//MARK: - Send Event

extension ActionCell: EditableTextDelegate {
    func editEvent(_ event: EditEvent) {
        guard let id = id else { return }
        delegate?.handleEditEvent(id, event)
    }
}

//MARK: - Complete

extension ActionCell {
    
    @IBAction func completePressed(_ sender: UIButton) {
        guard let id = id else { return }
        
        let i = 0.5, a = i * 1/3, b = i * 2/3
        UIView.animateKeyframes(withDuration: i, delay: 0, options: .calculationModeCubic) {
            let generator = UIImpactFeedbackGenerator(style: .medium)

            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: a) {
                self.checkmark.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
                generator.impactOccurred()
                self.checkmark.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
            }
            UIView.addKeyframe(withRelativeStartTime: a, relativeDuration: b) {
                self.checkmark.transform = CGAffineTransform(scaleX: 1, y: 1)
            }
        } completion: { complete in
            self.delegate?.handleEditEvent(id, .Complete)
        }
    }
    
}
