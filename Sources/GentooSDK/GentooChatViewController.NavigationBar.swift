//
//  GentooChatViewController.NavigationBar.swift
//  GentooSDK
//
//  Created by John on 8/7/24.
//

import UIKit

extension GentooChatViewController {
    
    final class NavigationBar: UIView {
        
        let backButton: UIButton = {
            let button = UIButton(type: .system)
            button.setImage(ImageProvider.loadImage(named: "icn_back"), for: .normal)
            button.tintColor = UIColor(hexString: "666666")
            return button
        }()
        
        private let iconView: UIImageView = {
            let imageView = UIImageView()
            imageView.image = ImageProvider.loadImage(named: "gentoo")
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            imageView.layer.cornerRadius = 18
            imageView.layer.borderWidth = 1.0
            imageView.layer.borderColor = UIColor(hexString: "E1E1E1").cgColor
            return imageView
        }()
        
        private let titleLabel: UILabel = {
            let label = UILabel()
            label.text = "젠투"
            label.font = Font.pretendardBold.uiFont(ofSize: 15)
            label.textColor = UIColor(hexString: "222222")
            return label
        }()
        
        private let subtitleLabel: UILabel = {
            let label = UILabel()
            label.text = "술 전문가"
            label.font = Font.pretendardRegular.uiFont(ofSize: 12)
            label.textColor = UIColor(hexString: "666666")
            return label
        }()
        
        private let stackView: UIStackView = {
            let stackView = UIStackView()
            stackView.axis = .vertical
            stackView.alignment = .leading
            return stackView
        }()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            setupView()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private func setupView() {
            addSubview(backButton)
            addSubview(iconView)
            stackView.addArrangedSubview(titleLabel)
            stackView.addArrangedSubview(subtitleLabel)
            addSubview(stackView)
            
            setupConstraints()
        }
        
        private func setupConstraints() {
            backButton.translatesAutoresizingMaskIntoConstraints = false
            iconView.translatesAutoresizingMaskIntoConstraints = false
            stackView.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                backButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
                backButton.centerYAnchor.constraint(equalTo: centerYAnchor),
                backButton.widthAnchor.constraint(equalToConstant: 24),
                backButton.heightAnchor.constraint(equalToConstant: 24),
                
                iconView.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: 16),
                iconView.centerYAnchor.constraint(equalTo: centerYAnchor),
                iconView.widthAnchor.constraint(equalToConstant: 36),
                iconView.heightAnchor.constraint(equalToConstant: 36),
                
                stackView.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 8),
                stackView.centerYAnchor.constraint(equalTo: centerYAnchor)
            ])
        }
    }
}
