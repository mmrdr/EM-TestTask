//
//  MainVC.swift
//  EM-TestTask
//
//  Created by Кирилл Исаев on 23.09.2025.
//

import UIKit

final class MainViewController: UIViewController, MainViewProtocol {
    
    var presenter: MainPresenterProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    private func configureUI() {
        
    }
}
