//
//  SSTSwitch.swift
//  SSTSwitch
//
//  Created by Ye Wai Yan on 8/1/19.
//  Copyright © 2019 Ye Wai Yan. All rights reserved.
//

import UIKit

enum SSTSwitchType: Int {
    case material
    case ios
    case iosImg
    case rounded
    var label: String {
        switch self {
        case .material: return "Material Switch"
        case .ios: return "iOS Switch"
        case .iosImg: return "iOS Switch /w Image"
        case .rounded: return "Rounded Switch"
        }
    }
}

enum SSTSwitchState: Int {
    case on
    case off
    case onSuspend
    case offSuspend
    var label: String {
        switch self {
        case .on: return "On State"
        case .off: return "Off State"
        case .onSuspend: return "Suspended On State"
        case .offSuspend: return "Suspended Off State"
        }
    }
}

protocol SSTSwitchDelegate {
    func didToggleSwitch(currentState: SSTSwitchState)
}

public class SSTSwitch: UIView {
    
    private var switchState: SSTSwitchState! = .off
    
    // Main Colors that will be referenced throughout the animations and states
    private var onColorCrease: UIColor!
    private var onColorKnob: UIColor!
    private var offColorCrease: UIColor!
    private var offColorKnob: UIColor!
    
    private var sliderKnob: UIView!
    private var sliderCrease: UIView!
    private var sliderKnobTint: UIView!
    private var sliderKnobImage: UIImageView!
    private var sliderKnobFill: UIView!
    private var tapGesture: UITapGestureRecognizer!
    
    private var creaseHeight: CGFloat!
    private var knobSize: CGFloat!
    
    // MARK: Configurables
    private var knobCreaseSizeDifference: CGFloat!
    private var knobTintSizeDifference: CGFloat!
    private var iosKnobSqueezeValue: CGFloat = 5
    
    // Constraints
    private var knobWidthConstraint: NSLayoutConstraint!
    private var knobLeftConstraint: NSLayoutConstraint!
    private var knobTintWidth: NSLayoutConstraint!
    private var knobTintHeight: NSLayoutConstraint!
    
    // Required for touch movements
    private var totalDistanceX: CGFloat!
    private var startLocationX: CGFloat!
    
    var delegate: SSTSwitchDelegate?
    
    // MARK: SSTSwitch Properties
    /// Padding for image in iOSImg Switch Type.
    /// Padding Value of 5 results the image to be padded all around in 5 points
    var imgPadding: CGFloat = 0 {
        didSet {
            if let _ = sliderKnobImage {
                let size = knobSize - imgPadding * 2
                sliderKnobImage.removeConstraints(sliderKnobImage.constraints)
                sliderKnobImage.layer.cornerRadius = size / 2
                sliderKnobImage.centerXAnchor.constraint(equalTo: sliderKnob.centerXAnchor).isActive = true
                sliderKnobImage.centerYAnchor.constraint(equalTo: sliderKnob.centerYAnchor).isActive = true
                sliderKnobImage.heightAnchor.constraint(equalToConstant: size).isActive = true
                sliderKnobImage.widthAnchor.constraint(equalToConstant: size).isActive = true
            }
        }
    }
    
    // MARK: Knob Clear
    /// Set to true to clear knob for both on and off states.
    var knobClear: Bool = false {
        didSet {
            if knobClear {
                onColorKnob = UIColor.clear
                offColorKnob = UIColor.clear
                sliderKnob.backgroundColor = switchState == .on ? onColorKnob : offColorKnob
            }
        }
    }
    
    // MARK: Custom Corner Radius
    /// Custom corner radius for crease rectangle.
    var switchCornerRadius: CGFloat = 10 {
        didSet {
            if switchType == .rounded {
                let ratio: CGFloat!
                if (knobSize > sliderCrease.frame.height) {
                    ratio = switchCornerRadius / sliderCrease.frame.height
                }
                else {
                    ratio = switchCornerRadius / knobSize
                }
                sliderCrease.layer.cornerRadius = switchCornerRadius
                sliderKnob.layer.cornerRadius = knobSize * ratio
            }
        }
    }
    
