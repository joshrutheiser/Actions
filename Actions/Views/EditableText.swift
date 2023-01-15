//
//  EditableText.swift
//  Actions
//
//  Created by Josh Rutheiser on 1/12/23.
//

import Foundation
import UIKit

protocol EditableTextDelegate {
    func textEvent(_ event: TextEvent)
}

enum TextEvent {
    case Tapped
    case Modified
    case Backspace
    case Enter(_ index: Int)
    case Save(_ text: String)
}

//MARK: - Editable Text

@IBDesignable
class EditableText: UITextView {
    lazy var saveTimer = SaveTimer()
    var editDelegate: EditableTextDelegate?
    var tapRecognizer: UITapGestureRecognizer?

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

//MARK: - Link support

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
        editDelegate?.textEvent(.Tapped)
    }
}

//MARK: - Editing

extension EditableText: UITextViewDelegate {

    func startEditing(_ position: UITextPosition) {
        tapRecognizer?.isEnabled = false
        isEditable = true
        selectedTextRange = textRange(from: position, to: position)
        becomeFirstResponder()
    }
    
    func stopEditing() {
        tapRecognizer?.isEnabled = true
        isEditable = false
        resignFirstResponder()
        saveTimer.stop()
        text = trimmedText()
        save()
    }
    
    func textView(
        _ textView: UITextView,
        shouldChangeTextIn range: NSRange,
        replacementText text: String) -> Bool
    {
        if text.isEmpty && range.location == 0 && range.length == 0 {
            saveTimer.stop()
            editDelegate?.textEvent(.Backspace)
            return false
        }
        
        if text.last?.isNewline == true {
            saveTimer.stop()
            guard trimmedText().isEmpty == false else { return false }
            editDelegate?.textEvent(.Enter(range.location))
            return false
        }

        saveTimer.start()
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        editDelegate?.textEvent(.Modified)
    }
}

//MARK: - Save

extension EditableText: SaveTimerDelegate {
    func save() {
        Task(priority: .background) { [weak self] in
            self?.editDelegate?.textEvent(.Save(text))
        }
    }
}

//MARK: - Private functions

extension EditableText {
    private func trimmedText() -> String {
        return text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
