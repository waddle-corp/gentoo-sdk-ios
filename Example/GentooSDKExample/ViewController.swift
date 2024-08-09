//
//  ViewController.swift
//  GentooSampleApp
//
//  Created by USER on 8/6/24.
//

import UIKit
import GentooSDK

class ViewController: UIViewController {
    
    let gentooFloatingButtonView = GentooFloatingButton()
    
    let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "mockup")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        view.addSubview(backgroundImageView)
        
        gentooFloatingButtonView.translatesAutoresizingMaskIntoConstraints = false
        gentooFloatingButtonView.addTarget(self, action: #selector(onTap), for: .touchUpInside)

        view.addSubview(gentooFloatingButtonView)
        
        setupConstraints()
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            backgroundImageView.widthAnchor.constraint(equalTo: view.widthAnchor),
            backgroundImageView.heightAnchor.constraint(equalTo: view.heightAnchor),
            backgroundImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            backgroundImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            gentooFloatingButtonView.widthAnchor.constraint(equalToConstant: 300),
            gentooFloatingButtonView.heightAnchor.constraint(equalToConstant: 54),
            gentooFloatingButtonView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            gentooFloatingButtonView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50)
        ])
    }
    
    @objc func onTap() {
        navigationController?.show(GentooChatViewController(), sender: nil)
    }
    
}

