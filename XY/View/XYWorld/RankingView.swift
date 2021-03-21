//
//  RankingView.swift
//  XY
//
//  Created by Maxime Franchot on 21/03/2021.
//

import UIKit

class RankingView: UIView, UITableViewDataSource, UITableViewDataSourcePrefetching {
        
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
    
    private let scoreLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Raleway-Medium", size: 9)
        label.textColor = UIColor(named: "tintColor")
        label.text = "Score"
        return label
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
    
    var models = [RankingCellModel]()
    var ranking: RankingModel?
    var viewModels: [String: NewProfileViewModel?] = [:]
    var rowsToReload = [Int]()
    
    init() {
        super.init(frame: .zero)
        
        backgroundColor = .clear
        
        tableView.dataSource = self
        tableView.prefetchDataSource = self
        
        addSubview(title)
        addSubview(rankLabel)
        addSubview(playerLabel)
        addSubview(scoreLabel)
        addSubview(tableView)
        
        tableView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 10).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
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
        
        scoreLabel.sizeToFit()
        scoreLabel.frame = CGRect(
            x: playerLabel.right + 100,
            y: title.bottom + 12.54,
            width: scoreLabel.width,
            height: scoreLabel.height
        )
        
        tableView.frame = CGRect(
            x: 5,
            y: rankLabel.bottom + 5,
            width: width - 10,
            height: 800
        )
    }
    
    func subscribeToRanking() {
        RankingDatabaseManager.shared.getRanking { (rankingModel) in
            self.ranking = rankingModel
            self.tableView.reloadData()
        } onChange: { (rankingCell) in
            if let indexRow = self.ranking?.ranking.firstIndex(where: {$0.profileID == rankingCell.profileID}) {
                
                if indexRow == rankingCell.rank - 1 {
                    // on score changed
                    let cell = self.tableView.cellForRow(at: IndexPath(row: indexRow, section: 0)) as! RankingTableViewCell
                    
                    cell.updateScore(rankingCell.score)
                }
            }
            
            if self.ranking != nil {
                
                let indexRow = rankingCell.rank - 1
                
                print("Update row at index: \(indexRow) with cell: \(rankingCell)")
                self.ranking!.ranking[indexRow] = rankingCell
                
                if self.rowsToReload.contains(where: {$0 == indexRow-1}) {
                    let indexPaths = (IndexPath(row: indexRow-1, section: 0), IndexPath(row: indexRow, section: 0))
                    
                    self.tableView.moveRow(at: indexPaths.0, to: indexPaths.1)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now()+0.3) {
                        self.tableView.reloadRows(at: [indexPaths.0, indexPaths.1], with: .fade)
                    }
                    
                    self.rowsToReload.removeAll(where: {$0 == indexRow-1})
                } else if self.rowsToReload.contains(where: {$0 == indexRow+1}) {
                    let indexPaths = (IndexPath(row: indexRow+1, section: 0), IndexPath(row: indexRow, section: 0))
                    
                    self.tableView.moveRow(at: indexPaths.0, to: indexPaths.1)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now()+0.3) {
                        self.tableView.reloadRows(at: [indexPaths.0, indexPaths.1], with: .none)
                    }
                    
                    self.rowsToReload.removeAll(where: {$0 == indexRow+1})
                } else {
                    // first arrived
                    self.rowsToReload.append(indexRow)
                }
            }
        } onAdd: { rankingCell in
            if self.ranking != nil, !self.ranking!.ranking.contains(where: {$0.profileID == rankingCell.profileID}) {
                let targetIndex = rankingCell.rank - 1
                
                if self.ranking!.ranking.count > targetIndex {
                    self.ranking!.ranking.insert(rankingCell, at: targetIndex)
                    
                    if targetIndex > 10 {
                        self.tableView.insertRows(at: [IndexPath(row: rankingCell.rank-1, section: 0)], with: .left)
                    } else {
                        self.tableView.reloadRows(at: [IndexPath(row: rankingCell.rank-1, section: 0)], with: .left)
                    }
                } else {
                    self.ranking!.ranking.append(rankingCell)
                    
                    if targetIndex > 10 {
                        self.tableView.insertRows(at: [IndexPath(row: self.ranking!.ranking.count-1, section: 0)], with: .left)
                    } else {
                        self.tableView.reloadRows(at: [IndexPath(row: self.ranking!.ranking.count-1, section: 0)], with: .left)
                    }
                }
            } else {
                self.ranking = RankingModel(name: "Global", ranking: [rankingCell])
                self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .left)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let ranking = ranking else {
            return 10
        }
        return max(ranking.ranking.count, 10)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let ranking = ranking, ranking.ranking.count > indexPath.row else {
            let cell = tableView.dequeueReusableCell(withIdentifier: RankingTableViewCell.identifier) as! RankingTableViewCell
            cell.configureEmpty(rank: indexPath.row + 1)
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: RankingTableViewCell.identifier) as! RankingTableViewCell
        let rankingModel = ranking.ranking[indexPath.row]
        
        if viewModels.contains(where: {$0.key == rankingModel.profileID}),
           let viewModel = viewModels[rankingModel.profileID] ?? nil {
            cell.configure(
                with: viewModel,
                rank: rankingModel.rank,
                score: rankingModel.score
            )
        } else {
            // Fetch
            fetchProfileViewModel(at: indexPath.row)
        }
                
        return cell
    }
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        guard let ranking = ranking else {
            return
        }
        
        for indexPath in indexPaths {
            
            fetchProfileViewModel(at: indexPath.row)
        }
    }
    
    private func fetchProfileViewModel(at indexRow: Int) {
        
        guard let id = ranking?.ranking[indexRow].profileID, !viewModels.contains(where: {$0.key == id}) else {
            return
        }
        
        viewModels[id] = nil
        
        ProfileFirestoreManager.shared.getProfile(forProfileID: id) { (profileModel) in
            if let profileModel = profileModel {
                self.viewModels[id] = ProfileViewModelBuilder.build(
                    with: profileModel, completion: { (profileViewModel) in
                        if let profileViewModel = profileViewModel {
                            self.viewModels[id] = profileViewModel
                            
                            self.tableView.reloadRows(at: [IndexPath(row: indexRow, section: 0)], with: .fade)
                        }
                    })
                
                self.tableView.reloadRows(at: [IndexPath(row: indexRow, section: 0)], with: .fade)
            }
        }
    }
}
