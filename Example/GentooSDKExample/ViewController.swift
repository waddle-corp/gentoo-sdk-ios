//
//  ViewController.swift
//  GentooSampleApp
//
//  Created by USER on 8/6/24.
//

import UIKit
import GentooSDK

class SelectionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "Type A (Navigation)"
        case 1:
            cell.textLabel?.text = "Type B (Floating)"
        default:
            break
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            let vc = ViewController()
            vc.buttonType = .navigation
            self.navigationController?.pushViewController(vc, animated: true)
        case 1:
            let vc = ViewController()
            vc.buttonType = .floating
            self.navigationController?.pushViewController(vc, animated: true)
        default:
            break
        }
    }
}

class ViewController: UIViewController {
    
    enum ButtonType {
        case floating
        case navigation
    }
    
    let gentooFloatingButtonView = GentooPresentationFloatingButton()
    let gentooNavigationButtonView = GentooNavigationFloatingButton()
    let tableView = UITableView()
    
    var buttonType: ButtonType = .floating
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        view.addSubview(tableView)
        
        switch buttonType {
        case .floating:
            gentooFloatingButtonView.translatesAutoresizingMaskIntoConstraints = false
            gentooFloatingButtonView.itemId = "4895"
            view.addSubview(gentooFloatingButtonView)
        case .navigation:
            gentooNavigationButtonView.translatesAutoresizingMaskIntoConstraints = false
            gentooNavigationButtonView.itemId = "4895"
            view.addSubview(gentooNavigationButtonView)
        }
        
        setupConstraints()
    }
    
    func setupConstraints() {
        
        let button: UIView
        
        switch buttonType {
        case .floating:
            button = self.gentooFloatingButtonView
        case .navigation:
            button = self.gentooNavigationButtonView
        }
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            button.widthAnchor.constraint(equalToConstant: 300),
            button.heightAnchor.constraint(equalToConstant: 54),
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            button.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50)
        ])
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = "\(indexPath.row + 1)"
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let scrollViewHeight = scrollView.frame.size.height
        
        let percentageScrolled = offsetY / (contentHeight - scrollViewHeight)
        
        // 스크롤 가능 영역의 70% 이상 스크롤 시 ContentType 변경
        if percentageScrolled >= 0.7 {
            switch buttonType {
            case .floating:
                gentooFloatingButtonView.setContentType(.recommendation)
            case .navigation:
                gentooNavigationButtonView.setContentType(.recommendation)
            }
        }
    }
}
