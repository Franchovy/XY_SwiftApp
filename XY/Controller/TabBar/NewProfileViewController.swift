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
    
    // MARK: - Initialisers
    
    init(userId: String) {
        super.init(nibName: nil, bundle: nil)
        
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
        
        ProfileManager.shared.fetchProfile(userId: userId) { result in
            switch result {
            case .success(let profileModel):
                ProfileViewModelBuilder.build(with: profileModel) { (profileViewModel) in
                    if let profileViewModel = profileViewModel {
                        self.configure(with: profileViewModel)
                    }
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
    
    public func configure(with viewModel: NewProfileViewModel) {
        self.viewModel = viewModel
        
        setUpPageViewController()
        setUpNavBar()
    }
    
    // MARK: - Obj-C Functions
    
    @objc private func openChatButtonPressed() {
        guard let selfId = AuthManager.shared.userId, let viewModel = viewModel else {
            return
        }
        if viewModel.userId == selfId {
            let vc = ProfileHeaderConversationsViewController()
            vc.modalPresentationStyle = .fullScreen
            
            ConversationManager.shared.getConversations() { conversationViewModels in
                if let conversationViewModels = conversationViewModels {
                    vc.configure(with: conversationViewModels)
                }
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
        } else {
            let vc = ProfileHeaderChatViewController()
            vc.modalPresentationStyle = .fullScreen
            
            ConversationManager.shared.getConversation(with: viewModel.userId) { conversationViewModel, messageViewModels in
                if let conversationViewModel = conversationViewModel, let messageViewModels = messageViewModels {
                    vc.configure(with: conversationViewModel, chatViewModels: messageViewModels)
                } else if conversationViewModel == nil, messageViewModels?.count == 0 {
                    vc.configureForNewConversation(with: viewModel.userId)
                }
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    // MARK: - Private Functions
    
    @objc private func openSettingsButtonPressed() {
        let vc = ProfileHeaderSettingsViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func setUpNavBar() {
        guard let viewModel = viewModel else {
            return
        }

        if viewModel.userId == AuthManager.shared.userId {
            navigationItem.leftBarButtonItem = UIBarButtonItem(
                image: UIImage(systemName: "gearshape.fill"),
                style: .done,
                target: self,
                action: #selector(openSettingsButtonPressed)
            )
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(named: "profile_conversations_icon"),
            style: .done,
            target: self,
            action: #selector(openChatButtonPressed)
        )
            
        let titleView = UIView()
        let titleLabel = UILabel()
        titleLabel.font = UIFont(name: "Raleway-ExtraBold", size: 30)
        titleLabel.text = viewModel.nickname
        titleLabel.textColor = .white
        titleView.addSubview(titleLabel)
        
        
        let xpCircle = CircleView()
        let xpToNextLevel = Float(XPModelManager.shared.getXpForNextLevelOfType(viewModel.level, .user))
        xpCircle.setProgress(level: viewModel.level, progress: Float(viewModel.xp) / xpToNextLevel)
        xpCircle.setupFinished()
        titleView.addSubview(xpCircle)
        
        titleView.frame = CGRect(
            x: 0,
            y: 0,
            width: 400,
            height: 45
        )
        let xpCircleSize:CGFloat = 25
        
        titleLabel.sizeToFit()
        titleLabel.frame = CGRect(
            x: (titleView.width - titleLabel.width)/2 - 8 - xpCircleSize,
            y: (titleView.height - titleLabel.height)/2,
            width: titleLabel.width,
            height: titleLabel.height
        )
        
        xpCircle.frame = CGRect(
            x: titleLabel.right + 8,
            y: titleLabel.top + (titleView.height - xpCircleSize)/2 - 5,
            width: xpCircleSize,
            height: xpCircleSize
        )
        
        navigationItem.titleView = titleView
            
        
    }
    
    private func setUpPageViewController() {
        
        guard let profileViewModel = viewModel else {
            return
        }
        
        let profileHeaderVC = ProfileHeaderViewController()
        let profileLivePostsVC = ProfileLivePostsViewController()
        let profileCollectionPostsVC = ProfileCollectionViewController()
        
        profileHeaderVC.configure(with: profileViewModel)
        
        viewControllers.append(profileHeaderVC)
        viewControllers.append(profileLivePostsVC)
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
        
        // Configure posts collection
        FirebaseDownload.getFlowForProfile(userId: profileViewModel.userId) { (postModels, error) in
            if let error = error {
                print(error)
            } else if let postModels = postModels {
                profileCollectionPostsVC.configure(with: postModels)
            }
        }
    }
    
    private func willTransitiontoViewController(vc: UIViewController) {
        UIView.animate(withDuration: 0.2) {
            self.topScrollIndicator.alpha = 0.0
            self.bottomScrollIndicator.alpha = 0.0
        }
    }
    
    private func transitionedToViewController(vc: UIViewController) {
        if let vc = vc as? ProfileHeaderViewController {
            bottomScrollIndicator.setText(text: "Live Posts")
            
            UIView.animate(withDuration: 0.2) {
                self.bottomScrollIndicator.alpha = 1.0
            }
        } else if let vc = vc as? ProfileLivePostsViewController {
            topScrollIndicator.setText(text: "Profile")
            bottomScrollIndicator.setText(text: "Collection")
            
            UIView.animate(withDuration: 0.2) {
                self.topScrollIndicator.alpha = 1.0
                self.bottomScrollIndicator.alpha = 1.0
            }
        } else if let vc = vc as? ProfileCollectionViewController {
            topScrollIndicator.setText(text: "Live Posts")
                        
            UIView.animate(withDuration: 0.2) {
                self.topScrollIndicator.alpha = 1.0
            }
        }
    }
}

// MARK: - Scroll Indicator Extension

extension NewProfileViewController : ScrollIndicatorDelegate {
    func pressedDownDirection() {
//        guard let vc = pageViewController.viewControllers?.first,
//              let currentIndex = viewControllers.firstIndex(of: vc) else {
//            return
//        }
//        let nextViewController = viewControllers[currentIndex + 1]
//        willTransitiontoViewController(vc: nextViewController)
//        pageViewController.setViewControllers(
//            [nextViewController],
//            direction: .forward,
//            animated: true,
//            completion: { _ in
//                self.transitionedToViewController(vc: nextViewController)
//            }
//        )
        
    }
    
    func pressedUpDirection() {
//        guard let vc = pageViewController.viewControllers?.first,
//              let currentIndex = viewControllers.firstIndex(of: vc) else {
//            return
//        }
//        let nextViewController = viewControllers[currentIndex - 1]
//        willTransitiontoViewController(vc: nextViewController)
//        pageViewController.setViewControllers(
//            [nextViewController],
//            direction: .reverse,
//            animated: true,
//            completion: { _ in
//                self.transitionedToViewController(vc: nextViewController)
//            }
//        )
        
    }
}

// MARK: - Page VC Extension

extension NewProfileViewController : UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if finished {
            let pageContentViewController = pageViewController.viewControllers![0]
            
            let index = viewControllers.firstIndex(of: pageContentViewController)
            
            transitionedToViewController(vc: pageContentViewController)
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        UIView.animate(withDuration: 0.2) {
            self.topScrollIndicator.alpha = 0.0
            self.bottomScrollIndicator.alpha = 0.0
        }
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
        label.font = UIFont(name: "Raleway-ExtraBold", size: 20)
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
            icon = UIImageView(image: UIImage(systemName: "arrowtriangle.down.fill"))
        } else {
            icon = UIImageView(image: UIImage(systemName: "arrowtriangle.up.fill"))
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
        
        let iconSize:CGFloat = 25
        
        if direction == .down {
            icon.frame = CGRect(
                x: (width - iconSize)/2,
                y: 0,
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
        } else if direction == .up {
            
            label.sizeToFit()
            label.frame = CGRect(
                x: (width - label.width)/2,
                y: 0,
                width: label.width,
                height: label.height
            )
            
            icon.frame = CGRect(
                x: (width - iconSize)/2,
                y: label.bottom + 4,
                width: iconSize,
                height: iconSize
            )

        }
    }
    
    // MARK: - Public functions
    
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
