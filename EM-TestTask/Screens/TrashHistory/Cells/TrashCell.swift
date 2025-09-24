//
//  TrashCell.swift
//  EM-TestTask
//
//  Created by Кирилл Исаев on 24.09.2025.
//

import UIKit

final class TrashCell: UITableViewCell {
    static let cellIdentifier: String = "TrashCell"
    
    private let todoLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let dateLabel = UILabel()
    private let taskStackView = UIStackView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configuration
    func configure(_ task: Task) {
        todoLabel.text = task.todo
        descriptionLabel.text = task.description
        dateLabel.text = formatDate(task.createdAt ?? Date.now)
    }
    
    func configureCell() {
        contentView.backgroundColor = Colors.surfaceSecondary
        selectionStyle = .none
        configureTaskStackView()
        configureTodoLabel()
        configureDescriptionLabel()
        configureDateLabel()
    }
    
    private func configureTaskStackView() {
        contentView.addSubview(taskStackView)
        taskStackView.axis = .vertical
        taskStackView.spacing = 4
        
        let topRow = UIStackView(arrangedSubviews: [todoLabel, UIView(), dateLabel])
        topRow.axis = .horizontal
        topRow.alignment = .firstBaseline

        taskStackView.addArrangedSubview(topRow)
        taskStackView.addArrangedSubview(descriptionLabel)
        
        taskStackView.pinTop(contentView.topAnchor, 12)
        taskStackView.pinBottom(contentView.bottomAnchor, 12)
        taskStackView.pinLeft(contentView.leadingAnchor, 16)
        taskStackView.pinRight(contentView.trailingAnchor, 16)
    }
    
    private func configureTodoLabel() {
        todoLabel.font = Fonts.trashTitleFont
        todoLabel.textColor = Colors.textPrimary
        todoLabel.numberOfLines = 1
    }
    
    private func configureDescriptionLabel() {
        descriptionLabel.font = Fonts.trashDescriptionFont
        descriptionLabel.textColor = Colors.textPrimary
        descriptionLabel.numberOfLines = 1
    }
    
    private func configureDateLabel() {
        dateLabel.font = Fonts.trashDateFont
        dateLabel.textColor = Colors.textPrimary
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
}