    /// Type of the switch (Material, iOS, iOS /w Img, Rounded) in raw value order
    var switchType: SSTSwitchType! = .ios {
        didSet {
            switch switchType! {
            case .ios, .iosImg:
                onColorKnob = .white
                onColorCrease = .iOSOnCrease
                offColorKnob = .white
                offColorCrease = .iOSOffCrease
            case .material, .rounded:
                onColorKnob = .materialOnKnob
                onColorCrease = .materialOnCrease
                offColorKnob = .materialOffKnob
                offColorCrease = .materialOffCrease
            }
            refreshViews()
        }
    }
    
    /// State of the switch (On or Off). Will instantly change to the desired state with no animations
    var state: SSTSwitchState! {
        didSet {
            switchState = state
            refreshViews()
        }
    }
    
    /// Image of the knob for the iOS /w Img type of switch
    var image: UIImage! {
        didSet {
            if switchType == .iosImg {
                sliderKnobImage.image = image
            }
        }
    }
    
    /// Active Color of the knob
    var activeColorKnob: UIColor! {
        didSet {
            onColorKnob = activeColorCrease
            updateColors()
        }
    }
    
    /// Active Color of the crease
    var activeColorCrease: UIColor! {
        didSet {
            onColorCrease = activeColorCrease
            updateColors()
        }
    }
    
    /// Idle Color of the knob
    var idleColorKnob: UIColor! {
        didSet {
            offColorKnob = idleColorKnob
            updateColors()
        }
    }
    
    /// Idle Color of the crease
    var idleColorCrease: UIColor! {
        didSet {
            offColorCrease = idleColorCrease
            updateColors()
        }
    }
    
    private func updateColors() {
        sliderKnob.backgroundColor = switchState == .on ? onColorKnob : offColorKnob
        
        if switchType == .ios || switchType == .iosImg {
            sliderCrease.layer.borderColor = switchState == .on ? onColorCrease.cgColor : UIColor.iOSCreaseBorder.cgColor
            sliderCrease.backgroundColor = switchState == .on ? onColorCrease : UIColor.iOSCreaseBorder
        } else {
            sliderCrease.backgroundColor = switchState == .on ? onColorCrease : offColorCrease
        }
        
        if switchType == .material {
            sliderKnobTint.backgroundColor = switchState == .on ? onColorCrease : offColorCrease
        }
    }
    
    /// Initialize the SSTSwitch with a required SSTSwitchType
    /// and multiple optional paramaters.
    
    /**
     This initializer will create a SSTSwitch primarilty based on the SSTSwitchType you passed on.
     Multiple properties can be specified with the initialization arguments
     - Parameters:
     - size: for the switch size, important: the width of the switch must be longer than the height
     - state: the starting state of the switch (on or off)
     - activeColor: the color of the knob in "on" state
     - activeColorCrease: the color of the crease in "on" state
     - idleColor: the color of the knob in "off" state
     - idleColorCrease: the color of the crease in "off" state
     - image: if you chose an iosImg switch type, you must pass on your desired UIImage. Otherwise, it will fill an empty UIImage
     - cornerRadius: if you chose a rounded switch type, you can specify your desired cornerRadius for the *crease*
     */
    init(size: CGSize? = nil, type: SSTSwitchType, state: SSTSwitchState? = .off,
         activeColorKnob: UIColor? = nil, activeColorCrease: UIColor? = nil,
         idleColorKnob: UIColor? = nil, idleColorCrease: UIColor? = nil,
         image: UIImage? = nil, cornerRadius: CGFloat? = nil) {
        
        var mainFrame: CGRect!
        if let _ = size {
            mainFrame = CGRect(origin: CGPoint.zero, size: size!)
        } else {
            if (type == .ios || type == .iosImg) {
                mainFrame = CGRect(x: 0, y: 0, width: 53, height: 33)
            } else if (type == .rounded) {
                mainFrame = CGRect(x: 0, y: 0, width: 60, height: 30)
            } else {
                mainFrame = CGRect(x: 0, y: 0, width: 50, height: 50)
            }
        }
        super.init(frame: mainFrame)
        
        self.switchType = type
        self.switchState = state
        
        if let _ = activeColorKnob {
            onColorKnob = activeColorKnob
        } else {
            onColorKnob = .materialOnKnob
        }
        if let _ = activeColorCrease {
            onColorCrease = activeColorCrease
        } else {
            onColorCrease = .materialOnCrease
        }
        
        if let _ = idleColorKnob {
            offColorKnob = idleColorKnob
        } else {
            offColorKnob = .materialOffKnob
        }
        if let _ = idleColorCrease {
            offColorCrease = idleColorCrease
        } else {
            offColorCrease = .materialOffCrease
        }
        
        self.heightAnchor.constraint(equalToConstant: mainFrame.height).isActive = true
        self.widthAnchor.constraint(equalToConstant: mainFrame.width).isActive = true

        commonSetup(size: mainFrame.size)
    }
    
