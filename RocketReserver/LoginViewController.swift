import UIKit
import KeychainSwift

class LoginViewController: UIViewController {
    static var loginKeychainKey = "login"
    
    private var emailTextField = UITextField()
    private var errorLabel = UILabel()
    private var submitButton = UIButton(type: .system)
    
    static func instantiate() -> UINavigationController {
        let navi = UINavigationController(rootViewController: LoginViewController())
        navi.modalPresentationStyle = .automatic
        
        return navi
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        emailTextField.translatesAutoresizingMaskIntoConstraints = false
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        submitButton.translatesAutoresizingMaskIntoConstraints = false
        
        
        let outerStack = UIStackView()
        outerStack.translatesAutoresizingMaskIntoConstraints = false
        outerStack.axis = .vertical
        outerStack.alignment = .fill
        outerStack.distribution = .fill
        outerStack.spacing = 8
        
        view.addSubview(outerStack)
        outerStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40).isActive = true
        outerStack.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
        outerStack.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -20).isActive = true
        
        
        let loginLabel = UILabel()
        loginLabel.text = "Log In"
        loginLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        
        emailTextField.placeholder = "email address"
        emailTextField.layer.borderWidth = 1.0
        
        errorLabel.text = "Errors"
        errorLabel.font = UIFont.systemFont(ofSize: 16)
        errorLabel.textColor = UIColor.red
        
        submitButton.setTitle("Submit", for: .normal)
        submitButton.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)
        
        
        outerStack.addArrangedSubview(loginLabel)
        outerStack.addArrangedSubview(emailTextField)
        outerStack.addArrangedSubview(errorLabel)
        outerStack.addArrangedSubview(submitButton)
        
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelTapped))
        navigationItem.rightBarButtonItem = cancelButton
        
        
        // Real process
        errorLabel.text = nil
        enableSubmitButton(true)
    }
    
    @objc private func submitTapped() {
        errorLabel.text = nil
        enableSubmitButton(false)

        guard let email = emailTextField.text else {
          errorLabel.text = "Please enter an email address."
          enableSubmitButton(true)
          return
        }

        guard validate(email: email) else {
          errorLabel.text = "Please enter a valid email."
          enableSubmitButton(true)
          return
        }
        
         Network.shared.apollo.perform(mutation: LoginMutation(email: email)) { [weak self] result in
          defer {
            self?.enableSubmitButton(true)
          }

          switch result {
          case .success(let graphQLResult):
            if let token = graphQLResult.data?.login {
              let keychain = KeychainSwift()
              keychain.set(token, forKey: LoginViewController.loginKeychainKey) // เซ็ต credential ไว้ใน keychain = บอกว่า login แล้ว
              self?.dismiss(animated: true)
            }

            if let errors = graphQLResult.errors {
              print("Errors from server: \(errors)")
            }
          case .failure(let error):
            print("Error: \(error)")
          }
        }
    }
    @objc private func cancelTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    private func enableSubmitButton(_ isEnabled: Bool) {
      self.submitButton.isEnabled = isEnabled
      if isEnabled {
        self.submitButton.setTitle("Submit", for: .normal)
      } else {
        self.submitButton.setTitle("Submitting...", for: .normal)
      }
    }
    private func validate(email: String) -> Bool {
      return email.contains("@")
    }
}

