//
//  SettingTableViewCell.swift
//  Alarm Clock App
//
//  Created by Shania Joseph on 5/21/21.
//

import UIKit

class SettingTableViewCell: UITableViewCell {
    static let identifier = "SettingsCell"
    
    private let iconContainer: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        return view
    }()
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(label)
        contentView.addSubview(iconContainer)
        iconContainer.addSubview(iconImageView)
        contentView.clipsToBounds = true
        accessoryType = .disclosureIndicator
    }
    
    required init?(coder: NSCoder) {
        print(Error.self)
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let size: CGFloat = contentView.frame.size.height - 12
        iconContainer.frame = CGRect(x: 10, y: 6,width: size, height: size)
        
        let imageSize: CGFloat = size/1.5
        iconImageView.frame = CGRect(x: 0, y: 0, width: imageSize, height: imageSize)
        iconImageView.center = iconContainer.center
        
        label.frame = CGRect(x: 15 + iconContainer.frame.size.width,
                             y: 0,
                             width: contentView.frame.size.width - 15 - iconContainer.frame.size.width,
                             height: contentView.frame.size.height)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        iconImageView.image = nil
        label.text = nil
        iconContainer.backgroundColor = nil
    }
    
    public func configure(with model: SettingsOption) {
        label.text = model.title
        iconImageView.image = model.icon
        iconContainer.backgroundColor = model.iconBackgroundColor
    }
}
