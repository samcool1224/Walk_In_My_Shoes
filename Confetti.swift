import SwiftUI

public struct ConfettiView: UIViewRepresentable {
    @Binding var isVisible: Bool
    
    public func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = false
        return view
    }
    
    public func updateUIView(_ uiView: UIView, context: Context) {
        if isVisible {
            showConfetti(on: uiView)
        }
    }
    
    private func showConfetti(on view: UIView) {
        let emitter = CAEmitterLayer()
        
        emitter.frame = view.bounds
        emitter.emitterPosition = CGPoint(x: view.bounds.width / 2, y: 0)
        emitter.emitterShape = .line
        emitter.emitterSize = CGSize(width: view.bounds.width, height: 1)
        emitter.renderMode = .oldestFirst
        
        let cell = CAEmitterCell()
        cell.birthRate = 20
        cell.lifetime = 8
        cell.velocity = 220
        cell.velocityRange = 80
        cell.emissionLongitude = .pi
        cell.emissionRange = .pi / 4
        cell.spin = 4
        cell.spinRange = 8
        cell.scale = 0.3
        cell.scaleRange = 0.2
        
        let size = CGSize(width: 12, height: 12)
        if let image = generateConfettiImage(size: size) {
            cell.contents = image
        }
        
        let colors: [UIColor] = [.systemRed, .systemBlue, .systemGreen,
                                 .systemYellow, .systemPurple, .systemOrange]
        
        emitter.emitterCells = colors.map { color in
            let newCell = cell.copy() as! CAEmitterCell
            newCell.color = color.cgColor
            return newCell
        }
        
        view.layer.sublayers?.removeAll(where: { $0 is CAEmitterLayer })
        view.layer.addSublayer(emitter)
        
        Task {
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            await MainActor.run {
                emitter.birthRate = 0
            }
            
            try? await Task.sleep(nanoseconds: 6_000_000_000)
            await MainActor.run {
                emitter.removeFromSuperlayer()
            }
        }
    }
    
    private func generateConfettiImage(size: CGSize) -> CGImage? {
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            let rect = CGRect(origin: .zero, size: size)
            
            switch Int.random(in: 0...2) {
            case 0:
                context.cgContext.addEllipse(in: rect)
            case 1:
                context.cgContext.addRect(rect)
            default:
                context.cgContext.addRect(CGRect(x: 0, y: 0, width: size.width, height: size.height / 3))
            }
            
            context.cgContext.setFillColor(UIColor.white.cgColor)
            context.cgContext.fillPath()
        }
        return image.cgImage
    }
    
}
