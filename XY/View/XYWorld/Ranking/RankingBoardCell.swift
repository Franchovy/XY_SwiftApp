//
//  RankingBoardCell.swift
//  XY
//
//  Created by Maxime Franchot on 03/03/2021.
//

import UIKit

protocol RankingBoardCellDelegate : class {
    func didTapRankingBoard(with viewModel: RankingViewModel)
}

class RankingBoardCell: UICollectionViewCell, UITableViewDataSource {
    
    static let identifier = "RankingBoardCell"
    
    private let title: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Raleway-Medium", size: 25)
        label.textColor = UIColor(named: "tintColor")
        return label
    }()
    
    private let rankLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Raleway-Medium", size: 9)
        label.textColor = UIColor(named: "tintColor")
        label.text = "Rank"
        return label
    }()
    
    private let playerLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Raleway-Medium", size: 9)
        label.textColor = UIColor(named: "tintColor")
        label.text = "Player"
        return label
    }()
    
    private let levelLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Raleway-Medium", size: 9)
        label.textColor = UIColor(named: "tintColor")
        label.text = "Level"
        return label
    }()
    
    private let indicatorIcon: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "chevron.right"))
        imageView.tintColor = UIColor(named: "XYTint")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(RankingTableViewCell.self, forCellReuseIdentifier: RankingTableViewCell.identifier)
        tableView.isScrollEnabled = false
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.backgroundColor = .clear
        return tableView
    }()
    
    let backgroundLayer = CAShapeLayer()
    let shadowLayer = CAShapeLayer()
    
    var cellViewModels = [RankingCellViewModel]()
    
    var delegate: RankingBoardCellDelegate?
    var viewModel: RankingViewModel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.layer.insertSublayer(shadowLayer, at: 0)
        contentView.layer.insertSublayer(backgroundLayer, at: 0)
        layer.masksToBounds = false
        clipsToBounds = false
        
        tableView.dataSource = self
        contentView.addSubview(title)
        contentView.addSubview(rankLabel)
        contentView.addSubview(playerLabel)
        contentView.addSubview(levelLabel)
        contentView.addSubview(tableView)
        contentView.addSubview(indicatorIcon)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTap))
        contentView.addGestureRecognizer(tapGesture)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        backgroundLayer.frame = bounds
        backgroundLayer.fillColor = UIColor(named: "XYCard")!.cgColor
        backgroundLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: 15).cgPath
        shadowLayer.frame = bounds
        shadowLayer.masksToBounds = false
        shadowLayer.shadowOpacity = 0.8
        shadowLayer.fillColor = backgroundLayer.fillColor
        shadowLayer.shadowColor = UIColor.black.cgColor
        shadowLayer.path = backgroundLayer.path
        shadowLayer.shadowOffset = CGSize(width: 0, height: 3)
        shadowLayer.shadowRadius = 6
        
        indicatorIcon.frame = CGRect(
            x: width - 10.28 - 7.67,
            y: 11.72,
            width: 7.67,
            height: 13.88
        )
        
        title.sizeToFit()
        title.frame = CGRect(
            x: 14.27,
            y: 7.75,
            width: title.width,
            height: title.height
        )
        
        rankLabel.sizeToFit()
        rankLabel.frame = CGRect(
            x: 16.66,
            y: title.bottom + 12.54,
            width: rankLabel.width,
            height: rankLabel.height
        )
        
        playerLabel.sizeToFit()
        playerLabel.frame = CGRect(
            x: rankLabel.right + 84.84,
            y: title.bottom + 12.54,
            width: playerLabel.width,
            height: playerLabel.height
        )
        
        levelLabel.sizeToFit()
        levelLabel.frame = CGRect(
            x: width - 37 - levelLabel.width,
            y: title.bottom + 12.54,
            width: levelLabel.width,
            height: levelLabel.height
        )
        
        tableView.frame = CGRect(
            x: 5,
            y: rankLabel.bottom + 5,
            width: width - 10,
            height: height - (rankLabel.bottom + 5)
        )
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        title.text = ""
        cellViewModels = []
    }
    
    public func configure(with viewModel: RankingViewModel) {
        self.viewModel = viewModel
        title.text = viewModel.name
        cellViewModels = viewModel.cells
        
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellViewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: RankingTableViewCell.identifier) as! RankingTableViewCell
        
        cell.configure(with: cellViewModels[indexPath.row], for: .small)
        
        return cell
    }
    
    @objc private func didTap() {
        let originalTransform = transform
        UIView.animate(withDuration: 0.15) {
            self.transform = originalTransform.scaledBy(x: 0.9, y: 0.9)
        } completion: { (done) in
            if done {
                UIView.animate(withDuration: 0.15) {
                    self.transform = originalTransform
                } completion: { (done) in
                    
                    guard let viewModel = self.viewModel else {
                        return
                    }
                    
                    self.delegate?.didTapRankingBoard(with: viewModel)
                }
            }
        }
    }
}

