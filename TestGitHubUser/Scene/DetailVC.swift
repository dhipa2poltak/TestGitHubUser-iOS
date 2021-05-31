//
//  DetailVC.swift
//  TestGitHubUser
//
//  Created by user on 30/05/21.
//

import Foundation
import UIKit
import Kingfisher

class DetailVC: BaseVC {
    
    @IBOutlet weak var ivUser: UIImageView!
    @IBOutlet weak var lblUser: UILabel!

    var url = ""
    var username = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        if !url.isEmpty {
            ivUser.kf.setImage(with: URL(string: url))
        }

        lblUser.text = username

        self.navigationController?.navigationBar.isHidden = false

        //self.navigationController?.navigationBar.backgroundColor = UIColor.red//UIColor(hex: "0xFF00BCD4")
    }

    override func viewDidAppear(_: Bool) {
        super.setupNavBar(transparant: true)

        //viewModel.loadData(completion: nil)
    }
}
