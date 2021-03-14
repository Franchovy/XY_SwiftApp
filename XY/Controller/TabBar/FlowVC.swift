//
//  FlowVC.swift
//  XY_APP
//
//  Created by Maxime Franchot on 06/01/2021.
//

import UIKit
import Firebase
import ImagePicker


class FlowVC : UITableViewController {

    // MARK: - Properties

    var postViewModels = [NewPostViewModel]()

    let barXPCircle = CircleView()

    private let errorLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "HelveticaNeue", size: 21)
        label.textColor = UIColor(named: "tintColor")
        label.text = "Error fetching Flow!"
        return label
    }()

    /// Index of fetch, for loading posts that come from the same user
    var currentFlowIndex: Int = 0

    var canRefresh = true

    init() {
        super.init(nibName: nil, bundle: nil)

        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: barXPCircle)
        navigationItem.titleView = UIImageView(image: UIImage(named: "XYNavbarLogo"))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        view.backgroundColor = UIColor(named: "Black")

        tableView.showsVerticalScrollIndicator = false

        barXPCircle.setProgress(level: 0, progress: 0.0)
        barXPCircle.setupFinished()
        barXPCircle.setLevelLabelFontSize(size: 24)
        barXPCircle.registerXPUpdates(for: .ownUser)

        let tap = UITapGestureRecognizer(target: self, action: #selector(xpButtonPressed))
        barXPCircle.addGestureRecognizer(tap)

        view.addSubview(errorLabel)

        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(flowRefreshed(_:)), for: .valueChanged)
        self.refreshControl = refreshControl

        tableView.register(ImagePostCell.self, forCellReuseIdentifier: ImagePostCell.identifier)

        isHeroEnabled = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        errorLabel.isHidden = true

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.isNavigationBarHidden = true
        barXPCircle.registerXPUpdates(for: .ownUser)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
        StorageManager.shared.cancelCurrentDownloadTasks()

        barXPCircle.deregisterUpdates()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        if let uid = Auth.auth().currentUser?.uid {
            FirebaseSubscriptionManager.shared.deactivateXPUpdates(for: uid)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        barXPCircle.frame.size = CGSize(width: 25, height: 25)

        errorLabel.sizeToFit()
        errorLabel.frame = CGRect(
            x: (view.width - errorLabel.width)/2,
            y: view.top + 35,
            width: errorLabel.width,
            height: errorLabel.height
        )
    }

    // MARK: - Obj-C Functions
    @objc func xpButtonPressed() {
        let vc = NotificationsVC()
        vc.isHeroEnabled = true
        vc.modalPresentationStyle = .fullScreen
        vc.heroModalAnimationType = .pageIn(direction: .left)
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc func flowRefreshed(_ sender: UIRefreshControl) {

//        StorageManager.shared.cancelCurrentDownloadTasks()

        FlowAlgorithmManager.shared.algorithmIndex += 1

        DispatchQueue.main.asyncAfter(deadline: .now()+3.0) {
            self.refreshControl?.endRefreshing()
        }
    }
}

