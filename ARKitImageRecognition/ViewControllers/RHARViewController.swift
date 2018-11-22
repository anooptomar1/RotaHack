import ARKit
import SceneKit
import UIKit
import WebKit

class RHARViewController: UIViewController, ARSCNViewDelegate {
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak private var productInfoView: ARProductInfoView!
    @IBOutlet weak private var profuctInfoViewBottomConstraint: NSLayoutConstraint!
    private var workingPlaneNode: SCNNode?
    private var images: [ARImageModel] = []
    private var addedNodes: [SCNNode] = []
    private var checkpointNode: SCNNode?
    private var hammerNode: SCNNode?
    
    lazy var statusViewController: StatusViewController = {
        return childViewControllers.lazy.compactMap({ $0 as? StatusViewController }).first!
    }()
    let updateQueue = DispatchQueue(label: Bundle.main.bundleIdentifier! + ".serialSceneKitQueue")
    
    
    var session: ARSession {
        return sceneView.session
    }
    
    // MARK: - View Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.images = ARImageModel.dummy()
        RHCLocationHandler.sharedInstance.startLocationUpdate()
        sceneView.delegate = self
        sceneView.session.delegate = self
        self.addGestureRecognizers()
        statusViewController.restartExperienceHandler = { [unowned self] in
            self.restartExperience()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIApplication.shared.isIdleTimerDisabled = true
        resetTracking()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        session.pause()
    }
    
    private func addGestureRecognizers() {
        let productInfoSwipe = UISwipeGestureRecognizer(target: self, action: #selector(self.closeInfoView))
        productInfoSwipe.direction = .down
        self.productInfoView.addGestureRecognizer(productInfoSwipe)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.tappedScene(withGestureRecognizer:)))
        self.sceneView.addGestureRecognizer(tap)
        
        
        
