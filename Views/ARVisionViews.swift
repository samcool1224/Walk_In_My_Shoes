//
//  ARVisionViews.swift
//  Walk In My Shoes
//
//  Created by Samaksh Bhargav on 2/24/25.
//
import SwiftUI
import RealityKit
import ARKit
import Combine
@available(iOS 17, *)
class TunnelVisionView: UIView {
    var clearRadius: CGFloat = 60
    
    init(frame: CGRect, clearRadius: CGFloat) {
        self.clearRadius = clearRadius
        super.init(frame: frame)
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.setFillColor(UIColor.black.withAlphaComponent(0.9).cgColor)
        context.fill(rect)
        
        let maskLayer = CAShapeLayer()
        let path = UIBezierPath(rect: rect)
        let clearCirclePath = UIBezierPath(ovalIn: CGRect(x: rect.midX - clearRadius, y: rect.midY - clearRadius, width: clearRadius * 2, height: clearRadius * 2))
        path.append(clearCirclePath)
        maskLayer.fillRule = .evenOdd
        maskLayer.path = path.cgPath
        self.layer.mask = maskLayer
    }
}

// 2. Macular Degeneration - Scotoma Simulation
class ScotomaView: UIView {
    var scotomaRadius: CGFloat = 80
    
    init(frame: CGRect, scotomaRadius: CGFloat) {
        self.scotomaRadius = scotomaRadius
        super.init(frame: frame)
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.setFillColor(UIColor.black.withAlphaComponent(0.85).cgColor)
        context.fill(rect)
        
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let path = UIBezierPath(arcCenter: center, radius: scotomaRadius, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true)
        
        context.setBlendMode(.clear)
        context.addPath(path.cgPath)
        context.fillPath()
    }
}

// 3. Glaucoma - Smooth Gradient Peripheral Vision Loss
class GlaucomaView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        let colors = [UIColor.clear.cgColor, UIColor.black.withAlphaComponent(0.95).cgColor] as CFArray
        let locations: [CGFloat] = [0.2, 1.0]
        
        guard let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors, locations: locations) else { return }
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let maxRadius = sqrt(pow(rect.width, 2) + pow(rect.height, 2)) / 2
        
        context.drawRadialGradient(gradient, startCenter: center, startRadius: 0, endCenter: center, endRadius: maxRadius, options: .drawsAfterEndLocation)
    }
}

// 4. Cataracts - Blurred Vision Overlay
class CataractsView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.white.withAlphaComponent(0.4) // Light haze effect
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

// 5. Diabetic Retinopathy - Random Dark Spots
class DiabeticRetinopathyView: UIView {
    let spotCount = 10 // Number of spots
    let maxSize: CGFloat = 50
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        for _ in 0..<spotCount {
            let size = CGFloat.random(in: 20...maxSize)
            let x = CGFloat.random(in: 0...rect.width - size)
            let y = CGFloat.random(in: 0...rect.height - size)
            let spotRect = CGRect(x: x, y: y, width: size, height: size)
            
            context.setFillColor(UIColor.black.withAlphaComponent(0.8).cgColor)
            context.fillEllipse(in: spotRect)
        }
    }
}
enum ImpairmentType {
    case none, tunnelVision, auditoryDistortion, cataract, macularDegeneration, glaucoma, presbycusis
}
struct ARViewContainer: UIViewRepresentable {
    var selectedImpairment: ImpairmentType
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal, .vertical]
        config.environmentTexturing = .automatic
        arView.session.run(config)
        // AR content: A rotating cube.
        let cubeMesh = MeshResource.generateBox(size: 0.2)
        let cubeMaterial = SimpleMaterial(color: .cyan, roughness: 0.3, isMetallic: false)
        let cubeEntity = ModelEntity(mesh: cubeMesh, materials: [cubeMaterial])
        cubeEntity.generateCollisionShapes(recursive: true)
        cubeEntity.move(to: Transform(pitch: 0, yaw: .pi, roll: 0), relativeTo: nil, duration: 10, timingFunction: .linear)
        let anchor = AnchorEntity(world: SIMD3(0, 0, -0.5))
        anchor.addChild(cubeEntity)
        arView.scene.anchors.append(anchor)
        return arView
    }
    func updateUIView(_ uiView: ARView, context: Context) {
        for subview in uiView.subviews {
            if subview.tag >= 1001 && subview.tag <= 1005 { subview.removeFromSuperview() }
        }
        switch selectedImpairment {
        case .cataract:
            let blur = UIBlurEffect(style: .regular)
            let blurView = UIVisualEffectView(effect: blur)
            blurView.frame = uiView.bounds
            blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            blurView.tag = 1001
            uiView.addSubview(blurView)
        case .tunnelVision:
            let tunnelView = TunnelVisionView(frame: uiView.bounds, clearRadius: min(uiView.bounds.width, uiView.bounds.height) / 5)
            tunnelView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            tunnelView.tag = 1002
            uiView.addSubview(tunnelView)
        case .glaucoma:
            let glaucomaView = GlaucomaView(frame: uiView.bounds)
            glaucomaView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            glaucomaView.tag = 1005
            uiView.addSubview(glaucomaView)
        case .macularDegeneration:
            let scotomaView = ScotomaView(frame: uiView.bounds, scotomaRadius: min(uiView.bounds.width, uiView.bounds.height) / 4)
            scotomaView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            scotomaView.tag = 1003
            uiView.addSubview(scotomaView)
        case .auditoryDistortion, .presbycusis, .none:
            break
        }
    }
}
