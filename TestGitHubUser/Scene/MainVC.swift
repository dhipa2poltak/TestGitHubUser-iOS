//
//  ViewController.swift
//  TestGitHubUser
//
//  Created by user on 30/05/21.
//

import UIKit
import Kingfisher

class MainVC: BaseVC {

    lazy var viewModel = MainVM(vc: self)

    @IBOutlet weak var tfSearch: UITextField!
    @IBOutlet weak var ivSearch: UIImageView!
    @IBOutlet weak var tvUser: UITableView!

    @IBOutlet weak var lblNoData: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        setupTableView()
        setupUIListener()
        setupCoreData()

        viewModel.initViewModel()

        lblNoData.isHidden = !viewModel.isShowNoData

        NotificationCenter.default.addObserver(self, selector: #selector(onResume), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onPause), name: UIApplication.willResignActiveNotification, object: nil)
    }

    private func setupTableView() {
        tvUser.dataSource = self
        tvUser.delegate = self
        tvUser.backgroundColor = .clear
        tvUser.separatorStyle = .none

        let userTVCNib = UINib(nibName: "UserTVC", bundle: nil)
        tvUser.register(userTVCNib, forCellReuseIdentifier: "UserTVC")

        let historyTVCNib = UINib(nibName: "HistoryTVC", bundle: nil)
        tvUser.register(historyTVCNib, forCellReuseIdentifier: "HistoryTVC")
    }

    private func setupUIListener() {
        tfSearch.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)


        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ivSearchTapped(tapGestureRecognizer:)))
        ivSearch.isUserInteractionEnabled = true
        ivSearch.addGestureRecognizer(tapGestureRecognizer)
    }

    private func setupCoreData() {
        let managedObjectContext = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
        if let managedObjectContext = managedObjectContext {
            viewModel.managedObjectContext = managedObjectContext
        }
    }

    @objc func textFieldDidChange(_ textField: UITextField) {
        viewModel.searchText = textField.text ?? ""
        viewModel.isNewSearch = true
        viewModel.isAllDataLoaded = false

        if viewModel.searchText.isEmpty {
            viewModel.users.removeAll()
            viewModel.page = 1

            viewModel.isShowHistory = true
            viewModel.isShowNoData = false

            lblNoData.isHidden = !viewModel.isShowNoData
            tvUser.reloadData()
        }
    }

    @objc func ivSearchTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        viewModel.processInputUserName()
    }

    /*
    override func viewDidAppear(_: Bool) {
        //super.setupNavBar(transparant: true)
    }
    */

    @objc override func layouting(notification _: NSNotification? = nil) {
        lblNoData.isHidden = !viewModel.isShowNoData
        tvUser.reloadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.backgroundColor = UIColor(hex: "0x00BCD4")
        self.navigationController?.navigationBar.barTintColor = UIColor(hex: "0x00BCD4")

        changeStatusBarColor()

        self.navigationController?.navigationBar.isHidden = true
    }
    @objc func onResume() {
        self.navigationController?.navigationBar.isHidden = true
    }
    @objc func onPause() {

    }

    private func changeStatusBarColor() {
        if #available(iOS 13.0, *) {
            let app = UIApplication.shared
            let statusBarHeight: CGFloat = app.statusBarFrame.size.height

            let statusbarView = UIView()
            statusbarView.backgroundColor = UIColor(hex: "0x00BCD4")
            view.addSubview(statusbarView)

            statusbarView.translatesAutoresizingMaskIntoConstraints = false
            statusbarView.heightAnchor
                .constraint(equalToConstant: statusBarHeight).isActive = true
            statusbarView.widthAnchor
                .constraint(equalTo: view.widthAnchor, multiplier: 1.0).isActive = true
            statusbarView.topAnchor
                .constraint(equalTo: view.topAnchor).isActive = true
            statusbarView.centerXAnchor
                .constraint(equalTo: view.centerXAnchor).isActive = true

        } else {
            let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView
            statusBar?.backgroundColor = UIColor(hex: "0x00BCD4")
        }

    }
}

extension MainVC: UIScrollViewDelegate {
    func scrollViewWillEndDragging(_ scrollView: UIScrollView,
                                       withVelocity _: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {

        let distance = scrollView.contentSize.height - (targetContentOffset.pointee.y + scrollView.bounds.height)

        if distance < 200 {
            viewModel.searchUsers(q: viewModel.searchText, page: viewModel.page + 1)
        }
    }
}

extension MainVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if viewModel.isShowHistory {
            return viewModel.histories?.count ?? 0
        }

        return viewModel.users.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if viewModel.isShowHistory {
            let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryTVC", for: indexPath) as! HistoryTVC

            let history = viewModel.histories?[indexPath.row]
            if let sHistory = history?.history {
                cell.lblHistory.text = sHistory
            }

            return cell
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: "UserTVC", for: indexPath) as! UserTVC

        let user = viewModel.users[indexPath.row]
        cell.lblUser.text = user.login

        if let avatarUrl = user.avatarUrl {
            cell.ivUser.kf.setImage(with: URL(string: avatarUrl))
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if viewModel.isShowHistory {
            if let history = viewModel.histories?[indexPath.row] {
                tfSearch.text = history.history
                viewModel.searchText = history.history ?? ""
                viewModel.processInputUserName()
            }
        } else {
            let user = viewModel.users[indexPath.row]

            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let detailVC = storyBoard.instantiateViewController(withIdentifier: "detailVC") as! DetailVC

            detailVC.url = user.avatarUrl ?? ""
            detailVC.username = user.login ?? ""

            self.navigationController?.pushViewController(detailVC, animated: true)
        }
    }
}
