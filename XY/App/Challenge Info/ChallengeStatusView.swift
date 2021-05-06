//
//  ChallengeStatusView.swift
//  XY
//
//  Created by Maxime Franchot on 06/05/2021.
//

import UIKit

class ChallengeStatusView: UIView {

    private let label = Label(style: .title)
    private let icon = UIImageView()
    
    var status: ChallengeCompletionState?
    
    init() {
        super.init(frame: .zero)
        
        icon.contentMode = .scaleAspectFill
        
        addSubview(icon)
        addSubview(label)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard let status = status else {
            return
        }

        label.sizeToFit()
        label.frame = CGRect(
            x: width - label.width,
            y: (height - label.height)/2,
            width: label.width,
            height: label.height
        )
        
        let iconSize = CGSize(
            width: status == .sent ? 20 : 34,
            height: 20
        )
        icon.frame = CGRect(
            x: width - iconSize.width - 5,
            y: (height - iconSize.height)/2,
            width: iconSize.width,
            height: iconSize.height
        )
    }
    
    
    override func sizeToFit() {
        super.sizeToFit()
        
        switch status {
        case .accepted:
            frame.size = "Accepted".boundingRect(
                with: CGSize(
                    width: CGFloat.greatestFiniteMagnitude,
                    height: .greatestFiniteMagnitude
                ),
                options: .usesLineFragmentOrigin,
                attributes: [.font: label.font!],
                context: nil
            ).size
        case .rejected:
            frame.size = "Rejected".boundingRect(
                with: CGSize(
                    width: CGFloat.greatestFiniteMagnitude,
                    height: .greatestFiniteMagnitude
                ),
                options: .usesLineFragmentOrigin,
                attributes: [.font: label.font!],
                context: nil
            ).size
        case .complete:
            frame.size = "View Reply".boundingRect(
                with: CGSize(
                    width: CGFloat.greatestFiniteMagnitude,
                    height: .greatestFiniteMagnitude
                ),
                options: .usesLineFragmentOrigin,
                attributes: [.font: label.font!],
                context: nil
            ).size
        case .received:
            frame.size = CGSize(width: 34, height: 20)
        case .sent:
            frame.size = CGSize(width: 20, height: 20)
        default:
            break
        }
    }
    
    public func prepareForReuse() {
        label.isHidden = true
        icon.isHidden = true
        
        status = nil
    }
    
    public func configure(with status: ChallengeCompletionState) {
        self.status = status
        
        switch status {
        case .accepted:
            label.isHidden = false
            label.text = "Accepted"
            label.textColor = .XYGreen
        case .rejected:
            label.isHidden = false
            label.text = "Rejected"
            label.textColor = .XYRed
        case .complete:
            label.isHidden = false
            label.text = "View Reply"
            label.textColor = .XYWhite
        case .received:
            icon.isHidden = false
            icon.image = UIImage(named: "double_check_icon")
        case .sent:
            icon.isHidden = false
            icon.image = UIImage(named: "single_check_icon")
        case .expired:
            break
        }
    }
}
