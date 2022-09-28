//
//  NumberTextField.swift
//
//  Created by Kristian Kiraly on 8/22/22.
//

import SwiftUI

@available(iOS 15, macOS 15.0, *)
fileprivate enum NumberWrapper: Equatable {
    case double(Binding<Double>)
    case int(Binding<Int>)
    case float(Binding<Float>)
    
    static func == (lhs: NumberWrapper, rhs: NumberWrapper) -> Bool {
        if case .double(let leftBinding) = lhs, case .double(let rightBinding) = rhs {
            return leftBinding.wrappedValue == rightBinding.wrappedValue //If they're both doubles and their values are equal, return true
        }
        if case .int(let leftBinding) = lhs, case .int(let rightBinding) = rhs {
            return leftBinding.wrappedValue == rightBinding.wrappedValue //If they're both ints and their values are equal, return true
        }
        if case .float(let leftBinding) = lhs, case .float(let rightBinding) = rhs {
            return leftBinding.wrappedValue == rightBinding.wrappedValue //If they're both floats and their values are equal, return true
        }
        return false //They either weren't the same type or the values didn't match
    }
    
    func isEqualToStringValue(string:String) -> Bool {
        switch self {
        case .double(let binding):
            return string.doubleValue == binding.wrappedValue
        case .int(let binding):
            return string.intValue == binding.wrappedValue
        case .float(let binding):
            return string.floatValue == binding.wrappedValue
        }
    }
}

@available(iOS 15, macOS 15.0, *)
extension String {
    fileprivate init(_ numberWrapper:NumberWrapper) { //Init string from NumberWrapper
        switch numberWrapper { //Just run String.init() on each type once broken out
        case .double(let binding):
            self.init(binding.wrappedValue)
        case .int(let binding):
            self.init(binding.wrappedValue)
        case .float(let binding):
            self.init(binding.wrappedValue)
        }
    }
    
    var doubleValue:Double {
        guard let resultDouble = Double(self) else { return 0 }
        return resultDouble
    }
    
    var intValue:Int {
        guard let resultInt = Int(self) else { return 0 }
        return resultInt
    }
    
    var floatValue:Float {
        guard let resultFloat = Float(self) else { return 0 }
        return resultFloat
    }
    
    fileprivate func isEqualToNumber(number:NumberWrapper) -> Bool {
        number.isEqualToStringValue(string: self)
    }
}

@available(iOS 15, macOS 15.0, *)
public struct NumberTextField: View {
    private var numberWrapper:NumberWrapper
    @State private var text:String
    private var placeholderText:String
    public static let defaultPlaceholderText = "Number Entry"

    public init(placeholderText:String = defaultPlaceholderText, number:Binding<Int>, startBlankIfZero:Bool = true) {
        numberWrapper = .int(number)
        var initialText = String(number.wrappedValue)
        if startBlankIfZero && number.wrappedValue == 0 {
            initialText = ""
        }
        _text = State(initialValue: initialText)
        self.placeholderText = placeholderText
    }

    public init(placeholderText:String = defaultPlaceholderText, number:Binding<Double>, startBlankIfZero:Bool = true) {
        numberWrapper = .double(number)
        var initialText = String(number.wrappedValue)
        if startBlankIfZero && number.wrappedValue == 0.0 {
            initialText = ""
        }
        _text = State(initialValue: initialText)
        self.placeholderText = placeholderText
    }

    public init(placeholderText:String = defaultPlaceholderText, number:Binding<Float>, startBlankIfZero:Bool = true) {
        numberWrapper = .float(number)
        var initialText = String(number.wrappedValue)
        if startBlankIfZero && number.wrappedValue == 0.0 {
            initialText = ""
        }
        _text = State(initialValue: initialText)
        self.placeholderText = placeholderText
    }

    public var body: some View {
        textFieldWrapper
    }
    
