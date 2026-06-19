import UIKit

/// Composites two captures (front/back of an ID or passport) onto one portrait
/// page (free). On-device. Each side is aspect-fit into the top/bottom half.
struct IDCardComposer {
    func compose(front: UIImage, back: UIImage,
                 pageSize: CGSize = CGSize(width: 1240, height: 1754)) -> UIImage {
        UIGraphicsImageRenderer(size: pageSize).image { ctx in
            UIColor.white.setFill()
            ctx.fill(CGRect(origin: .zero, size: pageSize))
            let pad = pageSize.width * 0.06
            let slotHeight = (pageSize.height - pad * 3) / 2
            let slotWidth = pageSize.width - pad * 2
            drawAspectFit(front, in: CGRect(x: pad, y: pad, width: slotWidth, height: slotHeight))
            drawAspectFit(back, in: CGRect(x: pad, y: pad * 2 + slotHeight, width: slotWidth, height: slotHeight))
        }
    }

    private func drawAspectFit(_ image: UIImage, in rect: CGRect) {
        guard image.size.width > 0, image.size.height > 0 else { return }
        let scale = min(rect.width / image.size.width, rect.height / image.size.height)
        let size = CGSize(width: image.size.width * scale, height: image.size.height * scale)
        let origin = CGPoint(x: rect.midX - size.width / 2, y: rect.midY - size.height / 2)
        image.draw(in: CGRect(origin: origin, size: size))
    }
}
