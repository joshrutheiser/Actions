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

class ActionCell: UITableViewCell {
    @IBOutlet weak var checkmark: Checkmark!
    @IBOutlet weak var editText: EditableText!
    var id: String?
    var delegate: ActionCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        editText.translatesAutoresizingMaskIntoConstraints = false
        editText.editDelegate = self
    }

    override func prepareForReuse() {
        editText.reset()
        checkmark.reset()
        id = nil
        delegate = nil
    }
    
    func setText(_ text: String) {
        editText.text = text
    }
    
    func getText() -> String {
        return editText.text.trim()
    }
    
    @IBAction func completePressed(_ sender: UIButton) {
        guard let id = id else { return }
        delegate?.handleEditEvent(id, .Complete)
    }
    
    func stopEditing() {
        editText.stopEditing()
    }
    
    func startEditing(_ index: Int) {
        editText.startEditing(index)
    }
}

extension ActionCell: EditableTextDelegate {
    func editEvent(_ event: EditEvent) {
        guard let id = id else { return }
        delegate?.handleEditEvent(id, event)
    }
}