    private var textFieldWrapper:some View {
        TextFieldWrapper(
            keyboardType: keyboardType,
            text: Binding(
                get: {
                    if numberWrapper.isEqualToStringValue(string: text) {
                        return text //If the value of the stored text and the binding number are equal, no need to replace the text. Keep stored value
                    } else {
                        return String(numberWrapper) //If the stored text's value and the binding number aren't equal, replace with number as text
                    }
                },
                set: { newText in
                    updateNumber(string: newText) //Text changed, update the number to match
                }),
            isInt: isInt,
            placeholderText: placeholderText,
            textDidEndEditingAction: textDidEndEditing(string:),
            textDidChangeAction: textDidChange(string:)
        )
        .fixedSize(horizontal: false, vertical: true)
        .onChange(of: numberWrapper) { newValue in
            if !numberWrapper.isEqualToStringValue(string: text) {
                text = String(numberWrapper)
            }
        }
    }
    
    private func textDidEndEditing(string:String?) {
        guard let string = string else { return }
        print(string)
        updateNumber(string: string)
    }
    
    private func textDidChange(string:String?) {
        guard let string = string else { return }
        print(string)
        updateNumber(string: string)
    }
    
    private func updateNumber(string:String) {
        DispatchQueue.main.async {
            switch numberWrapper {
            case .double(let binding):
                let proposedValue = string.doubleValue
                if binding.wrappedValue != proposedValue { //Need to only set if different or infinite loop of setting, then updating a view which sets...
                    if proposedValue == 0 || floor(proposedValue) == proposedValue { //Let people type with zero at the beginning or starting with a decimal
                        text = string
                    } else {
                        text = String(proposedValue)
                    }
                    binding.wrappedValue = proposedValue
                }
            case .int(let binding):
                let proposedValue = string.intValue
                if binding.wrappedValue != proposedValue { //Need to only set if different or infinite loop of setting, then updating a view which sets...
                    if proposedValue == 0 { //Let people type with zero at the beginning
                        text = string
                    } else {
                        text = String(proposedValue)
                    }
                    binding.wrappedValue = proposedValue
                }
            case .float(let binding):
                let proposedValue = string.floatValue
                if binding.wrappedValue != proposedValue { //Need to only set if different or infinite loop of setting, then updating a view which sets...
                    if proposedValue == 0 || floor(proposedValue) == proposedValue { //Let people type with zero at the beginning or starting with a decimal
                        text = string
                    } else {
                        text = String(proposedValue)
                    }
                    binding.wrappedValue = proposedValue
                }
            }
        }
    }

    private var isInt:Bool {
        return NumberTextField.isInt(numberWrapper: numberWrapper)
    }

    private var keyboardType:UIKeyboardType {
        isInt ? .numberPad : .decimalPad
    }
    
    private static func isInt(numberWrapper:NumberWrapper) -> Bool {
        if case .int = numberWrapper {
            return true
        }
        return false
    }
}

