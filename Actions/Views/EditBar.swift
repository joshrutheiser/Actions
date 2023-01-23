//
//  EditBar.swift
//  Action
//
//  Created by Josh Rutheiser on 1/20/23.
//

import UIKit

protocol EditBarDelegate {
    func actionDonePressed()
}

class EditBar: UIView {
    var delegate: EditBarDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
        
    @IBAction func donePressed(_ sender: UIButton) {
        delegate?.actionDonePressed()
    }
}
