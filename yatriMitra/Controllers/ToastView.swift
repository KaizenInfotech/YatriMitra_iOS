//
//  ToastView.swift
//  yatriMitra
//
//  Created by IOS 2 on 09/07/24.
//

import UIKit

extension String {
    func colorFromHex10() -> UIColor {
        let cString:String = self.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}

class ToastView: UIView {
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }()
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 5
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    init(message: String, image: UIImage? = nil) {
        super.init(frame: CGRect.zero)
        configureUI()
        messageLabel.text = message
        iconImageView.image = image
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        backgroundColor = UIColor.white.withAlphaComponent(0.7)
        layer.cornerRadius = 10
        clipsToBounds = true
        
        addSubview(messageLabel)
//        addSubview(iconImageView)
        
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
//            iconImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5),
//            iconImageView.heightAnchor.constraint(equalToConstant: 40),
//            iconImageView.widthAnchor.constraint(equalToConstant: 40),
//            iconImageView.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            
            messageLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5),
            messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
            messageLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])
    }
    
    func show(in view: UIView, duration: TimeInterval = 2, constraint: CGFloat) {
        view.addSubview(self)
        
        messageLabel.sizeToFit()
        let labelWidth = messageLabel.intrinsicContentSize.width
        
        translatesAutoresizingMaskIntoConstraints = false
        let centerXConstraint = NSLayoutConstraint(item: self,
                                                   attribute: .centerX,
                                                   relatedBy: .equal,
                                                   toItem: view,
                                                   attribute: .centerX,
                                                   multiplier: 1.0,
                                                   constant: 0.0)
        
        // Add the constraint to the view
        view.addConstraint(centerXConstraint)
        
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: labelWidth + 50),
            heightAnchor.constraint(equalToConstant: 50),
            bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: constraint)
        ])
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            self.alpha = 1.0
        }, completion: { _ in
            UIView.animate(withDuration: 0.3, delay: duration, options: .curveEaseInOut, animations: {
                self.alpha = 0.0
            }, completion: { _ in
                self.removeFromSuperview()
            })
        })
    }
}
