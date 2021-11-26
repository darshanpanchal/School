//  Created by Oleg Hnidets on 12/20/17.
//  Copyright © 2017-2018 Oleg Hnidets. All rights reserved.
//
import Foundation
import UIKit

/// An object of the class has a customized placeholder label which has animations on the beginning and ending editing.
open class TweePlaceholderTextField: UITextField {
    
    override open func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return false
    }
	/// Animation type when a user begins editing.
	public enum MinimizationAnimationType {
		/** Sets minimum font size immediately when a user begins editing. */
		case immediately

		// Has some performance issue on first launch. Need to investigate how to fix.
		/** Sets minimum font size step by step during animation transition when a user begins editing */
		case smoothly
	}

	// Public

	/// Default is `immediately`.
	public var minimizationAnimationType: MinimizationAnimationType = .immediately
	/// Minimum font size for the custom placeholder.
	@IBInspectable public public(set) var minimumPlaceholderFontSize: CGFloat = 15
	/// Original (maximum) font size for the custom placeholder.
	@IBInspectable public public(set) var originalPlaceholderFontSize: CGFloat = 18
	/// Placeholder animation duration.
	@IBInspectable public private(set) var placeholderDuration: Double = 0.5
	/// Color of custom placeholder.
	@IBInspectable public var placeholderColor: UIColor? {
		get {
			return placeholderLabel.textColor
		} set {
			placeholderLabel.textColor = newValue
		}
	}
	/// The styled string for a custom placeholder.
	public var attributedTweePlaceholder: NSAttributedString? {
		get {
			return placeholderLabel.attributedText
		} set {
			setAttributedPlaceholderText(newValue)
		}
	}
    let padding = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20);
    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)// UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    
	/// The string that is displayed when there is no other text in the text field.
	@IBInspectable public var tweePlaceholder: String? {
		get {
			return placeholderLabel.text
		} set {
			setPlaceholderText(newValue)
		}
	}
    public var minimumPlaceHolder:String?
    public var maximumPlaceHolder:String?
    
	/// Custom placeholder label. You can use it to style placeholder text.
	public private(set) lazy var placeholderLabel = UILabel()

	///	The current text that is displayed by the label.
	open override var text: String? {
		didSet {
			setCorrectPlaceholderSize()
		}
	}

	/// The styled text displayed by the text field.
	open override var attributedText: NSAttributedString? {
		didSet {
			setCorrectPlaceholderSize()
		}
	}

	/// The technique to use for aligning the text.
	open override var textAlignment: NSTextAlignment {
		didSet {
			placeholderLabel.textAlignment = textAlignment
		}
	}

	/// The font used to display the text.
	open override var font: UIFont? {
		didSet {
			configurePlaceholderFont()
		}
	}
    open var placeHolderFont:UIFont?{
        didSet{
            configurePlaceholderFont()
        }
    }
	// Private

	private var minimizeFontAnimation: FontAnimation!

	private var maximizeFontAnimation: FontAnimation!

	private var bottomConstraint: NSLayoutConstraint?

	// MARK: Methods

	/// Prepares the receiver for service after it has been loaded from an Interface Builder archive, or nib file.
	override open func awakeFromNib() {
		super.awakeFromNib()
		initializeTextField()
	}

	private func initializeTextField() {
		observe()

		minimizeFontAnimation = FontAnimation(target: self, selector: #selector(minimizePlaceholderFontSize))
		maximizeFontAnimation = FontAnimation(target: self, selector: #selector(maximizePlaceholderFontSize))

		configurePlaceholderLabel()
	}

	// Need to investigate and make code better.
	private func configurePlaceholderLabel() {
		placeholderLabel.textAlignment = textAlignment
        placeholderLabel.adjustsFontSizeToFitWidth = true
        placeholderLabel.minimumScaleFactor = 0.5
		configurePlaceholderFont()
	}

	private func configurePlaceholderFont() {
		placeholderLabel.font = placeHolderFont ?? placeholderLabel.font//font ?? placeholderLabel.font
		placeholderLabel.font = placeholderLabel.font.withSize(originalPlaceholderFontSize)
	}

	private func setPlaceholderText(_ text: String?) {
		addPlaceholderLabelIfNeeded()
		placeholderLabel.text = text
	}

	private func setAttributedPlaceholderText(_ text: NSAttributedString?) {
		addPlaceholderLabelIfNeeded()
		placeholderLabel.attributedText = text
	}

	private func observe() {
		let notificationCenter = NotificationCenter.default

		notificationCenter.addObserver(self,
									   selector: #selector(minimizePlaceholder),
                                       name: UITextField.textDidBeginEditingNotification,
									   object: self)

		notificationCenter.addObserver(self,
									   selector: #selector(maximizePlaceholder),
                                       name: UITextField.textDidEndEditingNotification,
									   object: self)
	}

	@objc private func setCorrectPlaceholderSize() {
		if let text = text, text.isEmpty == false {
			minimizePlaceholder()
		} else if isEditing == false {
			maximizePlaceholder()
		}
	}

	@objc public func minimizePlaceholder() {
		bottomConstraint?.constant = -frame.height

		UIView.animate(withDuration: placeholderDuration, delay: 0, options: [.preferredFramesPerSecond30], animations: {
			self.layoutIfNeeded()

			switch self.minimizationAnimationType {
			case .immediately:
                if let min = self.minimumPlaceHolder{
                    self.placeholderLabel.text = "\(min)"
                }else{
                    self.placeholderLabel.text = "\(self.tweePlaceholder ?? "")"
                }
				self.placeholderLabel.font = UIFont.init(name: "Avenir-Heavy", size: self.minimumPlaceholderFontSize) //self.placeholderLabel.font.withSize(self.minimumPlaceholderFontSize)
			case .smoothly:
				self.minimizeFontAnimation.start()
			}
		}, completion: { _ in
			self.minimizeFontAnimation.stop()
		})
	}

	@objc private func minimizePlaceholderFontSize() {
		guard let startTime = minimizeFontAnimation.startTime else {
			return
		}

		let timeDiff = CFAbsoluteTimeGetCurrent() - startTime
		let percent = CGFloat(1 - timeDiff / placeholderDuration)

		if percent < 0 {
			return
		}

		let fontSize = (originalPlaceholderFontSize - minimumPlaceholderFontSize) * percent + minimumPlaceholderFontSize

		DispatchQueue.main.async {
            if let min = self.minimumPlaceHolder{
                self.placeholderLabel.text = "\(min)"
            }else{
                self.placeholderLabel.text = "\(self.tweePlaceholder ?? "")"
            }
			self.placeholderLabel.font = UIFont.init(name: "Avenir-Heavy", size:fontSize)
            //self.placeholderLabel.font.withSize(fontSize)
		}
	}

	@objc public func maximizePlaceholder() {
		if let text = text, text.isEmpty == false {
			return
		}

		bottomConstraint?.constant = 0

		UIView.animate(withDuration: placeholderDuration, delay: 0, options: [.preferredFramesPerSecond60], animations: {
			self.layoutIfNeeded()
			self.maximizeFontAnimation.start()
		}, completion: { _ in
			self.maximizeFontAnimation.stop()
            if let max = self.maximumPlaceHolder{
                self.placeholderLabel.text = "\(max)"
            }else{
                self.placeholderLabel.text = "\(self.tweePlaceholder ?? "")"
            }
            
			self.placeholderLabel.font = UIFont.init(name: "Avenir-Roman", size:self.originalPlaceholderFontSize)
                //self.placeholderLabel.font.withSize(self.originalPlaceholderFontSize)
		})
	}

	@objc private func maximizePlaceholderFontSize() {
		guard let startTime = maximizeFontAnimation.startTime else {
			return
		}

		let timeDiff = CFAbsoluteTimeGetCurrent() - startTime
		let percent = CGFloat(timeDiff / placeholderDuration)

		let fontSize = (originalPlaceholderFontSize - minimumPlaceholderFontSize) * percent + minimumPlaceholderFontSize

		DispatchQueue.main.async {
			let size = min(self.originalPlaceholderFontSize, fontSize)
            if let max = self.maximumPlaceHolder{
                self.placeholderLabel.text = "\(max)"
            }else{
                self.placeholderLabel.text = "\(self.tweePlaceholder ?? "")"
            }
			self.placeholderLabel.font = UIFont.init(name: "Avenir-Roman", size:size)
                //self.placeholderLabel.font.withSize(size)
		}
	}

	private func addPlaceholderLabelIfNeeded() {
		if placeholderLabel.superview != nil {
			return
		}

		addSubview(placeholderLabel)
		placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
		placeholderLabel.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
//        placeholderLabel.trailingAnchor.constraint(equalTo: trailingAnchor, Constants = -30).isActive = true
        placeholderLabel.trailingAnchor.constraint(equalTo: trailingAnchor,constant: -30).isActive = true
		bottomConstraint = placeholderLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
		bottomConstraint?.isActive = true

		let centerYConstraint = placeholderLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
		centerYConstraint.priority = .defaultHigh
		centerYConstraint.isActive = true
	}
}
