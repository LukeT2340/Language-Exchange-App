//
//  CallUIView.swift
//  Tandy
//
//  Created by Luke Thompson on 6/12/2023.
//

import UIKit

class CallUIView: UIView {
    private let label = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(label)
        label.text = "In Call..."
        label.textAlignment = .center
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = self.bounds
    }
}

