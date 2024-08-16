//
//  GentooChatViewController.SheetTopBar.swift
//  GentooSDK
//
//  Created by John on 8/7/24.
//

import UIKit

extension GentooChatViewController {
    
    final class SheetTopBar: UIView {
        
        private let dragHandle: UIView = {
            let handle = UIView()
            handle.backgroundColor = UIColor(hexString: "E1E1E1")
            handle.layer.cornerRadius = 2
            return handle
        }()
        
        let closeButton: UIButton = {
            let button = UIButton(type: .custom)
            button.setImage(ImageProvider.loadImage(named: "icn_close"), for: .normal)
            button.tintColor = UIColor(hexString: "666666")
            return button
        }()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            setupView()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private func setupView() {
            addSubview(dragHandle)
            addSubview(closeButton)
            
            setupConstraints()
        }
        
        private func setupConstraints() {
            dragHandle.translatesAutoresizingMaskIntoConstraints = false
            closeButton.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                dragHandle.centerXAnchor.constraint(equalTo: centerXAnchor),
                dragHandle.topAnchor.constraint(equalTo: topAnchor, constant: 8),
                dragHandle.widthAnchor.constraint(equalToConstant: 44),
                dragHandle.heightAnchor.constraint(equalToConstant: 4),
                
                closeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
                closeButton.centerYAnchor.constraint(equalTo: self.centerYAnchor),
                closeButton.widthAnchor.constraint(equalToConstant: 24),
                closeButton.heightAnchor.constraint(equalToConstant: 24),
            ])
        }
    }
    
}

