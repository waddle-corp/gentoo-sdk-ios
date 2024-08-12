//
//  GentooFloatingButtonView.swift
//  GentooSDK
//
//  Created by John on 8/7/24.
//

import UIKit

open class GentooFloatingButton: UIControl {
    
    private struct Constants {
        static let buttonContainerCornerRadius: CGFloat = 27
        static let buttonContainerExpandedCornerRadius: CGFloat = 25
        static let floatingButtonWidthCollapsed: CGFloat = 54
        static let floatingButtonHeightCollapsed: CGFloat = 54
        static let floatingButtonWidthExpanded: CGFloat = 40
        static let floatingButtonHeightExpanded: CGFloat = 40
        static let buttonContainerWidthCollapsed: CGFloat = 54
        static let buttonContainerHeightCollapsed: CGFloat = 54
        static let buttonContainerWidthExpanded: CGFloat = 300
        static let buttonContainerHeightExpanded: CGFloat = 50
        static let floatingButtonTrailingCollapsed: CGFloat = 0
        static let floatingButtonTrailingExpanded: CGFloat = -8
        static let labelLeading: CGFloat = 24
        static let minimumWidth: CGFloat = 300
        static let minimumHeight: CGFloat = 54
        static let shadowPathExpanded: CGPath = .init(
            roundedRect: .init(origin: .zero, size: .init(width: 300, height: 50)),
            cornerWidth: 25,
            cornerHeight: 25,
            transform: nil
        )
        static let shadowPathCollapsed: CGPath = .init(
            roundedRect: .init(origin: .zero, size: .init(width: 54, height: 54)),
            cornerWidth: 27,
            cornerHeight: 27,
            transform: nil
        )
        static let animationDuration: TimeInterval = 0.3
    }
    
