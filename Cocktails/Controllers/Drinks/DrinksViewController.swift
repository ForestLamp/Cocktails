//
//  ViewController.swift
//  Cocktails
//
//  Created by Alex Ch. on 28.03.2022.
//

import UIKit
import SnapKit

final class DrinksViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: - private properties
    private let timer = Timer()
    private lazy var textCocktails = UILabel()
    private lazy var drinkCollectionView = UICollectionView()
    private let textFild = UITextField()
    private var bottomTextFiled = UITextField()
    private let cocktailsCollectionViewCell = CocktailsCollectionViewCell()
    private let networkService = NetworkService()
    private var drinks: [DrinkViewModel] = []
    
    // MARK: - Life cicle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        observeTextFiledChanges()
        getDrinks()
        bottomTextFiled.delegate = self
        
    }
    
    // MARK: - Observers
    
    private func observeTextFiledChanges() {
        textFild.addTarget(self, action: #selector(textFieldEditingChanged(textField:)), for: .editingChanged)
        bottomTextFiled.addTarget(self, action: #selector(textDidChanged(textField:)), for: .editingChanged)
        bottomTextFiled.addTarget(self, action: #selector(textFieldEditingChanged(textField:)), for: .editingChanged)
    }
    
    @objc final private func textDidChanged(textField: UITextField)
    {
        if (bottomTextFiled.text) != nil {
            textFild.text = bottomTextFiled.text
        }
    }
    
    @objc final private func textFieldEditingChanged(textField: UITextField) {
        
        guard let seachText = textField.text else {
            return
        }
        searchDrinkWith(name: seachText)
        drinkCollectionView.reloadData()
    }
    
    private func searchDrinkWith(name: String) {
        for drink in drinks {
            if drink.name == name {
                drink.isChoosen = true
            }
        }
    }
    
    private func observeKeyboardChanges(){
        
        NotificationCenter.default.addObserver(self, selector: #selector(DrinksViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(DrinksViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            
            bottomTextFiled.snp.makeConstraints { make in
                make.bottom.equalToSuperview().inset(keyboardSize.height)
            }
        }
        
        textFild.isHidden = true
        bottomTextFiled.isHidden = false
        bottomTextFiled.becomeFirstResponder()
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        textFild.isHidden = false
        bottomTextFiled.isHidden = true
        bottomTextFiled.resignFirstResponder()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ scoreText: UITextField) -> Bool {
        self.bottomTextFiled.endEditing(true)
        bottomTextFiled.resignFirstResponder() // dismiss keyboard
        return true
    }
    
    // MARK: - Private methods
    
    private func setupViews() {
        view.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        tuneLayoutForCollectionView()
        setupCollectionView(drinkCollectionView)
        observeKeyboardChanges()
        setupTextField(textFild)
        setupBottomTextFiled()
    }
    
    private func tuneLayoutForCollectionView () {
        let layout = LeftAlignedCollectionViewFlowLayout()
        drinkCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        self.drinkCollectionView.collectionViewLayout = layout
        
        layout.scrollDirection = .vertical
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        layout.estimatedItemSize = CGSize(width: 100, height: 20)
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    private func setupCollectionView(_ collectionView: UICollectionView) {
        
        collectionView.register(CocktailsCollectionViewCell.self,
                                forCellWithReuseIdentifier: CocktailsCollectionViewCell.cellIdentifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .white
        collectionView.showsVerticalScrollIndicator = false
        
        view.addSubview(collectionView)
        
        collectionView.snp.makeConstraints { make in
            make.height.equalTo(view.frame.height / 2)
            make.top.equalToSuperview().offset(30)
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
        }
        drinkCollectionView.allowsMultipleSelection = true
    }
    
    private func setupTextField(_ textField: UITextField){
        
        textFild.textAlignment = .center
        textFild.placeholder = "Coctail name"
        textFild.addShadowToTextField(cornerRadius: 10)
        textFild.addShadowToTextField(color: .gray, cornerRadius: 10)
        view.addSubview(textField)
        
        textField.snp.makeConstraints { make in
            make.height.equalTo(30)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.bottom.equalToSuperview().offset(-140)
        }
    }
    
    private func setupBottomTextFiled() {
        bottomTextFiled = UITextField(frame: .zero)
        bottomTextFiled.textAlignment = .center
        bottomTextFiled.addShadowToTextField(cornerRadius: 0)
        bottomTextFiled.addShadowToTextField(color: .gray, cornerRadius: 0)
        bottomTextFiled.isHidden = true
        view.addSubview(bottomTextFiled)
        
        bottomTextFiled.snp.makeConstraints { make in
            make.height.equalTo(30)
            make.width.equalToSuperview()
        }
    }
    
    private func getDrinks() {
        networkService.getDrinks { data in
            switch data {
            case .success(let drinks):
                DispatchQueue.main.async {
                    self.drinks = drinks?.drinks.map {
                        DrinkViewModel(model: $0)
                    } ?? []
                    self.drinkCollectionView.reloadData()
                }
            case .failure(_):
                self.showAlertError(text: "Пожалуйста, проверьте соединение")
            }
        }
    }
}

extension DrinksViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return drinks.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CocktailsCollectionViewCell.cellIdentifier, for: indexPath) as? CocktailsCollectionViewCell {
            
            let drink = self.drinks[indexPath.row]
            cell.setupCell(drink: drink)
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? CocktailsCollectionViewCell {
            cell.updateGradient()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        drinks[indexPath.item].isChoosen = true
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        drinks[indexPath.item].isChoosen = false
    }
}

extension DrinksViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout _: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize.zero
    }
}

extension UITextField {
    
    func addShadowToTextField(color: UIColor = .gray, cornerRadius: CGFloat) {
        
        self.backgroundColor = .white
        self.layer.masksToBounds = false
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 3)
        self.layer.shadowOpacity = 1.0
        self.layer.cornerRadius = cornerRadius
    }
}
