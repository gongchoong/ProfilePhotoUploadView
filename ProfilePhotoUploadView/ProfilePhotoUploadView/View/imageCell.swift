

import UIKit

class ImageCell: UICollectionViewCell {
    let imageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFill
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 10
        view.isUserInteractionEnabled = true
        return view
    }()
    
    let imageDeleteButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(named: "profile_image_delete_button")
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.imageView?.contentMode = .scaleAspectFill
        button.imageView?.layer.masksToBounds = true
        return button
    }()
    
    let shapeLayer:CAShapeLayer = CAShapeLayer()
    
    var isChanged = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    fileprivate func setup(){
        backgroundColor = UIColor.clear
        addSubview(imageView)
        addSubview(imageDeleteButton)
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            imageView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.95),
            imageView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.95)
            ])
        NSLayoutConstraint.activate([
            imageDeleteButton.topAnchor.constraint(equalTo: topAnchor),
            imageDeleteButton.rightAnchor.constraint(equalTo: rightAnchor),
            imageDeleteButton.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.2),
            imageDeleteButton.heightAnchor.constraint(equalTo: widthAnchor, multiplier: 0.2)
            ])
        imageView.bringSubviewToFront(imageDeleteButton)
    }
    
    func applyDottedBorder(){
        let frameSize = self.frame.size
        let shapeRect = CGRect(x: 0, y: 0, width: frameSize.width * 0.95, height: frameSize.height * 0.95)
        
        shapeLayer.bounds = shapeRect
        shapeLayer.position = CGPoint(x: frameSize.width/2 * 0.95, y: frameSize.height/2 * 0.95)
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = UIColor.lightGray.cgColor
        shapeLayer.lineWidth = 2
        shapeLayer.lineJoin = CAShapeLayerLineJoin.round
        shapeLayer.lineDashPattern = [6,3]
        shapeLayer.path = UIBezierPath(roundedRect: shapeRect, cornerRadius: 10).cgPath
        imageView.layer.addSublayer(shapeLayer)
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static var identifier: String {
        return String(describing: self)
    }
}
