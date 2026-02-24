/*
Navy Museum

Abstract:
Shared helpers for loading image sources for spatial scene generation.
*/

import Foundation
import ImageIO
import UIKit
import CoreGraphics

enum SpatialSceneImageSource {
    case url(URL)
    case imageSource(CGImageSource)

    static func resolve(named name: String, bundle: Bundle = .main) throws -> SpatialSceneImageSource {
        let nsName = name as NSString
        let baseName = nsName.deletingPathExtension
        let fileExtension = nsName.pathExtension

        if !fileExtension.isEmpty,
           let url = bundle.url(forResource: baseName, withExtension: fileExtension) {
            return .url(url)
        }

        if let url = bundle.url(forResource: name, withExtension: nil) {
            return .url(url)
        }

        let commonExtensions = ["heic", "heif", "jpg", "jpeg", "png", "webp", "tiff", "bmp", "gif"]
        for ext in commonExtensions {
            if let url = bundle.url(forResource: name, withExtension: ext) {
                return .url(url)
            }
        }

        if let uiImage = UIImage(named: name),
           let data = uiImage.pngData(),
           let imageSource = CGImageSourceCreateWithData(data as CFData, nil) {
            return .imageSource(imageSource)
        }

        throw SpatialSceneGenerationError.imageNotFound(name)
    }
}

enum SpatialSceneGenerationError: LocalizedError {
    case imageNotFound(String)

    var errorDescription: String? {
        switch self {
        case .imageNotFound(let name):
            return "Could not locate image '\(name)' in the app bundle."
        }
    }
}
enum SpatialSceneImageMetrics {
    static func imageSize(named name: String, bundle: Bundle = .main) -> CGSize? {
        do {
            let source = try SpatialSceneImageSource.resolve(named: name, bundle: bundle)
            switch source {
            case .url(let url):
                guard let cgImageSource = CGImageSourceCreateWithURL(url as CFURL, nil) else {
                    return nil
                }
                return size(from: cgImageSource)
            case .imageSource(let cgImageSource):
                return size(from: cgImageSource)
            }
        } catch {
            if let image = UIImage(named: name) {
                return image.size
            }
            return nil
        }
    }

    private static func size(from imageSource: CGImageSource) -> CGSize? {
        guard let properties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as? [CFString: Any],
              let width = properties[kCGImagePropertyPixelWidth] as? CGFloat,
              let height = properties[kCGImagePropertyPixelHeight] as? CGFloat,
              width > 0,
              height > 0 else {
            return nil
        }
        return CGSize(width: width, height: height)
    }
}
