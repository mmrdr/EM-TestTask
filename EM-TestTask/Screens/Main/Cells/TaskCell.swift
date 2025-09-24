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
    private let loader: LoadingRingsView = LoadingRingsView()
    private let failButton: UIButton = UIButton(type: .system)
    private let taskStackView: UIStackView = UIStackView()
    var isActive: Bool {
        get {
            failButton.isHidden
        }
    }
    
    var failButtonTapped: (() -> ())?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureCell()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        failButton.isHidden = true
        loader.stop()
        loader.isHidden = true
        checkImageView.image = UIImage(systemName: "circle")
        checkImageView.tintColor = Colors.checkPrimary
        titleLabel.text = nil
        descriptionLabel.text = nil
        dateLabel.text = nil
        titleLabel.textColor = Colors.textPrimary
        descriptionLabel.textColor = Colors.textPrimary
        dateLabel.textColor = Colors.textSecondary
        accessoryType = .none
        selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configuration
    func configure(_ task: Task, _ failedIDs: Set<Int64>, _ animated: Bool = false) {
        titleLabel.text = task.todo
        descriptionLabel.text = task.description
        dateLabel.text = formatDate(task.createdAt ?? Date())

        let hasError = failedIDs.contains(task.id)
        failButton.isHidden = !hasError
        loader.stop()
        loader.isHidden = true

        updateCheckbox(task.completed, animated)
        accessoryType = .none
        selectionStyle = .none
    }
    
    func configureCell() {
        contentView.backgroundColor = Colors.surfacePrimary
        configureCheckImageView()
        configureLoader()
        configureFailButton()
        configureTaskStackView()
        configureTitleLabel()
        configureDescriptionLabel()
        configureDateLabel()
    }
    
    func startAnimation() {
        loader.start()
        failButton.isHidden = true
    }
    
    func stopAnimation() {
        loader.stop()
    }
    
    func showError() {
        failButton.isHidden = false
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
    
    private func configureLoader() {
        contentView.addSubview(loader)
        loader.setHeight(24)
        loader.setWidth(24)
        loader.pinRight(contentView.trailingAnchor, 0)
        loader.pinCenterY(contentView)
    }
    
    private func configureFailButton() {
        contentView.addSubview(failButton)
        failButton.setImage(UIImage(systemName: "exclamationmark.circle"), for: .normal)
        failButton.tintColor = .red
        failButton.setTitleColor(.red, for: .normal)
        failButton.setHeight(24)
        failButton.setWidth(24)
        failButton.pinRight(contentView.trailingAnchor, 0)
        failButton.pinCenterY(contentView)
        failButton.isHidden = true
        failButton.addTarget(self, action: #selector(failButtonPressed), for: .touchUpInside)
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
        taskStackView.pinRight(loader.leadingAnchor, 8)
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
    }
    
    @objc private func failButtonPressed() {
        failButtonTapped?()
    }
}