        //        let productInfoTap = UITapGestureRecognizer(target: self, action: #selector(self.closeInfoView))
        //        self.productInfoView.addGestureRecognizer(productInfoTap)
    }
    
    @objc func tappedScene(withGestureRecognizer recognizer: UIGestureRecognizer) {
        let tapLocation = recognizer.location(in: sceneView)
        
        let hitTestOptions: [SCNHitTestOption : Any] = [SCNHitTestOption.rootNode: self.sceneView.scene.rootNode, SCNHitTestOption.boundingBoxOnly: true]
        
        let testResults = sceneView.hitTest(tapLocation, options: hitTestOptions)
        
        if testResults.count > 0 {
            
            let hitTestNode = testResults.first?.node
            
            if hitTestNode?.name == "Checkpoint" {
                self.presentObjectOnScene()
            } else {
                
            }
            
        } else {
        }
        
        
    }
    
    @objc private func closeInfoView() {
        profuctInfoViewBottomConstraint.constant = self.view.frame.size.height
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        self.removeExistingNodes()
    }
    var isRestartAvailable = true
    
    func resetTracking() {
        guard let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil) else {
            fatalError("Missing expected asset catalog resources.")
        }
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.detectionImages = referenceImages
        session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        
        statusViewController.scheduleMessage("Look around to detect images", inSeconds: 7.5, messageType: .contentPlacement)
    }
    
    // MARK: - ARSCNViewDelegate (Image detection results)
    /// - Tag: ARImageAnchor-Visualizing
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let imageAnchor = anchor as? ARImageAnchor else { return }
        let referenceImage = imageAnchor.referenceImage
        print("FOUND SOMETHING")
        updateQueue.async {
            
            // Create a plane to visualize the initial position of the detected image.
            let plane = SCNPlane(width: referenceImage.physicalSize.width,
                                 height: referenceImage.physicalSize.height)
            let planeNode = SCNNode(geometry: plane)
            planeNode.opacity = 1.0
            
            /*
             `SCNPlane` is vertically oriented in its local coordinate space, but
             `ARImageAnchor` assumes the image is horizontal in its local space, so
             rotate the plane to match.
             */
            planeNode.eulerAngles.x = -.pi / 2
            
            /*
             Image anchors are not tracked after initial detection, so create an
             animation that limits the duration for which the plane visualization appears.
             */
            planeNode.runAction(self.imageHighlightAction, completionHandler: {
                planeNode.opacity = 1.0
                self.workingPlaneNode = planeNode
                self.imageDetected(referencedImage: referenceImage, node: planeNode)
                
            })
            node.addChildNode(planeNode)
        }
        
        DispatchQueue.main.async {
            let imageName = referenceImage.name ?? ""
            self.statusViewController.cancelAllScheduledMessages()
            self.statusViewController.showMessage("Detected image “\(imageName)”")
        }
    }
    
    private func presentObjectOnScene() {
        self.checkpointNode?.opacity = 0.0
        self.checkpointNode?.removeFromParentNode()
        self.hammerNode?.opacity = 1.0
        self.hammerNode?.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 10.0, y: 0.0, z: 0.0, duration: 10.0)))
    }
    
    private func imageDetected(referencedImage: ARReferenceImage, node: SCNNode) {
        
        print("referencedImage name: ", referencedImage.name ?? "No image name")
        self.removeExistingNodes()
        addedNodes.append(node)
        if let foundARImage = images.first(where: { imageModel -> Bool in
            return imageModel.imageName == referencedImage.name
        }) {
            
            switch foundARImage.imageType {
            case .image:
                break
            case .localImage:
                if let image = UIImage(named: foundARImage.imageURL) {
                    //                    self.setupLocalImageOn(node, image: image)
                    self.setupLocalImageAboveOn(node,
                                                image: image,
                                                referencedImage: referencedImage)
                }
                
                break
            case .localVideo:
                if let videoURL = Bundle.main.url(forResource: foundARImage.videoURL,
                                                  withExtension: "mp4"){
                    self.setupVideoOnNode(node,
                                          fromURL: videoURL)
                }
                break
            case .video:
                if let videoURL =  foundARImage.videoURL,
                    let URL = URL(string: videoURL) {
                    DispatchQueue.main.async {
                        self.setupWebOn(node, fromURL: URL, referencedImage: referencedImage)
                    }
                }
                break
            case .scene:
                DispatchQueue.main.async {
                    self.addSceneTo(node: node, ARImage: foundARImage)
                }
                break
                
            case .info:
                DispatchQueue.main.async {
                    self.showImageInfo(ARImage: foundARImage)
                }
                break
            case .web:
                DispatchQueue.main.async {
                    if let webURL = foundARImage.webURL,
                        let url = URL(string: webURL) {
                        UIApplication.shared.open(url)
                    }
                }
            }
        }
        
    }
    
    private func addSceneTo(node: SCNNode, ARImage: ARImageModel) {
        if let sceneURL = ARImage.sceneURL,
            let scene = SCNScene(named: sceneURL) {
            let rootNode = scene.rootNode.childNode(withName: ARImage.imageName, recursively: true)!
            rootNode.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "WorkingToolsI")
            rootNode.position = SCNVector3Zero
            rootNode.position.z -= 0.2
            node.geometry = rootNode.geometry
            self.checkpointNode = rootNode.childNode(withName: "Checkpoint", recursively: true)
            self.hammerNode = rootNode.childNode(withName: "Hammer", recursively: true)
            self.hammerNode?.opacity = 0.0
            rootNode.childNodes.forEach { childNode in
                node.addChildNode(childNode)
            }
            
        } else {
            print("No scene")
        }
    }
    
    private func showImageInfo(ARImage: ARImageModel) {
        productInfoView.setup(with: ARImage)
        profuctInfoViewBottomConstraint.constant = 0.0
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    func setupVideoOnNode(_ node: SCNNode, fromURL url: URL){
        var videoPlayerNode: SKVideoNode!
        
        let videoPlayer = AVPlayer(url: url)
        videoPlayerNode = SKVideoNode(avPlayer: videoPlayer)
        videoPlayerNode.yScale = -1
        
        let spriteKitScene = SKScene(size: CGSize(width: 600, height: 300))
        spriteKitScene.scaleMode = .aspectFit
        videoPlayerNode.position = CGPoint(x: spriteKitScene.size.width/2, y: spriteKitScene.size.height / 2)
        videoPlayerNode.size = spriteKitScene.size
        spriteKitScene.addChild(videoPlayerNode)
        
        node.geometry?.firstMaterial?.diffuse.contents = spriteKitScene
        
        videoPlayerNode.play()
    }
    
    func setupLocalImageOn(_ node: SCNNode, image: UIImage){
        node.geometry?.firstMaterial?.diffuse.contents = image
    }
    
    func setupLocalImageAboveOn(_ node: SCNNode,
                                image: UIImage,
                                referencedImage: ARReferenceImage) {
        let width = Float(referencedImage.physicalSize.width)
        let height = Float(referencedImage.physicalSize.height)
        
        var nodePosition = node.position
        
        let zPosition: Float = height - (height / 4) - 0.5
        
        nodePosition.z = -zPosition
        node.position = nodePosition
        node.geometry?.firstMaterial?.diffuse.contents = image
    }
    
    func setupWebOn(_ node: SCNNode, fromURL url: URL, referencedImage: ARReferenceImage){

        let webView = UIWebView(frame: CGRect(x: 0, y: 0, width: 640, height: 480))
        let request = URLRequest(url: url)
        webView.loadRequest(request)
        webView.delegate = self
        
        let tvPlane = SCNPlane(width: referencedImage.physicalSize.width, height: referencedImage.physicalSize.height)
        tvPlane.firstMaterial?.diffuse.contents = webView
        tvPlane.firstMaterial?.isDoubleSided = true
        
        node.geometry = tvPlane
    }
    
    private func removeExistingNodes() {
        addedNodes.forEach { node in
            node.removeFromParentNode()
        }
        self.workingPlaneNode = nil
        self.hammerNode = nil
        self.checkpointNode = nil
    }
        var imageHighlightAction: SCNAction {
            return .sequence([
                .wait(duration: 0.25),
                .fadeOpacity(to: 0.85, duration: 0.25),
                .fadeOpacity(to: 0.15, duration: 0.25),
                .fadeOpacity(to: 0.85, duration: 0.25),
                .fadeOut(duration: 0.5),
            ])
        }
    
//    var imageHighlightAction: SCNAction {
//        return .sequence([
//            .fadeOpacity(to: 0.85, duration: 0.25)
//            ])
//    }
}


extension RHARViewController: UIWebViewDelegate {
    func webViewDidStartLoad(_ webView: UIWebView) {
        print("webViewDidStartLoad")
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        print("webViewDidFinishLoad")
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        print("didFailLoadWithError error: ", error.localizedDescription)
    }
}
