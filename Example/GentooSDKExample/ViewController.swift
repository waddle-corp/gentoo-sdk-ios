//
//  ViewController.swift
//  GentooSampleApp
//
//  Created by USER on 8/6/24.
//

import UIKit
import GentooSDK

class ViewController: UIViewController {
    
    let gentooFloatingButtonView = GentooPresentationFloatingButton()
    let tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        view.addSubview(tableView)
        
        gentooFloatingButtonView.translatesAutoresizingMaskIntoConstraints = false
        gentooFloatingButtonView.itemId = "4895"
        
        view.addSubview(gentooFloatingButtonView)
        
        setupConstraints()
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            gentooFloatingButtonView.widthAnchor.constraint(equalToConstant: 300),
            gentooFloatingButtonView.heightAnchor.constraint(equalToConstant: 54),
            gentooFloatingButtonView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            gentooFloatingButtonView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50)
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
            gentooFloatingButtonView.setContentType(.recommendation)
        }
    }
}
