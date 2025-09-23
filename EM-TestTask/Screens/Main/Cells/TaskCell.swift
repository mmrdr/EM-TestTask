//
//  TaskCell.swift
//  EM-TestTask
//
//  Created by Кирилл Исаев on 23.09.2025.
//

import UIKit

final class TaskCell: UITableViewCell {
    static let cellIdentifier: String = "TaskCell"
    
    private let checkImageView: UIImageView = UIImageView()
    private let titleLabel: UILabel = UILabel()
    private let descriptionLabel: UILabel = UILabel()
    private let dateLabel: UILabel = UILabel()
    private let taskStackView: UIStackView = UIStackView()
    private let line: CAShapeLayer = CAShapeLayer()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureCell()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let y = titleLabel.bounds.midY
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: y))
        path.addLine(to: CGPoint(x: titleLabel.intrinsicContentSize.width, y: y))
        line.path = path.cgPath
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configuration
    func configure(_ task: Task, _ animated: Bool = false) {
        titleLabel.text = task.todo
        descriptionLabel.text = task.description
        dateLabel.text = formatDate(task.createdAt ?? Date.now)
        updateCheckbox(task.completed, animated)
        accessoryType = .none
        selectionStyle = .default
    }
    
    func configureCell() {
        contentView.backgroundColor = Colors.surfacePrimary
        configureCheckImageView()
        configureTaskStackView()
        configureTitleLabel()
        configureDescriptionLabel()
        configureDateLabel()
        configureLine()
    }
    
    private func configureCheckImageView() {
        contentView.addSubview(checkImageView)
        checkImageView.image = UIImage(systemName: "circle")
        checkImageView.image?.withTintColor(Colors.surfaceSecondary)
        checkImageView.tintColor = Colors.surfaceSecondary
        checkImageView.setHeight(24)
        checkImageView.setWidth(24)
        checkImageView.pinLeft(contentView.leadingAnchor, 0)
        checkImageView.pinTop(contentView.topAnchor, 12)
    }
    
    private func configureTaskStackView() {
        contentView.addSubview(taskStackView)
        taskStackView.spacing = 8
        taskStackView.axis = .vertical
        taskStackView.distribution = .fill
        taskStackView.alignment = .fill
        taskStackView.pinTop(contentView.topAnchor, 12)
        taskStackView.pinBottom(contentView.bottomAnchor, 12)
        taskStackView.pinLeft(checkImageView.trailingAnchor, 8)
        taskStackView.pinRight(contentView.trailingAnchor, 16)
        taskStackView.addArrangedSubview(titleLabel)
        taskStackView.addArrangedSubview(descriptionLabel)
        taskStackView.addArrangedSubview(dateLabel)
    }
    
    private func configureTitleLabel() {
        titleLabel.numberOfLines = 0
        titleLabel.font = Fonts.titleFont
        titleLabel.textColor = Colors.textPrimary
    }
    
    private func configureDescriptionLabel() {
        descriptionLabel.numberOfLines = 0
        descriptionLabel.font = Fonts.descriptionFont
        descriptionLabel.textColor = Colors.textPrimary
    }
    
    private func configureDateLabel() {
        dateLabel.font = Fonts.dateFont
        dateLabel.textColor = Colors.textSecondary
    }
    
    private func configureLine() {
        line.fillColor = Colors.textSecondary.cgColor
        line.strokeColor = Colors.textSecondary.cgColor
        line.lineWidth = 1
        line.lineCap = .round
        line.strokeEnd = 0
        titleLabel.layer.addSublayer(line)
    }
    
    private func formatDate(_ date: Date) -> String {
        let calendar = Calendar.current
        
        let dateFormatter = DateFormatter()
        
        if calendar.isDateInToday(date) {
            dateFormatter.timeStyle = .short
            dateFormatter.dateStyle = .none
        } else {
            dateFormatter.dateFormat = "dd/MM/yyyy"
        }
        
        return dateFormatter.string(from: date)
    }
    
    private func updateCheckbox(_ completed: Bool, _ animated: Bool) {
        let name = completed ? "checkmark.circle.fill" : "circle"
        checkImageView.image = UIImage(systemName: name)
        checkImageView.tintColor = completed ? Colors.checkSecondary : Colors.checkPrimary

        let toTitle = completed ? Colors.textSecondary : Colors.textPrimary
        let toDesc  = completed ? Colors.textSecondary : Colors.textPrimary
        let duration: TimeInterval = animated ? 0.28 : 0
        UIView.animate(withDuration: duration) {
            self.titleLabel.textColor = toTitle
            self.descriptionLabel.textColor = toDesc
            self.dateLabel.textColor = Colors.textSecondary
        }
        if animated {
            let anim = CABasicAnimation(keyPath: "strokeEnd")
            anim.fromValue = completed ? 0 : 1
            anim.toValue   = completed ? 1 : 0
            anim.duration  = 0.28
            anim.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            line.strokeEnd = completed ? 1 : 0
            line.add(anim, forKey: "strike")
        } else {
            line.strokeEnd = completed ? 1 : 0
        }
    }
}
