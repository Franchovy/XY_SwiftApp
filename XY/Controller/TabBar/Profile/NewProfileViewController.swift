//
//  NewProfileViewController.swift
//  XY
//
//  Created by Maxime Franchot on 18/02/2021.
//

import UIKit

class NewProfileViewController: UIViewController {

    private let pageViewController = UIPageViewController(
        transitionStyle: .scroll,
        navigationOrientation: .vertical,
        options: [:]
    )
    
    private var topScrollIndicator = ScrollIndicator(direction: .up)
    private var bottomScrollIndicator = ScrollIndicator(direction: .down)
    
    private var viewControllers = [UIViewController]()
    
    private var viewModel: NewProfileViewModel?
    
    private var controllerIndex = 0
    
    private let loadingCircle = XPCircleView()
    
    // MARK: - Initialisers
    
    init(profileId: String) {
        super.init(nibName: nil, bundle: nil)
        
        ProfileFirestoreManager.shared.getProfile(forProfileID: profileId) { (profileModel) in
            if let profileModel = profileModel {
                ProfileViewModelBuilder.build(with: profileModel) { (profileViewModel) in
                    if let profileViewModel = profileViewModel {
                        self.configure(with: profileViewModel)
                        self.onLoadedProfile()
                    }
                }
            }
        }
        
        commonInit()
    }
    
    init(userId: String) {
        super.init(nibName: nil, bundle: nil)
        
        ProfileFirestoreManager.shared.getProfileID(forUserID: userId) { (profileId, error) in
            if let error = error {
                print(error)
            } else if let profileId = profileId {
                ProfileFirestoreManager.shared.getProfile(forProfileID: profileId) { (profileModel) in
                    if let profileModel = profileModel {
                        ProfileViewModelBuilder.build(with: profileModel) { (profileViewModel) in
                            if let profileViewModel = profileViewModel {
                                self.configure(with: profileViewModel)
                                self.onLoadedProfile()
                            }
                        }
                    }
                }
            }
        }
        
        commonInit()
    }
    
