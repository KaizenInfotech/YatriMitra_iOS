//
//  CustomKeyboard.swift
//  yatriMitra
//
//  Created by Kaizen Infotech Solutions Private Limited. on 25/12/24.
//
import UIKit
import Foundation


class CustomTextField: UITextField {
    // Delegate to notify the backspace press
    weak var backspaceDelegate: CustomTextFieldDelegate?
    
    override func deleteBackward() {
        super.deleteBackward()
        backspaceDelegate?.textFieldDidPressBackspace(self)
    }
}

protocol CustomTextFieldDelegate: AnyObject {
    func textFieldDidPressBackspace(_ textField: CustomTextField)
}

