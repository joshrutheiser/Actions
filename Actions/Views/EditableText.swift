//
//  EditableText.swift
//  Actions
//
//  Created by Josh Rutheiser on 1/12/23.
//

#warning ("TODO: load accessory bar")

import Foundation
import UIKit

protocol EditableTextDelegate {
    func editEvent(_ event: EditEvent)
}

enum EditEvent {
    case Tapped
    case Backspace(text: String)
    case Enter(text: String, index: Int)
    case Save(text: String)
    case Complete
    case Modify
}

//MARK: - Editable Text

@IBDesignable
class EditableText: UITextView {
    lazy var saveTimer = SaveTimer()
    var editDelegate: EditableTextDelegate?
    var tapRecognizer: UITapGestureRecognizer?
    var lastSaved: String?
    
    //MARK: - Setup
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
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
        tapRecognizer?.isEnabled = true
        isEditable = false
    }
    
    private func setup() {
        isEditable = false
        delegate = self
        saveTimer.delegate = self
        tapRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(tapped(recognizer:))
        )
        addGestureRecognizer(tapRecognizer!)
    }
    
}

//MARK: - Hyperlink support

extension EditableText {
    
    @objc func tapped(recognizer: UITapGestureRecognizer) {
        let location = recognizer.location(in: self)
        guard var position = closestPosition(to: location) else { return }
        
        if let style = textStyling(at: position, in: .forward) {
            if let url = style[NSAttributedString.Key.link] as? URL {
                UIApplication.shared.open(url)
                return
            }
        } else {
            position = endOfDocument
        }
        
        startEditing(position)
        editDelegate?.editEvent(.Tapped)
    }
}

//MARK: - Editing

extension EditableText: UITextViewDelegate {

    func startEditing(_ position: UITextPosition) {
        tapRecognizer?.isEnabled = false
        isEditable = true
        selectedTextRange = textRange(
            from: position,
            to: position
        )
        becomeFirstResponder()
    }
    
    func startEditing(_ index: Int) {
        let beginning = beginningOfDocument
        guard let position = position(from: beginning, offset: index) else { return }
        startEditing(position)
    }
    
    func stopEditing() {
        tapRecognizer?.isEnabled = true
        isEditable = false
        text = text.trim()
        saveTimer.stop()
        save()
    }
    
    func textView(
        _ textView: UITextView,
        shouldChangeTextIn range: NSRange,
        replacementText text: String) -> Bool
    {
        if text.isEmpty && range.location == 0 && range.length == 0 {
            saveTimer.stop()
            editDelegate?.editEvent(
                .Backspace(text: self.text)
            )
            return false
        }
        
        if text.last?.isNewline == true {
            saveTimer.stop()
            guard self.text.trim().isEmpty == false
                else { return false }
            editDelegate?.editEvent(
                .Enter(
                    text: self.text,
                    index: range.location
                )
            )
            return false
        }

        saveTimer.start()
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        editDelegate?.editEvent(.Modify)
    }
    
    // initialize last saved text
    func textViewDidBeginEditing(_ textView: UITextView) {
        lastSaved = textView.text
    }
}

//MARK: - Save

extension EditableText: SaveTimerDelegate {
    func save() {
        // don't save if text hasn't changed
        guard text.trim() != lastSaved?.trim() else { return }
        editDelegate?.editEvent(
            .Save(text: text)
        )
        lastSaved = text
    }
}