    private func commonInit() {
        view.addSubview(loadingCircle)
        
        loadingCircle.frame.size = CGSize(width: 50, height: 50)
        loadingCircle.center = view.center
        
        view.backgroundColor = UIColor(named: "Black")
        
        view.addSubview(pageViewController.view)
        addChild(pageViewController)
        
        //pageViewController.didMove(to: self)
        
        view.addSubview(topScrollIndicator)
        view.addSubview(bottomScrollIndicator)
        topScrollIndicator.alpha = 0.0
        bottomScrollIndicator.alpha = 0.0
        topScrollIndicator.delegate = self
        bottomScrollIndicator.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.isTranslucent = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        loadingCircle.setProgress(0.1)
    
        DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
            self.loadingCircle.animateSetProgress(0.2)
            
            DispatchQueue.main.asyncAfter(deadline: .now()+1.0) {
                self.loadingCircle.animateSetProgress(0.9)
                
                DispatchQueue.main.asyncAfter(deadline: .now()+1.0) {
                    self.loadingCircle.animateSetProgress(1.0)
                }
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
            self.bottomScrollIndicator.animate()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let viewModel = viewModel {
            _ProfileManager.shared.cancelListenerFor(userId: viewModel.userId)
        }
        StorageManager.shared.cancelCurrentDownloadTasks()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        topScrollIndicator.frame = CGRect(
            x: 0,
            y: view.safeAreaInsets.top,
            width: view.width,
            height: 67
        )
        
        pageViewController.view.frame = view.bounds
        
        bottomScrollIndicator.frame = CGRect(
            x: 0,
            y: view.bottom - 67,
            width: view.width,
            height: 67
        )
    }
    
    // MARK: - Public Functions
    
    public func onLoadedProfile() {
        loadingCircle.removeFromSuperview()
        
        guard let userID = viewModel?.userId else {
            return
        }
        _ProfileManager.shared.listenToProfileUpdatesFor(userId: userID) { viewModel in
            if let viewModel = viewModel {
                self.configure(with: viewModel)
            }
        }
    }
    
    public func configure(with viewModel: NewProfileViewModel) {
        self.viewModel = viewModel
        
        setUpPageViewController()
        setUpNavBar()
    }
    
    public func setHeroID(forProfileImage id: String) {
        isHeroEnabled = true
        if let headerVC = viewControllers.first as? ProfileHeaderViewController {
            headerVC.setHeroID(forProfileImage: id)
        }
    }
    
    // MARK: - Obj-C Functions
    
    @objc private func openChatButtonPressed() {
        guard let selfId = AuthManager.shared.userId, let viewModel = viewModel else {
            return
        }
        if viewModel.userId == selfId {
            let vc = ProfileHeaderConversationsViewController()
            vc.modalPresentationStyle = .fullScreen
            
            self.navigationController?.pushViewController(vc, animated: true)
            
            ConversationManager.shared.getConversations() { conversationViewModels in
                if let conversationViewModels = conversationViewModels {
                    vc.configure(with: conversationViewModels)
                }
            }
            
        } else {
            let vc = ProfileHeaderChatViewController()
            vc.modalPresentationStyle = .fullScreen
            
            self.navigationController?.pushViewController(vc, animated: true)
            
            ConversationManager.shared.getConversation(with: viewModel.userId) { conversationViewModel, messageViewModels in
                if let conversationViewModel = conversationViewModel, let messageViewModels = messageViewModels {
                    vc.configure(with: conversationViewModel, chatViewModels: messageViewModels)
                } else if conversationViewModel == nil, messageViewModels?.count == 0 {
                    let newConversationViewModel = ConversationViewModelBuilder.new(with: viewModel)
                    vc.configureForNewConversation(with: newConversationViewModel)
                }
                
            }
        }
    }
    
    // MARK: - Private Functions
    
    @objc private func openSettingsButtonPressed() {
        let vc = ProfileHeaderSettingsViewController()
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func setUpNavBar() {
        guard let viewModel = viewModel else {
            return
        }

        if viewModel.userId == AuthManager.shared.userId {
            navigationItem.leftBarButtonItem = UIBarButtonItem(
                image: UIImage(systemName: "gearshape.fill")?.withTintColor(UIColor(named: "tintColor")!, renderingMode: .alwaysOriginal),
                style: .done,
                target: self,
                action: #selector(openSettingsButtonPressed)
            )
            
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                image: UIImage(named: "profile_conversations_icon")?.withRenderingMode(.alwaysOriginal),
                style: .done,
                target: self,
                action: #selector(openChatButtonPressed)
            )
        } else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                image: UIImage(named: "profile_chat_icon")?.withRenderingMode(.alwaysOriginal),
                style: .done,
                target: self,
                action: #selector(openChatButtonPressed)
            )
        }
            
        let titleView = UIView()
        let titleLabel = UILabel()
        titleLabel.font = UIFont(name: "Raleway-ExtraBold", size: 30)
        titleLabel.text = viewModel.nickname
        titleLabel.textColor = UIColor(named: "tintColor")
        titleLabel.adjustsFontSizeToFitWidth = true
        titleView.addSubview(titleLabel)
        
        let xpCircle = CircleView()
        let xpToNextLevel = Float(XPModelManager.shared.getXpForNextLevelOfType(viewModel.level, .user))
        xpCircle.setProgress(level: viewModel.level, progress: Float(viewModel.xp) / xpToNextLevel)
        xpCircle.setupFinished()
        titleView.addSubview(xpCircle)
        
        navigationItem.titleView = titleView

        let xpCircleSize:CGFloat = 25
        
        titleLabel.sizeToFit()
        let titleLabelWidth:CGFloat = min(titleLabel.width, view.width - 200)
        titleLabel.frame = CGRect(
            x: (titleView.width - titleLabelWidth)/2 - (5 + xpCircleSize)/2,
            y: (titleView.height - titleLabel.height)/2,
            width: titleLabelWidth,
            height: titleLabel.height
        )
        
