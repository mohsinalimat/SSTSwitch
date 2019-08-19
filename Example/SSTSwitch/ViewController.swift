//
//  ViewController.swift
//  SSTSwitch
//
//  Created by bupstan on 08/19/2019.
//  Copyright (c) 2019 bupstan. All rights reserved.
//

import UIKit
import SSTSwitch

class ViewController: UIViewController {

    @IBOutlet weak var switchOnStoryboard: SSTSwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        switchOnStoryboard.backgroundColor = .clear
        switchOnStoryboard.switchType = .ios
        switchOnStoryboard.delegate = self
        createSSTSwitches()
    }
    
    func createSSTSwitches() {
        let activeColor = UIColor.orange
        let idleColor = UIColor.blue
        
        let customColorMaterialSwitch = SSTSwitch(size: CGSize(width: 50, height: 50),
                                     type: .material,
                                     activeColorKnob: activeColor,
                                     activeColorCrease: activeColor.withAlphaComponent(0.5),
                                     idleColorKnob: idleColor,
                                     idleColorCrease: idleColor.withAlphaComponent(0.5))
        customColorMaterialSwitch.delegate = self
        self.view.addSubview(customColorMaterialSwitch)
        customColorMaterialSwitch.translatesAutoresizingMaskIntoConstraints = false
        customColorMaterialSwitch.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0).isActive = true
        customColorMaterialSwitch.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: 0).isActive = true
        
        let defaultMaterialSwitch = SSTSwitch(size: CGSize(width: 70, height: 50), type: .material)
        defaultMaterialSwitch.delegate = self
        self.view.addSubview(defaultMaterialSwitch)
        defaultMaterialSwitch.translatesAutoresizingMaskIntoConstraints = false
        defaultMaterialSwitch.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0).isActive = true
        defaultMaterialSwitch.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: -100).isActive = true
        
        let iOSSwitch = SSTSwitch(
            type: .ios, state: .on,
            activeColorKnob: .white,
            activeColorCrease: UIColor(red: 52/255, green: 199/255, blue: 89/255, alpha: 1),
            idleColorKnob: UIColor.white,
            idleColorCrease: UIColor(red: 120/255, green: 120/255, blue: 128/255, alpha: 0.16))
        iOSSwitch.delegate = self
        self.view.addSubview(iOSSwitch)
        iOSSwitch.translatesAutoresizingMaskIntoConstraints = false
        iOSSwitch.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0).isActive = true
        iOSSwitch.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: -200).isActive = true
        
        let iOSSwitchImage = SSTSwitch(type: .iosImg, idleColorKnob: UIColor.white, idleColorCrease: UIColor.clear, image: UIImage(named: "grape"))
        iOSSwitchImage.delegate = self
        self.view.addSubview(iOSSwitchImage)
        iOSSwitchImage.translatesAutoresizingMaskIntoConstraints = false
        iOSSwitchImage.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0).isActive = true
        iOSSwitchImage.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: -270).isActive = true
        
        let roundedSwitch = SSTSwitch(size: CGSize(width: 150, height: 100), type: .rounded)
        roundedSwitch.switchCornerRadius = 20
        roundedSwitch.delegate = self
        self.view.addSubview(roundedSwitch)
        roundedSwitch.translatesAutoresizingMaskIntoConstraints = false
        roundedSwitch.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0).isActive = true
        roundedSwitch.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: 120).isActive = true
        
        self.view.layoutIfNeeded()
    }
}

extension ViewController: SSTSwitchDelegate {
    func didToggleSwitch(currentState: SSTSwitchState) {
        print(currentState.label)
    }
}