    /** Initialization method invoked from IBOulet initialization/Storyboard */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        onColorKnob = .white
        onColorCrease = .iOSOnCrease
        offColorKnob = .white
        offColorCrease = .iOSOffCrease
        
        commonSetup(size: self.frame.size)
    }
    
    private func refreshViews() {
        self.removeAllChildViews()
        commonSetup(size: self.frame.size)
    }
    
    /** Common function that is called from both code init and interface builder objects init */
    private func commonSetup(size: CGSize, image: UIImage? = nil, cornerRadius: CGFloat? = nil) {
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapOnSwitch))
        self.addGestureRecognizer(tapGesture)

        let width = size.width
        let height = size.height
        var allConstraints = [NSLayoutConstraint]()
        
        sliderCrease = UIView(frame: .zero)
        sliderCrease.isUserInteractionEnabled = false
        sliderCrease.backgroundColor = switchState == .on ? onColorCrease : offColorCrease
        self.addSubview(sliderCrease)
        
        sliderKnob = UIView(frame: .zero)
        sliderKnob.isUserInteractionEnabled = false
        sliderKnob.backgroundColor = switchState == .on ? onColorKnob : offColorKnob
        self.addSubview(sliderKnob)
        
        sliderCrease.translatesAutoresizingMaskIntoConstraints = false
        sliderKnob.translatesAutoresizingMaskIntoConstraints = false
        
        if let type = switchType {
            
            switch type {
                
            case .ios, .iosImg:
                // creating iOS/iOSImg Switch
                knobCreaseSizeDifference = -2
                
                creaseHeight = height - abs(knobCreaseSizeDifference)
                sliderCrease.backgroundColor = switchState == .on ? onColorCrease : .iOSCreaseBorder
                sliderCrease.layer.masksToBounds = true
                sliderCrease.layer.cornerRadius = (creaseHeight / 2)
                sliderCrease.layer.borderColor = switchState == .on ? onColorCrease.cgColor : UIColor.iOSCreaseBorder.cgColor
                sliderCrease.layer.borderWidth = abs(knobCreaseSizeDifference)
                
                sliderKnobFill = UIView(frame: .zero)
                sliderKnobFill.backgroundColor = .white
                sliderCrease.addSubview(sliderKnobFill)
                sliderKnobFill.layer.cornerRadius = height / 2
                sliderKnobFill.translatesAutoresizingMaskIntoConstraints = false
                sliderKnobFill.heightAnchor.constraint(equalToConstant: height).isActive = true
                sliderKnobFill.widthAnchor.constraint(equalToConstant: width).isActive = true
                sliderKnobFill.transform = switchState == .on ? CGAffineTransform(scaleX: 0.001, y: 0.001) : .identity
                sliderKnobFill.centerXAnchor.constraint(equalTo: sliderCrease.centerXAnchor, constant: 0).isActive = true
                sliderKnobFill.centerYAnchor.constraint(equalTo: sliderCrease.centerYAnchor, constant: 0).isActive = true
                
                // - knobCreaseSizeDifference is subtracted twice to have perfect corner around the knob and crease
                // compansating for the borderWidth of the crease
                knobSize = creaseHeight + knobCreaseSizeDifference * 2
                sliderKnob.layer.cornerRadius = knobSize / 2
                sliderKnob.layer.shadowColor = UIColor.black.cgColor
                sliderKnob.layer.shadowOpacity = 0.30
                sliderKnob.layer.shadowOffset = CGSize(width: 0, height: 2)
                sliderKnob.layer.shadowRadius = 8
                
                if type == .iosImg {
                    if let _ = image {
                        sliderKnobImage = UIImageView(image: image)
                    } else {
                        sliderKnobImage = UIImageView(image: UIImage())
                    }
                    sliderKnob.addSubview(sliderKnobImage)
                    sliderKnobImage.translatesAutoresizingMaskIntoConstraints = false
                    sliderKnobImage.frame = CGRect(x: 0, y: 0, width: knobSize - imgPadding * 2, height: knobSize - imgPadding * 2)
                    sliderKnobImage.layer.masksToBounds = true
                    sliderKnobImage.layer.cornerRadius = sliderKnobImage.frame.height / 2
                    sliderKnobImage.heightAnchor.constraint(equalToConstant: sliderKnobImage.frame.height).isActive = true
                    sliderKnobImage.widthAnchor.constraint(equalToConstant: sliderKnobImage.frame.width).isActive = true
                    sliderKnobImage.centerXAnchor.constraint(equalTo: sliderKnob.centerXAnchor).isActive = true
                    sliderKnobImage.centerYAnchor.constraint(equalTo: sliderKnob.centerYAnchor).isActive = true
                }
                
            case .material:
                // Creating Material Switch
                knobCreaseSizeDifference = 8
                
                creaseHeight = height / 3
                sliderCrease.layer.cornerRadius = creaseHeight / 2
                
                knobSize = creaseHeight + knobCreaseSizeDifference
                sliderKnob.layer.cornerRadius = knobSize / 2
                sliderKnob.layer.shadowColor = UIColor.black.cgColor
                sliderKnob.layer.shadowOpacity = 0.24
                sliderKnob.layer.shadowOffset = CGSize(width: 0, height: 1)
                sliderKnob.layer.shadowRadius = 1
                
                knobTintSizeDifference = 26
                sliderKnobTint = UIView(frame: .zero)
                sliderKnobTint.isUserInteractionEnabled = false
                sliderKnobTint.alpha = 0.3
                sliderKnobTint.layer.cornerRadius = (knobSize + knobTintSizeDifference) / 2
                sliderKnobTint.backgroundColor = switchState == .on ? onColorCrease : offColorCrease
                self.insertSubview(sliderKnobTint, belowSubview: sliderKnob)
                
                sliderKnobTint.translatesAutoresizingMaskIntoConstraints = false
                knobTintWidth = NSLayoutConstraint(item: sliderKnobTint as Any, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 0)
                allConstraints.append(knobTintWidth)
                knobTintHeight = NSLayoutConstraint(item: sliderKnobTint as Any, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 0)
                allConstraints.append(knobTintHeight)
                sliderKnobTint.centerXAnchor.constraint(equalTo: sliderKnob.centerXAnchor).isActive = true
                sliderKnobTint.centerYAnchor.constraint(equalTo: sliderKnob.centerYAnchor).isActive = true
                
            case .rounded:
                // Creating Rounded Switch
                knobCreaseSizeDifference = -10
                
                if let rad = cornerRadius {
                    sliderCrease.layer.cornerRadius = rad
                    sliderKnob.layer.cornerRadius = rad
                } else {
                    sliderCrease.layer.cornerRadius = switchCornerRadius
                    sliderKnob.layer.cornerRadius = switchCornerRadius
                }
                creaseHeight = height
                
                knobSize = creaseHeight + knobCreaseSizeDifference
                sliderKnob.layer.shadowColor = UIColor.black.cgColor
                sliderKnob.layer.shadowOpacity = 0.24
                sliderKnob.layer.shadowOffset = CGSize(width: 0, height: 1)
                sliderKnob.layer.shadowRadius = 1
            }
        }
        
        let views = ["crease": sliderCrease as Any,
                     "knob": sliderKnob as Any]
        
        sliderCrease.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        let creaseX = NSLayoutConstraint.constraints(withVisualFormat: "H:|[crease]|", options: .init(rawValue: 0), metrics: nil, views: views)
        allConstraints += creaseX
        let creaseY = NSLayoutConstraint.constraints(withVisualFormat: "V:[crease(\(creaseHeight!))]",
            options: .alignAllCenterY, metrics: nil, views: views)
        allConstraints += creaseY
        
        sliderKnob.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        knobWidthConstraint = NSLayoutConstraint(item: sliderKnob as Any, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: knobSize)
        allConstraints.append(knobWidthConstraint)
        let knobY = NSLayoutConstraint.constraints(withVisualFormat: "V:[knob(\(knobSize!))]", options: .init(rawValue: 0), metrics: nil, views: views)
        allConstraints += knobY
        
        let sizeDiff:CGFloat = switchType == .rounded ? 2 : 1
        knobLeftConstraint = NSLayoutConstraint(item: sliderKnob as Any, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: switchState == .on ? (width - (knobSize - (knobCreaseSizeDifference/sizeDiff))) : -(knobCreaseSizeDifference/sizeDiff))
        allConstraints.append(knobLeftConstraint)
        
        self.addConstraints(allConstraints)
        self.layoutIfNeeded()
    }
    
    @objc private func tapOnSwitch() {
        let width = self.frame.width
        switchState = switchState == .on ? .off : .on
        let sizeDiff:CGFloat = switchType == .rounded ? 2 : 1
        
        knobLeftConstraint.constant = switchState == .on ? (width - (knobSize - (knobCreaseSizeDifference/sizeDiff))) : -(knobCreaseSizeDifference/sizeDiff)
        
        if let _ = sliderKnobTint {
            knobTintWidth.constant = 0
            knobTintHeight.constant = 0
        }
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
            self.sliderKnob.backgroundColor = self.switchState == .on ? self.onColorKnob : self.offColorKnob
            if self.switchType == .ios || self.switchType == .iosImg {
                self.sliderCrease.layer.borderColor = self.switchState == .on ? self.onColorCrease.cgColor : UIColor.iOSCreaseBorder.cgColor
                self.sliderCrease.backgroundColor = self.switchState == .on ? self.onColorCrease : UIColor.iOSCreaseBorder
            } else {
                self.sliderCrease.backgroundColor = self.switchState == .on ? self.onColorCrease : self.offColorCrease
            }
            self.layoutIfNeeded()
        }, completion: {_ in
            if let _ = self.sliderKnobTint {
                self.sliderKnobTint.backgroundColor = self.switchState == .on ? self.onColorCrease : self.offColorCrease
            }
        })
        delegate?.didToggleSwitch(currentState: switchState)
    }
    
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if let touch = touches.first {
            totalDistanceX = 0
            startLocationX = touch.location(in: self).x
        }
        popKnobTint()
        squeezeKnob()
    }
    
    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        if switchState == .onSuspend {
            switchState = .on
            if let _ = sliderKnobTint {
                knobTintWidth.constant = 0
                knobTintHeight.constant = 0
                UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
                    self.layoutIfNeeded()
                }, completion: {_ in
                    self.sliderKnobTint.backgroundColor = self.onColorCrease
                })
            }
            delegate?.didToggleSwitch(currentState: switchState)
            
        } else if switchState == .offSuspend {
            switchState = .off
            if let _ = sliderKnobTint {
                knobTintWidth.constant = 0
                knobTintHeight.constant = 0
                UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
                    self.layoutIfNeeded()
                }, completion: {_ in
                    self.sliderKnobTint.backgroundColor = self.offColorCrease
                })
            }
            delegate?.didToggleSwitch(currentState: switchState)

        } else {
            shrinkKnobTint()
        }
        releaseKnob()
    }
    
    override public func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        shrinkKnobTint()
        releaseKnob()
    }
    
    override public func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        if let startLocationX = startLocationX, let touch = touches.first {
            let sizeDiff:CGFloat = switchType == .rounded ? 2 : 1

            let currentLocation = touch.location(in: self)
            totalDistanceX = startLocationX - currentLocation.x
            if totalDistanceX < -20 && switchState != .onSuspend {
                switchState = .onSuspend
                if switchType == .ios || switchType == .iosImg {
                    knobLeftConstraint.constant = (self.frame.width - (knobSize - (knobCreaseSizeDifference)) - iosKnobSqueezeValue)
                    sliderCrease.layer.borderColor = self.onColorCrease.cgColor
                } else {
                    knobLeftConstraint.constant = (self.frame.width - (knobSize - (knobCreaseSizeDifference/sizeDiff)))
                }
                UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
                    self.sliderCrease.backgroundColor = self.onColorCrease
                    self.sliderKnob.backgroundColor = self.onColorKnob
                    
                    self.layoutIfNeeded()
                }, completion: nil)
                
            } else if totalDistanceX > 20 && switchState != .offSuspend {
                switchState = .offSuspend                
                knobLeftConstraint.constant = -(knobCreaseSizeDifference/sizeDiff)
                UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
                    if (self.switchType == .ios || self.switchType == .iosImg) {
                        self.sliderCrease.backgroundColor = .iOSCreaseBorder
                        self.sliderCrease.layer.borderColor = self.offColorCrease.cgColor
                    } else {
                        self.sliderCrease.backgroundColor = self.offColorCrease
                    }
                    self.sliderKnob.backgroundColor = self.offColorKnob
                    self.layoutIfNeeded()
                    
                }, completion: nil)
            }
        }
    }
    
    private func shrinkKnobTint() {
        if let _ = sliderKnobTint {
            knobTintWidth.constant = 0
            knobTintHeight.constant = 0
            UIView.animate(withDuration: 0.2, delay: 0, options: [], animations: {
                self.layoutIfNeeded()
            }, completion: nil)
        }
    }
    
    private func popKnobTint() {
        if let _ = sliderKnobTint {
            knobTintWidth.constant = knobSize + knobTintSizeDifference
            knobTintHeight.constant = knobSize + knobTintSizeDifference
            UIView.animate(withDuration: 0.2, delay: 0, options: [], animations: {
                self.layoutIfNeeded()
            }, completion: nil)
        }
    }
    
    private func squeezeKnob() {
        if switchType == .ios || switchType == .iosImg {
            knobWidthConstraint.constant = knobSize + iosKnobSqueezeValue
            if switchState == .on {
                knobLeftConstraint.constant = (self.frame.width - (knobSize - (knobCreaseSizeDifference)) - iosKnobSqueezeValue)
            }
            UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseInOut, animations: {
                self.sliderKnobFill.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
            }, completion: nil)
            UIView.animate(withDuration: 0.2, delay: 0, options: [], animations: {
                self.layoutIfNeeded()
            }, completion: nil)
        }
    }
    
    private func releaseKnob() {
        if switchType == .ios || switchType == .iosImg {
            if switchState == .on {
                knobLeftConstraint.constant = (self.frame.width - (knobSize - (knobCreaseSizeDifference)))
            } else if switchState == .off {
                knobLeftConstraint.constant =  -(knobCreaseSizeDifference)
                UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseInOut, animations: {
                    self.sliderKnobFill.transform = .identity
                }, completion: nil)
            }
            knobWidthConstraint.constant = knobSize
            sliderCrease.layer.borderColor = switchState == .on ? onColorCrease.cgColor : UIColor.iOSCreaseBorder.cgColor
            UIView.animate(withDuration: 0.2, delay: 0, options: [], animations: {
                self.layoutIfNeeded()
            }, completion: nil)
        }
    }
}
