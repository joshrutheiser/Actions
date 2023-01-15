//
//  ActionCell.swift
//  Actions
//
//  Created by Josh Rutheiser on 1/8/23.
//

import UIKit

protocol ActionCellDelegate {
    func complete(_ actionId: String)
    func textEvent(_ actionId: String, _ event: TextEvent)
}

class ActionCell: UITableViewCell {
    @IBOutlet weak var actionText: EditableText!
    private var actionId: String?
    var delegate: ActionCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        actionText.translatesAutoresizingMaskIntoConstraints = false
        actionText.editDelegate = self
    }

    override func prepareForReuse() {
        actionText.reset()
        actionId = nil
        delegate = nil
    }
    
    func setup(_ action: Action) {
        actionText.text = action.text
        actionId = action.id
    }
    
    @IBAction func completePressed(_ sender: UIButton) {
        guard let actionId = actionId else { return }
        actionText.stopEditing()
        delegate?.complete(actionId)
    }
}

extension ActionCell: EditableTextDelegate {
    func textEvent(_ event: TextEvent) {
        guard let actionId = actionId else { return }
        delegate?.textEvent(actionId, event)
    }
}
