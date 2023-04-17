//
//  MainViewController.swift
//  Membrana
//
//  Created by Fedor Bebinov on 08.12.22.
//

import UIKit
import AVFoundation
import CoreHaptics
import Lottie

open class MainViewController: UIViewController {
    
    // MARK: Properties
    var gestureTitleLabel = UILabel()
    var gradientLabel = UILabel()
    var fingerprintImageView = UIImageView()
    var audioPlayer = AVAudioPlayer()
    var panGestureStartLocation : CGPoint = .zero
    var engine: CHHapticEngine?
    let animationView = LottieAnimationView()
    var repeatedPoinstCount = 0
    var isXChanged = false
    var isYChanged = false
    let service: MainVCService
    var connectionIndicator = UIView()
    var loadDataTimer: Timer?
    var friendTapLocationCoefs: CGPoint = .zero
    var currentUser: User?
    var isConnected: Bool = false
    
    init() {
        let networkManager = NetworkManager()
        self.service = MainVCService(networkManager: networkManager)
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var model = MainModel()
    
    // MARK: Private funcs
    private func setUpView() {
        let backgroundImage = UIImage(named: MainModel.Images.backgroundImageName)
        let backgroundImageView = UIImageView(image: backgroundImage)
        view.addSubview(backgroundImageView)
        backgroundImageView.anchor(top: view.topAnchor, paddingTop: -100,
                                   bottom:  view.bottomAnchor, paddingBottom: 100,
                                   left: view.leadingAnchor, paddingLeft: 0,
                                   right: view.trailingAnchor, paddingRight: 0)
        
        animationView.frame = view.bounds
        animationView.isHidden = true
        view.addSubview(animationView)
        
        view.addSubview(gestureTitleLabel)
        gestureTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        gestureTitleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16).isActive = true
        gestureTitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        gestureTitleLabel.font = .systemFont(ofSize: 40, weight: .bold)
        gestureTitleLabel.textColor = .white
        self.gestureTitleLabel.alpha = 0
        
        view.addSubview(gradientLabel)
        gradientLabel.translatesAutoresizingMaskIntoConstraints = false
        gradientLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16).isActive = true
        gradientLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16).isActive = true
        gradientLabel.font = .systemFont(ofSize: 20)
        gradientLabel.text = "Ждем " + (UserDefaults.standard.string(forKey: "connectWithUser") ?? "") + "-а"
        gradientLabel.textColor = Colors.gray_217
        self.gradientLabel.alpha = 0
        
        fingerprintImageView.image = model.fingerPrintImage
        view.addSubview(fingerprintImageView)
        fingerprintImageView.frame.size = CGSize(width: 70, height: 70)
        fingerprintImageView.layer.cornerRadius = 35
        fingerprintImageView.clipsToBounds = true
        self.fingerprintImageView.alpha = 0
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        connectionIndicator = UIView()
        connectionIndicator.backgroundColor = .clear
        connectionIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(connectionIndicator)
        
        connectionIndicator.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        connectionIndicator.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        connectionIndicator.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        connectionIndicator.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }
    
    private func setEngine() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        do {
            engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            print("There was an error creating the engine: \(error.localizedDescription)")
        }
        
        engine?.stoppedHandler = { reason in
            print("The engine stopped: \(reason)")
        }
        
        engine?.resetHandler = { [weak self] in
            print("The engine reset")
            do {
                try self?.engine?.start()
            } catch {
                print("Failed to restart the engine: \(error)")
            }
        }
    }
    
    private func createHaptic() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 1)
        let event = CHHapticEvent(eventType: .hapticContinuous, parameters: [intensity, sharpness], relativeTime: 0, duration: 3)
        
        do {
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("Failed to play pattern: \(error.localizedDescription).")
        }
    }
    
    private func addGestures() {
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        view.addGestureRecognizer(singleTap)
        
        let doubleTap = UITapGestureRecognizer(target: self, action:  #selector(self.handleDoubleTap(_:)))
        doubleTap.numberOfTapsRequired = 2
        view.addGestureRecognizer(doubleTap)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.handlePan(_ :)))
        panGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(panGesture)
        
        singleTap.require(toFail: doubleTap)
    }
    
    private func playSound(named: String, type: String) {
        let path = Bundle.main.path(forResource: named, ofType: type)!
        let url = URL(fileURLWithPath: path)
        
        do {
            //create your audioPlayer in your parent class as a property
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer.play()
        } catch {
            print("couldn't load the file")
        }
    }
    
    private func animateTitle(named: String) {
        gestureTitleLabel.text = named
        UIView.animate(withDuration: 0.5, animations : {
            self.gestureTitleLabel.alpha = 1
        }) { _ in
            UIView.animate(withDuration: 2.5, animations : {
                self.gestureTitleLabel.alpha = 0
            })
        }
    }
    
    private func animatePending() {
        UIView.animate(withDuration: 5.0, delay: 0, options: [.autoreverse,.repeat], animations: {
            self.gradientLabel.alpha = 1
        }) { _ in
            self.gradientLabel.alpha = 0
        }
    }
    
    private func addLottieAnimation(named: String) {
        animationView.isHidden = false
        animationView.animation = LottieAnimation.named(named)
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .playOnce
        animationView.play(){ [weak self] _ in
            self?.animationView.isHidden = true
            self?.resetData()
        }
    }
    
    private func updateIndicators() {
        if isConnected {
            gradientLabel.alpha = 0
            connectionIndicator.backgroundColor = .green
        } else {
            gradientLabel.alpha = 1
            connectionIndicator.backgroundColor = .red
        }
    }
    
    private func handleCircle() {
        if connectionIndicator.backgroundColor != .green {
            animateTitle(named: MainModel.GestureTitle.dojd)
        }
        playSound(named: MainModel.Sound.dojd.0, type: MainModel.Sound.dojd.1)
        addLottieAnimation(named: MainModel.LottieNamed.rain)
    }
    
    private func handleLine() {
        if connectionIndicator.backgroundColor != .green {
            animateTitle(named: MainModel.GestureTitle.grom)
        }
        createHaptic()
        playSound(named: MainModel.Sound.grom.0, type: MainModel.Sound.grom.1)
        addLottieAnimation(named: MainModel.LottieNamed.lightning)
    }
    
    private func handleGettedTap() {
        let tapCordinater = CGPoint(x: view.frame.width * friendTapLocationCoefs.x, y: view.frame.height * friendTapLocationCoefs.y)
        fingerprintImageView.center = tapCordinater
        
        UIView.animate(withDuration: 2, animations : { [weak self] in
            self?.fingerprintImageView.alpha = 1
        }) { _ in
            UIView.animate(withDuration: 1, animations : { [weak self] in
                self?.fingerprintImageView.alpha = 0
                self?.resetData()
            })
        }
    }
    
    private func handleGettedDoubleTap() {
        playSound(named: MainModel.Sound.solnce.0, type: MainModel.Sound.solnce.1)
        addLottieAnimation(named: MainModel.LottieNamed.double_tap)
    }
    
    private func handleRecivedGestures(with type: Int, tapLocation: CGPoint? = nil) {
        switch type {
            // single tap
        case 0:
            handleGettedTap()
            
            // double tap
        case 1:
            handleGettedDoubleTap()
            
            // line
        case 2:
            handleLine()
            
            // circle
        case 3:
            handleCircle()
        default:
            print("debug: this type isn't expected")
        }
    }
    
    private func resetData() {
        guard let username = currentUser?.userName else { return }

        service.resetUserData(username: username) { [weak self] resp, error in
            guard self != nil else { return }
            if error != nil  {
                print("debug: error is \(String(describing: error))")
            }
            if resp != nil {
                print("debug: data is reseted")
            }
        }
    }
    
    
    private func sendGestures(drawingGestureType: Int = 5, tapGestureLocationCoef: [CGFloat] = []) {
        guard let currentUser = currentUser else { return }
        let username = currentUser.userName
        let connections = currentUser.connections
        
        service.sendData(username: username,
                         connections: connections,
                         drawingGestureType: drawingGestureType,
                         tapGestureLocation: tapGestureLocationCoef) { [weak self] resp, error in
            guard self != nil else { return }
            if error != nil  {
                print("debug: gesture is error \(String(describing: error?.localizedDescription))")
            }
            
            if resp != nil {
                print("debug: gesture is sent")
            }
        }
    }
    
    // MARK: View controller life cycle
    open override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        addGestures()
        setEngine()
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        resetData()
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadDataTimer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(handleLoadDataTimer), userInfo: nil, repeats: true)
        resetData()
    }
    
    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        loadDataTimer?.invalidate()
        loadDataTimer = nil
        resetData()
        
        guard let username = UserDefaults.standard.string(forKey: "username") else { return }
        
        service.logoutUserNameMain(username: username) { [weak self] resp, error in
            guard UserDefaults.standard.string(forKey: "username") != nil else { return }
            guard self != nil else { return }
            if error != nil  {
                print("debug: \(String(describing: error?.localizedDescription))")
            }
            
            if resp != nil {
                guard let topController = UIApplication.topViewController() else { return }
                topController.navigationController?.popToRootViewController(animated: true)
                print("debug: user is logged out")
            }
        }
    }
    
    // MARK: IBActions
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        if !self.isConnected {
            animateTitle(named: MainModel.GestureTitle.contact)
        }
        
        let tapCordinater = CGPoint(x: view.frame.width * friendTapLocationCoefs.x, y: view.frame.height * friendTapLocationCoefs.y)
        fingerprintImageView.center = sender?.location(in: view) ?? tapCordinater
        
        UIView.animate(withDuration: 2, animations : {
            self.fingerprintImageView.alpha = 1
        }) { _ in
            UIView.animate(withDuration: 1, animations : {
                self.fingerprintImageView.alpha = 0
            })
        }
        
        guard let position = sender?.location(in: view) else { return }
        let propX = position.x / view.frame.width
        let propY = position.y / view.frame.height
        let tapGestureLocationCoef = [propX, propY]
        
        sendGestures(drawingGestureType: 0, tapGestureLocationCoef: tapGestureLocationCoef)
    }
    
    @objc func handlePan(_ sender: UIPanGestureRecognizer? = nil) {
        guard let position = sender?.location(in: view) else { return }
        
        if sender?.state == .began {
            panGestureStartLocation = position
            isXChanged = false
            isYChanged = false
        }
        
        if sender?.state == .changed {
            if (position.x - panGestureStartLocation.x).magnitude > 50 {
                isXChanged = true
            }
            if (position.y - panGestureStartLocation.y).magnitude > 50 {
                isYChanged = true
            }
        }
        
        // line
        if sender?.state == .ended {
            if position.y - panGestureStartLocation.y > view.frame.size.height - 200 {
                if !self.isConnected {
                    animateTitle(named: MainModel.GestureTitle.grom)
                }
                createHaptic()
                playSound(named: MainModel.Sound.grom.0, type: MainModel.Sound.grom.1)
                addLottieAnimation(named: MainModel.LottieNamed.lightning)
                sendGestures(drawingGestureType: 2)
            }
            
            //circle
            if isXChanged && isYChanged {
                let distance = position.cgPointDistance(to: panGestureStartLocation)
                if distance >= 0 && distance <= 50 {
                    if !self.isConnected {
                        animateTitle(named: MainModel.GestureTitle.dojd)
                    }
                    playSound(named: MainModel.Sound.dojd.0, type: MainModel.Sound.dojd.1)
                    addLottieAnimation(named: MainModel.LottieNamed.rain)
                    sendGestures(drawingGestureType: 3)
                }
            }
        }
    }
    
    @objc func handleDoubleTap(_ sender: UITapGestureRecognizer? = nil) {
        if !self.isConnected {
            animateTitle(named: MainModel.GestureTitle.svet)
        }
        playSound(named: MainModel.Sound.solnce.0, type: MainModel.Sound.solnce.1)
        addLottieAnimation(named: MainModel.LottieNamed.double_tap)
        
        sendGestures(drawingGestureType: 1)
    }
    
    @objc func handleLoadDataTimer() {
        service.getUserData { [weak self] data, error in
            guard let self else { return }
            if error != nil  {
                print("debug: error loading data \(String(describing: error?.localizedDescription))")
            }
            
            if let data {
                let decoder = JSONDecoder()
                let userInfo = try? decoder.decode(User.self, from: data)
                
                if let connections = userInfo?.connections,
                   let gestureType = userInfo?.drawingGestureType,
                   let tapGestureLocation = userInfo?.tapGestureLocation,
                   connections.count > 0 {
                    self.currentUser = userInfo
                    self.connectionIndicator.backgroundColor = .red
                    self.updateIndicators()
                    self.isConnected = true
                    if !tapGestureLocation.isEmpty {
                        self.friendTapLocationCoefs = CGPoint(x: tapGestureLocation[0], y: tapGestureLocation[1])
                    }
                    self.handleRecivedGestures(with: gestureType)
                } else {
                    self.updateIndicators()
                    self.isConnected = false
                }
            }
        }
    }
}