    private let background: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    
    private let floatingButtonContainerShadow1: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowPath = Constants.shadowPathCollapsed
        view.layer.shadowRadius = 8
        view.layer.shadowOpacity = 0.16
        view.backgroundColor = .clear
        return view
    }()
    
    private let floatingButtonContainerShadow2: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 0)
        view.layer.shadowPath = Constants.shadowPathCollapsed
        view.layer.shadowRadius = 4
        view.layer.shadowOpacity = 0.12
        view.backgroundColor = .clear
        return view
    }()
    
    private let buttonContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = Constants.buttonContainerCornerRadius
        view.layer.borderWidth = 1
        view.clipsToBounds = true
        return view
    }()
    
    private let icon: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(ImageProvider.loadImage(named: "gentoo"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = Constants.buttonContainerCornerRadius
        button.clipsToBounds = true
        button.isUserInteractionEnabled = false
        return button
    }()
    
    private let button: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = Constants.buttonContainerCornerRadius
        button.clipsToBounds = true
        return button
    }()
    
    private let labelMask: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        return view
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.text = "술 전문가 젠투에게 술 추천 받아보세요!"
        label.font = Font.pretendardSemiBold.uiFont(ofSize: 14)
        label.textColor = .darkGray
        label.alpha = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var buttonContainerWidthConstraint: NSLayoutConstraint!
    private var buttonContainerHeightConstraint: NSLayoutConstraint!
    private var floatingButtonWidthConstraint: NSLayoutConstraint!
    private var floatingButtonHeightConstraint: NSLayoutConstraint!
    private var floatingButtonTrailingConstraint: NSLayoutConstraint!
    
    private var expandWorkItem: DispatchWorkItem?
    private var collapseWorkItem: DispatchWorkItem?
    
    private let minimumSize = CGSize(width: Constants.minimumWidth, height: Constants.minimumHeight)
    
    public override var intrinsicContentSize: CGSize {
        return minimumSize
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    open override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        
        expandWorkItem?.cancel()
        collapseWorkItem?.cancel()
        
        if newWindow != nil {
            let now = DispatchTime.now()
            expandWorkItem = DispatchWorkItem { [weak self] in
                self?.expandButton()
            }
            collapseWorkItem = DispatchWorkItem { [weak self] in
                self?.collapseButton()
            }
            DispatchQueue.main.asyncAfter(deadline: now + 1, execute: expandWorkItem!)
            DispatchQueue.main.asyncAfter(deadline: now + 3, execute: collapseWorkItem!)
        }
    }
    
    private func setupViews() {
        
        self.clipsToBounds = false
        
        self.addSubview(background)
    
        background.addSubview(floatingButtonContainerShadow1)
        background.addSubview(floatingButtonContainerShadow2)
        background.addSubview(buttonContainer)
        
        buttonContainer.addSubview(label)
        buttonContainer.addSubview(labelMask)
        buttonContainer.addSubview(icon)
        buttonContainer.addSubview(button)

        setupConstraints()
  
        button.addTarget(self, action: #selector(handleButtonClick), for: .touchUpInside)
    }
    
    @objc private func handleButtonClick() {
        sendActions(for: .touchUpInside)
    }
    
    private func setupConstraints() {
        
        buttonContainerWidthConstraint = buttonContainer.widthAnchor.constraint(equalToConstant: Constants.buttonContainerWidthCollapsed)
        buttonContainerHeightConstraint = buttonContainer.heightAnchor.constraint(equalToConstant: Constants.buttonContainerHeightCollapsed)
        floatingButtonWidthConstraint = icon.widthAnchor.constraint(equalToConstant: Constants.floatingButtonWidthCollapsed)
        floatingButtonHeightConstraint = icon.heightAnchor.constraint(equalToConstant: Constants.floatingButtonHeightCollapsed)
        floatingButtonTrailingConstraint = icon.trailingAnchor.constraint(equalTo: buttonContainer.trailingAnchor)
        
        NSLayoutConstraint.activate([
            
            background.widthAnchor.constraint(greaterThanOrEqualToConstant: Constants.minimumWidth),
            background.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.minimumHeight),
            background.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            background.bottomAnchor.constraint(equalTo: self.bottomAnchor),

            buttonContainerWidthConstraint,
            buttonContainerHeightConstraint,
            
            floatingButtonContainerShadow1.widthAnchor.constraint(equalTo: buttonContainer.widthAnchor),
            floatingButtonContainerShadow1.heightAnchor.constraint(equalTo: buttonContainer.heightAnchor),
            floatingButtonContainerShadow1.centerXAnchor.constraint(equalTo: buttonContainer.centerXAnchor),
            floatingButtonContainerShadow1.centerYAnchor.constraint(equalTo: buttonContainer.centerYAnchor),
            
            floatingButtonContainerShadow2.widthAnchor.constraint(equalTo: buttonContainer.widthAnchor),
            floatingButtonContainerShadow2.heightAnchor.constraint(equalTo: buttonContainer.heightAnchor),
            floatingButtonContainerShadow2.centerXAnchor.constraint(equalTo: buttonContainer.centerXAnchor),
            floatingButtonContainerShadow2.centerYAnchor.constraint(equalTo: buttonContainer.centerYAnchor),
            
            buttonContainer.trailingAnchor.constraint(equalTo: background.trailingAnchor),
            buttonContainer.centerYAnchor.constraint(equalTo: background.centerYAnchor),
            
            button.widthAnchor.constraint(equalTo: buttonContainer.widthAnchor),
            button.heightAnchor.constraint(equalTo: buttonContainer.heightAnchor),
            button.centerXAnchor.constraint(equalTo: buttonContainer.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: buttonContainer.centerYAnchor),
            
            floatingButtonWidthConstraint,
            floatingButtonHeightConstraint,
            floatingButtonTrailingConstraint,
            icon.centerYAnchor.constraint(equalTo: buttonContainer.centerYAnchor),
            
            labelMask.widthAnchor.constraint(equalToConstant: Constants.floatingButtonWidthCollapsed),
            labelMask.heightAnchor.constraint(equalToConstant: Constants.floatingButtonHeightCollapsed),
            labelMask.trailingAnchor.constraint(equalTo: buttonContainer.trailingAnchor),
            labelMask.centerYAnchor.constraint(equalTo: buttonContainer.centerYAnchor),
            
            label.centerYAnchor.constraint(equalTo: buttonContainer.centerYAnchor),
            label.leadingAnchor.constraint(equalTo: buttonContainer.leadingAnchor, constant: Constants.labelLeading)
        ])
    }
    
    private func expandButton() {
        buttonContainerWidthConstraint.constant = Constants.buttonContainerWidthExpanded
        buttonContainerHeightConstraint.constant = Constants.buttonContainerHeightExpanded
        floatingButtonWidthConstraint.constant = Constants.floatingButtonWidthExpanded
        floatingButtonHeightConstraint.constant = Constants.floatingButtonHeightExpanded
        floatingButtonTrailingConstraint.constant = Constants.floatingButtonTrailingExpanded
        UIView.animate(withDuration: Constants.animationDuration, delay: 0, options: .curveEaseInOut) {
            self.layoutIfNeeded()
            self.icon.layer.cornerRadius = Constants.buttonContainerExpandedCornerRadius
            self.floatingButtonContainerShadow1.layer.shadowPath = Constants.shadowPathExpanded
            self.floatingButtonContainerShadow2.layer.shadowPath = Constants.shadowPathExpanded
            self.buttonContainer.layer.cornerRadius = Constants.buttonContainerExpandedCornerRadius
            self.label.alpha = 1
        }
    }
    
    private func collapseButton() {
        buttonContainerWidthConstraint.constant = Constants.buttonContainerWidthCollapsed
        buttonContainerHeightConstraint.constant = Constants.buttonContainerHeightCollapsed
        floatingButtonWidthConstraint.constant = Constants.floatingButtonWidthCollapsed
        floatingButtonHeightConstraint.constant = Constants.floatingButtonHeightCollapsed
        floatingButtonTrailingConstraint.constant = Constants.floatingButtonTrailingCollapsed
        UIView.animate(withDuration: Constants.animationDuration, delay: 0, options: .curveEaseInOut) {
            self.layoutIfNeeded()
            self.icon.layer.cornerRadius = Constants.buttonContainerCornerRadius
            self.floatingButtonContainerShadow1.layer.shadowPath = Constants.shadowPathCollapsed
            self.floatingButtonContainerShadow2.layer.shadowPath = Constants.shadowPathCollapsed
            self.buttonContainer.layer.cornerRadius = Constants.buttonContainerCornerRadius
            self.label.alpha = 0
        }
    }
    
}

