//
//  BlurView.swift
//  yatriMitra
//
//  Created by IOS 2 on 12/07/24.
//

import UIKit

class BlurView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLoaderView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupLoaderView()
    }

    private func setupLoaderView() {
        backgroundColor = UIColor(white: 0, alpha: 0.7)
//        layer.cornerRadius = 10
    }
}
