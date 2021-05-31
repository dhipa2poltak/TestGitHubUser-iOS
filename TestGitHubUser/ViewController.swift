//
//  ViewController.swift
//  TestGitHubUser
//
//  Created by user on 30/05/21.
//

import UIKit

class ViewControllerVM: BaseVM {

}

class MainVC: BaseVC {

    lazy var viewModel = ViewControllerVM(vc: self)

    @IBOutlet weak var tfSearch: UITextField!
    @IBOutlet weak var ivSearch: UIImageView!
    @IBOutlet weak var tvUser: UITableView!

    private lazy var refreshControl: UIRefreshControl = {
        let rc = UIRefreshControl()
        rc.addTarget(self,
                     action: #selector(didRefreshControl),
                     for: .valueChanged)
        return rc
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        setupTableView()

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ivSearchTapped(tapGestureRecognizer:)))
        ivSearch.isUserInteractionEnabled = true
        ivSearch.addGestureRecognizer(tapGestureRecognizer)
    }

    private func setupTableView() {
        if #available(iOS 10.0, *) {
            tvUser.refreshControl = refreshControl
        } else {
            tvUser.addSubview(refreshControl)
        }

        tvUser.dataSource = self
        tvUser.delegate = self
        tvUser.backgroundColor = .clear
        tvUser.separatorStyle = .none

        let userTVCNib = UINib(nibName: "UserTVC", bundle: nil)
        tvUser.register(userTVCNib, forCellReuseIdentifier: "UserTVC")
    }

    @objc func ivSearchTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        //let tappedImage = tapGestureRecognizer.view as! UIImageView

        // Your action
        tfSearch.text = "ok"
    }

    /*
    override func viewDidAppear(_: Bool) {
        super.setupNavBar(transparant: true)

        viewModel.loadData(completion: nil)
    }
    */

    @objc private func didRefreshControl() {
        //viewModel.loadData(completion: nil)
    }

    /*
    @objc override func layouting(notification _: NSNotification? = nil) {
        refreshControl.endRefreshing()
        tableVw.reloadData()
    }
    */
}

extension MainVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "UserTVC", for: indexPath) as! UserTVC

        cell.lblUser.text = "Test"

        return cell
    }

    /*
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        let tableViewCell = sender as! UITableViewCell
        let indexPath = tableVw.indexPath(for: tableViewCell)

        if (indexPath?.row ?? -1) != -1 {
            let genre = viewModel.genres?[indexPath!.row]

            let movieByGenreVC = segue.destination as! MovieByGenreVC
            movieByGenreVC.viewModel.genreId = genre?.id ?? -1
            movieByGenreVC.viewModel.genreName = genre?.name ?? "unknown"
        }
    }
    */
}
