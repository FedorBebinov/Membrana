//
//  OnboardingViewController.swift
//  Membrana
//
//  Created by Fedor Bebinov on 28.03.23.
//

import UIKit

enum InfoViewType {
    case addUsernameView
    case getConnectionView
    case changeUsername
}

class InfoViewController: UIViewController {
    
    let username = UITextField()
    let hintLabel = UILabel()
    let continueButton = UIButton(type: .system)
    let type: InfoViewType
    let placeHolderText: String
    let buttonText: String
    
    let service: InfoVCService
    
    init(type: InfoViewType) {
        self.type = type
        let networkManager = NetworkManager()
        self.service = InfoVCService(networkManager: networkManager)
        
        switch type {
        case .addUsernameView:
            self.placeHolderText = "Создайте Никнейм"
            self.buttonText = "Продолжитъ"
        case .getConnectionView:
            self.placeHolderText = "Никнейм друга"
            self.buttonText = "Создать Мембрану"
        case .changeUsername:
            self.placeHolderText = "Новый Никнейм"
            self.buttonText = "Поменять"
        }
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Закрыть", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        setUpGestures()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        username.text = nil
    }
    
    @objc func buttonTapped(sender: UIButton!) {
        switch type {
        case .getConnectionView:
            guard let connectWithUser = username.text,
                  let username = UserDefaults.standard.string(forKey: "username") else { return }
            
            let mainVC = MainViewController()
            service.connectWithUser(username: username, withUser: connectWithUser) { [weak mainVC] resp, error in
                if error != nil  {
                    self.showAlert(title: "Ошибка при подключении", message: error?.localizedDescription ?? "")
                }
                
                if resp != nil {
                    UserDefaults.standard.set(connectWithUser, forKey: "connectWithUser")
                    self.navigationController?.pushViewController(mainVC ?? MainViewController(), animated: true)
                }
            }
            
            
        case .addUsernameView:
            guard let usernameText = username.text else { return }
            service.postUserNameRegister(username: usernameText) { [weak self] resp, error in
                guard let self else { return }
                if error != nil  {
                    self.animateHintLabel()
                }
                
                if resp != nil {
                    UserDefaults.standard.set(usernameText, forKey: "username")
                    self.navigationController?.pushViewController(InfoViewController(type: .getConnectionView), animated: true)
                }
            }
            
        case .changeUsername:
            guard let newUserName = username.text,
                  let userName = UserDefaults.standard.string(forKey: "username") else { return }
            
            service.editUserName(username: userName, newUserName: newUserName) { [weak self] resp, error in
                guard let self else { return }
                if error != nil  {
                    self.animateHintLabel()
                }
                
                if resp != nil {
                    UserDefaults.standard.set(newUserName, forKey: "username")
                    if !UserDefaults.standard.bool(forKey: "changeUsernameAddedFirstTime") {
                        let infoVC = self.navigationController?.viewControllers[1] as! InfoViewController
                        self.navigationController?.popToViewController(infoVC, animated: true)
                        UserDefaults.standard.set(true, forKey: "changeUsernameAddedFirstTime")
                    } else {
                        self.navigationController?.popToRootViewController(animated: true)
                    }
                }
            }
        }
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func animateHintLabel() {
        UIView.animate(withDuration: 2, animations : {
            self.hintLabel.alpha = 1
        }) { _ in
            UIView.animate(withDuration: 1, animations : {
                self.hintLabel.alpha = 0
            })
        }
    }
    
    private func setUpGestures() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        continueButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }
    
    private func setUpView() {
        view.backgroundColor = Colors.gray_23
        username.delegate = self
        
        username.attributedPlaceholder = NSAttributedString(
            string: placeHolderText,
            attributes: [
                .foregroundColor: Colors.gray_100 ?? .gray,
                .font: UIFont.systemFont(ofSize: 30)]
        )
        
        username.tintColor = .white
        username.textColor = .white
        username.font = .systemFont(ofSize: 30)
        username.textAlignment = .center
        username.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(username)
        username.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        username.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: -16).isActive = true
        username.heightAnchor.constraint(equalToConstant: 30).isActive = true
        username.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 16).isActive = true
        
        hintLabel.attributedText = NSAttributedString(
            string: "Такой никнейм уже сушествует",
            attributes: [
                .foregroundColor: Colors.gray_100 ?? .gray,
                .font: UIFont.systemFont(ofSize: 20)]
        )
        
        hintLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(hintLabel)
        hintLabel.centerXAnchor.constraint(equalTo: username.centerXAnchor).isActive = true
        hintLabel.topAnchor.constraint(equalTo: username.bottomAnchor, constant: 10).isActive = true
        hintLabel.alpha = 0
        
        continueButton.isEnabled = false
        continueButton.setTitle(buttonText, for: .normal)
        setUpContinueButton(isEnabled: false)
        
        continueButton.layer.cornerRadius = 20
        continueButton.layer.masksToBounds = true
        continueButton.translatesAutoresizingMaskIntoConstraints = false
        continueButton.titleLabel?.font = .systemFont(ofSize: 17)
        
        view.addSubview(continueButton)
        
        continueButton.heightAnchor.constraint(equalToConstant: 54).isActive = true
        continueButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        continueButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
        continueButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50).isActive = true
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        guard type == .getConnectionView else { return }
        let rightButton = UIButton(frame: CGRect(origin: .zero, size: CGSize(width: 40, height: 40)))
        rightButton.backgroundColor = .clear
        
        rightButton.layer.cornerRadius = 15
        rightButton.tintColor = Colors.gray_100
        rightButton.layer.masksToBounds = true
        rightButton.addTarget(self, action: #selector(rightBarButtonItemTapped), for: .touchUpInside)
        let info = UIImage(systemName: "info.circle")
        rightButton.setImage(info, for: .normal)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightButton)
        
        let leftButton = UIButton(frame: CGRect(origin: .zero, size: CGSize(width: 120, height: 34)))
        leftButton.backgroundColor = Colors.gray_217
        leftButton.setTitle("Сменить Ник", for: .normal)
        leftButton.layer.cornerRadius = 8
        leftButton.layer.masksToBounds = true
        leftButton.setTitleColor(Colors.gray_14, for: .normal)
        leftButton.addTarget(self, action: #selector(leftBarButtonItemTapped), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: leftButton)
    }
    
    private func setUpContinueButton(isEnabled: Bool) {
        continueButton.backgroundColor = isEnabled ? Colors.gray_217 : Colors.gray_46
        continueButton.setTitleColor(isEnabled ? .black : Colors.gray_99_99_103, for: .normal)
    }
    
    @objc func rightBarButtonItemTapped() {
        navigationController?.pushViewController(InformationTableViewController(), animated: true)
    }
    
    @objc func leftBarButtonItemTapped() {
        navigationController?.pushViewController(InfoViewController(type: .changeUsername), animated: true)
    }
}

extension InfoViewController : UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        let isEnabled = textField.text?.count ?? 0 > 0 && !(textField.text?.isEmptyOrWhitespace() ?? true)
        continueButton.isEnabled = isEnabled
        setUpContinueButton(isEnabled: isEnabled)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

