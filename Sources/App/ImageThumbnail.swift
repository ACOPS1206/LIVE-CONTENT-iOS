import UIKit

enum ImageThumbnail {
    static func make(from data: Data, maxBytes: Int = 1_800) -> Data? {
        guard let source = UIImage(data: data) else { return nil }
        let size = CGSize(width: 56, height: 56)
        let renderer = UIGraphicsImageRenderer(size: size)
        let square = renderer.image { _ in
            let scale = max(size.width / source.size.width, size.height / source.size.height)
            let drawnSize = CGSize(width: source.size.width * scale, height: source.size.height * scale)
            let origin = CGPoint(
                x: (size.width - drawnSize.width) / 2,
                y: (size.height - drawnSize.height) / 2
            )
            source.draw(in: CGRect(origin: origin, size: drawnSize))
        }

        for quality in stride(from: 0.55, through: 0.10, by: -0.05) {
            if let result = square.jpegData(compressionQuality: quality), result.count <= maxBytes {
                return result
            }
        }
        return nil
    }
}