@available(iOS 15, macOS 15.0, *)
fileprivate struct TextFieldWrapper: UIViewRepresentable {
    var keyboardType:UIKeyboardType = .default
    @Binding var text:String
    var isInt:Bool
    var placeholderText:String = ""
    var textAlignment:NSTextAlignment = .right
    var borderStyle:UITextField.BorderStyle = .roundedRect
    var startBlankIfZero = true
    var textDidEndEditingAction:(String?) -> Void = {_ in }
    var textDidChangeAction:(String?) -> Void = {_ in }
    @State var cursorPositionRange:UITextRange?
    
    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField(frame: .zero)
        textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        textField.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        textField.delegate = context.coordinator
        
        self.setProperties(textField)
        
        
        
        return textField
    }
    
    private func setProperties(_ textField: UITextField) {
        textField.keyboardType = self.keyboardType
        textField.placeholder = self.placeholderText
        textField.textAlignment = self.textAlignment
        textField.borderStyle = self.borderStyle
        textField.text = self.text
        if let cursorPositionRange = cursorPositionRange {
            textField.selectedTextRange = cursorPositionRange
        }
    }
    
    func updateUIView(_ uiView: UITextField, context: Context) {
        self.setProperties(uiView)
    }
    
    func makeCoordinator() -> TextFieldCoordinator {
        TextFieldCoordinator(self)
    }
    
    func setCursorPositionRange(range:UITextRange?) {
        self.cursorPositionRange = range
    }
    
    class TextFieldCoordinator: NSObject, UITextFieldDelegate {
        var parent: TextFieldWrapper
        
        init(_ textField: TextFieldWrapper) {
            self.parent = textField
        }
        
        //Also called on resignFirstResponder
        func textFieldDidEndEditing(_ textField: UITextField) {
            self.parent.textDidEndEditingAction(textField.text)
        }
        
        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            //Check validity of string as a number
            let shouldReplace = TextFieldCoordinator.textField(textField, shouldChangeCharactersIn: range, replacementString: string, isInt: parent.isInt, textDidChangeAction: parent.textDidChangeAction)
            
            guard shouldReplace else { return shouldReplace }
            
            //Get string after proposed replacement. If failed, exit
            guard let proposedText = TextFieldCoordinator.proposedTextAfterReplacingCharacters(textField, tryReplacingCharactersIn: range, replacementString: string) else { return shouldReplace }
            
            //Get number values of both valid number strings. If it fails for some reason, return
            guard let originalText = textField.text, let originalDoubleValue = Double(originalText), let proposedDoubleValue = Double(proposedText) else { return shouldReplace }
            
            //Make sure values are different. If they're not different, we don't need to set the cursor position or replace the parent's text value, so return
            //Values could be the same, but it could be 1.40 vs 1.4 and skip to 1.4. So we can skip the replacement of the value in parent
            guard originalDoubleValue != proposedDoubleValue else { return shouldReplace }
            
            //Tell the TextFieldWrapper to set the cursor position to the place it should go after the replacement
            self.parent.setCursorPositionRange(range: TextFieldCoordinator.cursorPositionForTextReplacement(textField, replacementRange: range, replacementString: string))
            
            //Set the text to the replacement text
            self.parent.text = proposedText
            
            return shouldReplace
        }
        
        static func cursorPositionForTextReplacement(_ textField:UITextField, replacementRange range:NSRange, replacementString string:String) -> UITextRange? {
            //Try replacing characters as planned
            guard let proposedText = TextFieldCoordinator.proposedTextAfterReplacingCharacters(textField, tryReplacingCharactersIn: range, replacementString: string) else { return nil }
            
            //Create dummy UITextField to calculate cursor position and populate with proposed text
            let proposedTextField = UITextField(frame: .zero)
            proposedTextField.text = proposedText
            
            //Find the length of the string that will be inserted in the replacement
            let addedLength = string.count
            //Find the length of the characters that will be replaced
            let replacedLength = range.length
            //Find the total cursor offset length after both insertion and replacement have occurred
            let offsetLength = addedLength - replacedLength
            //Get the current cursor position from the real text field
            guard let selectedTextRange = textField.selectedTextRange else { return nil }
            let beginning = textField.beginningOfDocument
            let currentCursorPosition = textField.offset(from: beginning, to: selectedTextRange.start)
            //Capture the start position of the proposed new cursor position
            guard let start = proposedTextField.position(from: beginning, offset: currentCursorPosition + offsetLength),
                    let end = proposedTextField.position(from: start, offset: 0) else {
                return nil
            }
            return proposedTextField.textRange(from: start, to: end)
        }
        
        static func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String, isInt: Bool, textDidChangeAction:(String?) -> Void) -> Bool {
            //Try replacing characters. If failed, return false
            guard let proposedString = proposedTextAfterReplacingCharacters(textField, tryReplacingCharactersIn: range, replacementString: string) else { return false }
            
            var isValid = false
            if isInt {
                isValid = Coordinator.stringIsValidInt(string: proposedString)
            } else {
                isValid = Coordinator.stringIsValidDecimal(string: proposedString)
            }
            
            if isValid {
                //If the string was a valid number, then we will perform the replacement. So call textDidChangeAction
                textDidChangeAction(proposedString)
            }
            
            return isValid
        }
        
        static func proposedTextAfterReplacingCharacters(_ textField:UITextField, tryReplacingCharactersIn range:NSRange, replacementString string:String) -> String? {
            guard let currentText = textField.text as? NSString else { return nil }
            return currentText.replacingCharacters(in: range, with: string)
        }
        
        static let justNumbersCharacterSetFilter = CharacterSet.decimalDigits.inverted
        static func stringIsValidInt(string:String) -> Bool {
            let filteredString = string.components(separatedBy: justNumbersCharacterSetFilter).joined()
            return string == filteredString
        }
        
        static let decimalCharacterSet = CharacterSet(charactersIn: ".")
        static let numbersAndDecimalsCharacterSetFilter = CharacterSet.decimalDigits.union(decimalCharacterSet).inverted
        static func stringIsValidDecimal(string:String) -> Bool {
            let filteredString = string.components(separatedBy: numbersAndDecimalsCharacterSetFilter).joined()
            return string == filteredString && numDecimalsInString(string: string) <= 1
        }
        
        static func numDecimalsInString(string:String) -> Int {
            return string.components(separatedBy: decimalCharacterSet).count - 1
        }
    }
}

