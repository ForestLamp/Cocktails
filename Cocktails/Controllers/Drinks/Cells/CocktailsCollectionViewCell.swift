//
//  CocktailsCollectionViewCell.swift
//  Cocktails
//
//  Created by Alex Ch. on 29.03.2022.
//

import UIKit
import SnapKit

final class CocktailsCollectionViewCell: UICollectionViewCell {
    
    // MARK: - private properties
    
    private lazy var drinkLabel = UILabel()
    
    private lazy var gradientLayer: CAGradientLayer = {
        let gradient = CAGradientLayer()
        clipsToBounds = true
        gradient.frame = contentView.bounds
        gradient.cornerRadius = 5
        gradient.colors = [UIColor.red.cgColor, UIColor.purple.cgColor]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 0, y: 1)
        return gradient
    }()
    
    // MARK: - public properties
    
    static var cellIdentifier = "CocktailsCollectionViewCell"
    
    // MARK: - override properties
    
    override var isSelected: Bool {
        didSet {
            isSelected ? addGradient() : removeGradient()
        }
    }
    
    // MARK: - override methods
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateGradient()
    }
    
    // MARK: - public methods
    
    func setupCell(drink: DrinkViewModel) {
        createContentView()
        craeateDrinkLabel(drinkLabel, text: drink.model.strDrink)
        isSelected = drink.isChoosen
    }
    
    func updateGradient() {
        gradientLayer.frame = contentView.bounds
    }
    
    // MARK: - private methods
    
    private func addGradient() {
        contentView.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    private func removeGradient() {
        gradientLayer.removeFromSuperlayer()
    }
    
    private func createContentView() {
        contentView.backgroundColor = .systemGray2
        contentView.layer.cornerRadius = 5
    }
    
    private func craeateDrinkLabel(_ label: UILabel, text: String) {
        label.text = text
        label.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        label.font = .systemFont(ofSize: 10)
        contentView.addSubview(label)
        
        label.snp.makeConstraints { make in
            make.right.left.equalToSuperview().inset(5)
            make.centerY.equalToSuperview()
        }
    }
}
