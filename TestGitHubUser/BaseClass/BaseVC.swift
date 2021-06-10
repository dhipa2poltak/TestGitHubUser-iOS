//
//  BaseVC.swift
//  TestGitHubUser
//
//  Created by user on 30/05/21.
//

import Foundation

import UIKit

class BaseVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
    }

    func setupNavBar(transparant: Bool) {
        guard let navController = navigationController else { return }

        navController.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.black,
                                                           .font: UIFont.preferredFont(forTextStyle: .title1) /* FontFamily.Calibri.bold.font(size: 20) as Any */ ]

        if navController.viewControllers.count > 1 {
            let image = UIImage(named: "ic_back_white")

            navigationItem.leftBarButtonItem = UIBarButtonItem(
                image: image,
                style: .plain,
                target: self,
                action: #selector(didTapBack(_:))
            )
        }

        navController.navigationBar.backgroundColor = UIColor(hex: "0x00BCD4")
        navController.navigationBar.barTintColor = UIColor(hex: "0x00BCD4")
        navController.navigationBar.tintColor = .white

        let label:UILabel = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: view.frame.size.width - 20, height: 30))
        label.text = "Profile"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 20)
        label.textAlignment = .left

        self.navigationItem.titleView = label
    }

    @objc func didTapBack(_: Any) {
        navigationController?.popViewController(animated: true)
    }
}