#if DEBUG
@available(iOS 15, macOS 15.0, *)
extension TextFieldWrapper {
    internal static func testStringIsValidInt(string:String) -> Bool {
        TextFieldCoordinator.stringIsValidInt(string: string)
    }
    
    internal static func testStringIsValidDecimal(string:String) -> Bool {
        TextFieldCoordinator.stringIsValidDecimal(string: string)
    }
    
    internal static func testShouldReplaceCharactersInRange(_ textField:UITextField, shouldChangeCharactersIn range:NSRange, replacementString string: String, isInt:Bool, textDidChangeAction:(String?) -> Void) -> Bool {
        TextFieldCoordinator.textField(textField, shouldChangeCharactersIn: range, replacementString: string, isInt: isInt, textDidChangeAction: textDidChangeAction)
    }
    
    internal static func testProposedTextAfterReplacingCharacters(_ textField:UITextField, tryReplacingCharactersIn range:NSRange, replacementString string:String) -> String? {
        TextFieldCoordinator.proposedTextAfterReplacingCharacters(textField, tryReplacingCharactersIn: range, replacementString: string)
    }
}

@available(iOS 15, macOS 15.0, *)
extension NumberTextField {
    internal static func testStringIsValidInt(string:String) -> Bool {
        TextFieldWrapper.testStringIsValidInt(string: string)
    }
    
    internal static func testStringIsValidDecimal(string:String) -> Bool {
        TextFieldWrapper.testStringIsValidDecimal(string: string)
    }
    
    internal static func testShouldReplaceCharactersInRange(_ textField:UITextField, shouldChangeCharactersIn range:NSRange, replacementString string: String, isInt: Bool, textDidChangeAction:(String?) -> Void) -> Bool {
        TextFieldWrapper.testShouldReplaceCharactersInRange(textField, shouldChangeCharactersIn: range, replacementString: string, isInt: isInt, textDidChangeAction: textDidChangeAction)
    }
    
    internal static func testProposedTextAfterReplacingCharacters(_ textField:UITextField, tryReplacingCharactersIn range:NSRange, replacementString string:String) -> String? {
        TextFieldWrapper.testProposedTextAfterReplacingCharacters(textField, tryReplacingCharactersIn: range, replacementString: string)
    }
}
#endif