        xpCircle.frame = CGRect(
            x: titleLabel.right + 8,
            y: titleLabel.top + 4,
            width: xpCircleSize,
            height: xpCircleSize
        )
        
        titleView.center.x = view.center.x
        
    }
    
    private func setUpPageViewController() {
        
        guard viewControllers.count == 0 else {
            return
        }
        
        guard let profileViewModel = viewModel else {
            return
        }
        
        let profileHeaderVC = ProfileHeaderViewController()
//        let profileLivePostsVC = ProfileLivePostsViewController()
        let profileCollectionPostsVC = ProfileCollectionViewController()
        
        profileHeaderVC.configure(with: profileViewModel)
        
        viewControllers.append(profileHeaderVC)
//        viewControllers.append(profileLivePostsVC)
        viewControllers.append(profileCollectionPostsVC)
        
        pageViewController.setViewControllers(
            [profileHeaderVC],
            direction: .forward,
            animated: false,
            completion: nil
        )
        
        transitionedToViewController(vc: profileHeaderVC)
        
        pageViewController.dataSource = self
        pageViewController.delegate = self
    }
    
    private func willTransitiontoViewController(vc: UIViewController) {
        UIView.animate(withDuration: 0.2) {
            self.topScrollIndicator.alpha = 0.0
            self.bottomScrollIndicator.alpha = 0.0
        }
        
        if let collectionVC = vc as? ProfileCollectionViewController, let userId = viewModel?.userId {
            // Configure posts collection
            PostFirestoreManager.shared.getPostsByUser(userId: userId) { (postModels, error) in
                if let error = error {
                    print(error)
                } else if let postModels = postModels {
                    collectionVC.configure(with: postModels)
                }
            }
        }
    }
    
    private func transitionedToViewController(vc: UIViewController) {
        controllerIndex = viewControllers.firstIndex(of: vc) ?? 0
        
        self.topScrollIndicator.alpha = 0.0
        self.bottomScrollIndicator.alpha = 0.0
        
        if vc is ProfileHeaderViewController {
            bottomScrollIndicator.setText(text: "Collection")
            
            UIView.animate(withDuration: 0.2) {
                self.bottomScrollIndicator.alpha = 1.0
            }
        } else if vc is ProfileLivePostsViewController {
            topScrollIndicator.setText(text: "Profile")
            bottomScrollIndicator.setText(text: "Collection")
            
            UIView.animate(withDuration: 0.2) {
                self.topScrollIndicator.alpha = 1.0
                self.bottomScrollIndicator.alpha = 1.0
            }
        } else if vc is ProfileCollectionViewController {
            topScrollIndicator.setText(text: "Profile")
                        
            UIView.animate(withDuration: 0.2) {
                self.topScrollIndicator.alpha = 1.0
            }
        }
    }
}

// MARK: - Settings extension

extension NewProfileViewController : ProfileHeaderSettingsViewControllerDelegate {
    func didLogOut() {
        guard let superviewController = view.superview?.parentContainerViewController() as? TabBarViewController else {
            return
        }
        
        superviewController.backToLaunch()
    }
}

// MARK: - Scroll Indicator Extension

extension NewProfileViewController : ScrollIndicatorDelegate {
    func pressedDownDirection() {
        let nextViewController = viewControllers[controllerIndex + 1]
        
        willTransitiontoViewController(vc: nextViewController)
        pageViewController.setViewControllers(
            [nextViewController],
            direction: .forward,
            animated: true,
            completion: { _ in
                self.transitionedToViewController(vc: nextViewController)
            }
        )
        
    }
    
    func pressedUpDirection() {
        
        let nextViewController = viewControllers[controllerIndex - 1]
        
        willTransitiontoViewController(vc: nextViewController)
        pageViewController.setViewControllers(
            [nextViewController],
            direction: .reverse,
            animated: true,
            completion: { _ in
                self.transitionedToViewController(vc: nextViewController)
            }
        )
        
    }
    
    
}


