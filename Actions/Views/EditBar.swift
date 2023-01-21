//
//  EditBar.swift
//  Action
//
//  Created by Josh Rutheiser on 6/18/22.
//

import UIKit

protocol EditBarDelegate {
    func actionHighPressed()
    func actionMedPressed()
    func actionLowPressed()
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
