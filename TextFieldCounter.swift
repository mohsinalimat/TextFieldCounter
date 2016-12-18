//
//  TextFieldCounter.swift
//  TextFieldCounter
//
//  Created by Fabricio Serralvo on 12/7/16.
//  Copyright © 2016 Fabricio Serralvo. All rights reserved.
//

import Foundation
import UIKit

class TextFieldCounter: UITextField, UITextFieldDelegate {

    var counterLabel: UILabel!
    
    // MARK: IBInspectable: Limits and behaviors
    
    @IBInspectable public dynamic var animate : Bool = true
    @IBInspectable public var maxLength : Int = TextFieldCounter.defaultLength {
        didSet {
            if (!self.isValidMaxLength(max: self.maxLength)) {
                self.maxLength = TextFieldCounter.defaultLength
            }
        }
    }
    @IBInspectable public dynamic var counterColor : UIColor! = UIColor.lightGray
    @IBInspectable public dynamic var limitColor: UIColor! = UIColor.red
    
    // MARK: Enumerations and Constants
    
    enum animationType {
        case basic
        case didReachLimit
        case unknown
    }
    
    static let defaultLength = 30
    
    // MARK: Init
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        super.delegate = self
        self.counterLabel = self.setupCounterLabel()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.rightView = self.counterLabel
        self.rightViewMode = .whileEditing
    }
    
    // MARK: Public Methods
    
    /**
     Initializes a new beautiful *TextFieldCounter*.
     
     - parameter frame: The frame of view.
     - parameter shouldAnimate: Default is `true`.
     - parameter limit: By default, if the number is not greater than 0, the limit will be `30`.
     - parameter colorOfCounterLabel: Default color is `UIColor.lightGray`.
     - parameter colorOfLimitLabel: Default color is `UIColor.red`.
    */
    
    init(frame: CGRect, limit: Int, shouldAnimate: Bool?, colorOfCounterLabel: UIColor?, colorOfLimitLabel: UIColor?) {
        
        super.init(frame: frame)
        
        if !self.isValidMaxLength(max: limit) {
            self.maxLength = TextFieldCounter.defaultLength
        } else {
            self.maxLength = limit
        }
        
        if let animate = shouldAnimate {
            self.animate = animate
        } else {
            self.animate = true
        }
        
        if let counterTextColor = colorOfCounterLabel {
            self.counterColor = counterTextColor
        } else {
            self.counterColor = UIColor.lightGray
        }
        
        if let limitTextColor = colorOfLimitLabel {
            self.limitColor = limitTextColor
        } else {
            self.limitColor = UIColor.red
        }
        
        super.delegate = self
        self.counterLabel = self.setupCounterLabel()
    }
    
    // MARK: Private Methods
    
    private func isValidMaxLength(max: Int) -> Bool {
        return max > 0
    }
    
    private func setupCounterLabel() -> UILabel! {
        
        let fontFrame : CGRect = CGRect(x: 0, y: 0, width: self.getCounterLabelWidth(), height: Int(self.frame.height))
        let label : UILabel = UILabel(frame: fontFrame)
        
        if let currentFont : UIFont = self.font {
            label.font = currentFont
            label.textColor = self.counterColor
            label.textAlignment = .left
            label.lineBreakMode = .byWordWrapping
            label.numberOfLines = 1
        }
        
        return label
    }
    
    private func getCounterLabelWidth() -> Int {
        let biggestText : NSString = "\(self.maxLength)" as NSString
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .left
        paragraph.lineBreakMode = .byWordWrapping
        
        let size: CGSize = biggestText.size(attributes: [NSFontAttributeName: self.font!, NSParagraphStyleAttributeName : paragraph])
        
        return Int(size.width) + 15
    }
    
    private func updateCounterLabel(count: Int) {
        if count <= self.maxLength {
            self.counterLabel.text = "\(count)"
        }
        
        self.prepareToAnimateCounterLabel(count: count)
    }
    
    private func getTextFieldCharactersCount(textField: UITextField, string: String) -> Int {
        
        var textFieldCharactersCount = 0
        
        if let textFieldText = textField.text {
            
            textFieldCharactersCount = textFieldText.characters.count + string.characters.count
            
            if string.isEmpty {
                textFieldCharactersCount = textFieldCharactersCount - 1
            }
        }
        
        return textFieldCharactersCount
    }

    // MARK: Animations
    
    private func prepareToAnimateCounterLabel(count: Int) {
        
        var animationType : animationType = .unknown
        
        if (count >= self.maxLength) {
            animationType = .didReachLimit
        } else if (count <= self.maxLength) {
            animationType = .basic
        }
        
        self.animateTo(type: animationType)
    }
    
    private func animateTo(type: animationType) {
        
        switch type {
        case .basic:
            self.animateCounterLabelColor(color: self.counterColor)
            break
        case .didReachLimit:
            self.animateCounterLabelColor(color: self.limitColor)
            
            if (self.animate) {
                self.counterLabel.shakeTo(transform: CGAffineTransform(translationX: 5, y: 0), duration: 0.3)
            }
            
            break
        default:
            print("Ops, nothing to animate")
            break
        }
    }
    
    private func animateCounterLabelColor(color: UIColor) {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            self.counterLabel.textColor = color
        }, completion: nil)
    }
    
    // MARK: UITextFieldDelegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        var shouldChange = false
        let textFieldCharactersCount = self.getTextFieldCharactersCount(textField: textField, string: string)
        
        if string.isEmpty {
            shouldChange = true
        } else {
            shouldChange = textFieldCharactersCount <= self.maxLength
        }
        
        self.updateCounterLabel(count: textFieldCharactersCount)
        
        return shouldChange
    }
    
}

extension UIView {
    
    public func shakeTo(transform: CGAffineTransform, duration: TimeInterval) {
        
        self.transform = transform
        
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseInOut, animations: {
            self.transform = CGAffineTransform.identity
        }, completion: nil)
    }
    
}