// MARK: - Page VC Extension

extension NewProfileViewController : UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        if finished {
            guard let viewControllers = pageViewController.viewControllers?.filter({ !previousViewControllers.contains($0) }),
                  viewControllers.count > 0 else {
                return
            }
            
            let pageContentViewController = viewControllers[0]
            let index = viewControllers.firstIndex(of: pageContentViewController)
            
            transitionedToViewController(vc: pageContentViewController)
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        UIView.animate(withDuration: 0.2) {
            self.topScrollIndicator.alpha = 0.0
            self.bottomScrollIndicator.alpha = 0.0
        }
        
        pendingViewControllers.forEach({print($0)})
        let pageContentViewController = pendingViewControllers[0]
        
        willTransitiontoViewController(vc: pageContentViewController)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = viewControllers.firstIndex(of: viewController), index != 0 else {
            return nil
        }
        transitionedToViewController(vc: viewControllers[index])

        return viewControllers[index - 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = viewControllers.firstIndex(of: viewController), index < viewControllers.count - 1 else {
            return nil
        }
        
        transitionedToViewController(vc: viewControllers[index])
        
        return viewControllers[index + 1]
    }
}

// MARK: - Scroll Indicator Class

protocol ScrollIndicatorDelegate {
    func pressedDownDirection()
    func pressedUpDirection()
}

class ScrollIndicator : UIView {
    let label: UILabel = {
        let label =  UILabel()
        label.textColor = .white
        label.font = UIFont(name: "Raleway-ExtraBold", size: 15)
        label.textColor = UIColor(named: "tintColor")
        return label
    }()
    let image: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    let icon: UIImageView
    
    enum Direction {
        case up
        case down
    }
    let direction: Direction
    
    var delegate: ScrollIndicatorDelegate?
    
    // MARK: - Initialisers
    
    init(direction: Direction) {
        if direction == .down {
            icon = UIImageView(image: UIImage(named: "profile_arrow_down"))
        } else {
            icon = UIImageView(image: UIImage(named: "profile_arrow_up"))
        }
        self.direction = direction
        
        super.init(frame: .zero)
            
        icon.contentMode = .scaleAspectFit
        icon.tintColor = UIColor(named: "tintColor")
        
        addSubview(icon)
        addSubview(label)
        
        isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onPress))
        addGestureRecognizer(tapGesture)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let iconSize:CGFloat = 40
        
        if direction == .down {
            
            label.sizeToFit()
            label.frame = CGRect(
                x: (width - label.width)/2,
                y: 1,
                width: label.width,
                height: label.height
            )
            
            icon.frame = CGRect(
                x: (width - iconSize)/2,
                y: label.bottom + 4,
                width: iconSize,
                height: iconSize
            )
        } else if direction == .up {
            
            icon.frame = CGRect(
                x: (width - iconSize)/2,
                y: 1,
                width: iconSize,
                height: iconSize
            )
            
            label.sizeToFit()
            label.frame = CGRect(
                x: (width - label.width)/2,
                y: icon.bottom + 4,
                width: label.width,
                height: label.height
            )

        }
    }
    
    // MARK: - Public functions
    
    func animate() {
        DispatchQueue.main.asyncAfter(deadline: .now()+1.0) {
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
                self.icon.frame.origin.y += 5.0
            }) { _ in
                UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: {
                    self.icon.frame.origin.y -= 5.0
                }) { _ in
                    UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
                    self.icon.frame.origin.y += 5.0
                    }) { _ in
                        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: {
                            self.icon.frame.origin.y -= 5.0
                        })
                    }
                }
            }
        }
    }
    
    func setText(text: String) {
        label.text = text
        
        label.sizeToFit()
    }
    
    // MARK: - Obj-C Functions
    
    @objc private func onPress() {
        if direction == .down {
            delegate?.pressedDownDirection()
        } else {
            delegate?.pressedUpDirection()
        }
    }
}
