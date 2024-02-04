import SwiftUI
import UIKit
import CoreGraphics
import CoreImage

class QRCodeGenerator: ObservableObject {
    
    @Published var data: String = ""
    @Published var size: CGSize = CGSize(width: 200, height: 200)
    
    
    func generateQRCode(from string: String, size: CGSize, logo: UIImage?) -> UIImage? {
        // Convert the input string to data
        guard let data = string.data(using: String.Encoding.ascii) else {
            return nil
        }
        
        // Create a QR code filter using the CoreImage library
        guard let qrFilter = CIFilter(name: "CIQRCodeGenerator") else {
            return nil
        }
        
        // Set the input data for the filter
        qrFilter.setValue(data, forKey: "inputMessage")
        
        // Get the output image from the filter
        guard let qrImage = qrFilter.outputImage else {
            return nil
        }
        
        // Scale the image to the desired size
        let scaleX = size.width / qrImage.extent.size.width
        let scaleY = size.height / qrImage.extent.size.height
        let transformedImage = qrImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
        
        // Create a CIContext
        let context = CIContext()
        
        // Through context, render the CIImage to a CGImage
        guard let cgImage = context.createCGImage(transformedImage, from: transformedImage.extent) else {
            return nil
        }
        
        // Create a UIImage from the CGImage
        var qrCodeImage = UIImage(cgImage: cgImage)
        
        // Creates the logo overlay
        if let logoImage = logo {
            qrCodeImage = overlayLogo(qrCodeImage: qrCodeImage, logo: logoImage)
        }
        
        return qrCodeImage
    }
    
    func overlayLogo(qrCodeImage: UIImage, logo: UIImage) -> UIImage {
        let squareSize = CGSize(width: qrCodeImage.size.width/5, height: qrCodeImage.size.height/5) // Size of the square
        let squareRect = CGRect(x: (qrCodeImage.size.width - squareSize.width) / 2,
                                y: (qrCodeImage.size.height - squareSize.height) / 2,
                                width: squareSize.width, height: squareSize.height)
        
        let logoSize = CGSize(width: squareSize.width * 0.65, height: squareSize.height * 0.7) // Logo smaller than the square
        let logoRect = CGRect(x: (qrCodeImage.size.width - logoSize.width) / 2,
                              y: (qrCodeImage.size.height - logoSize.height) / 2,
                              width: logoSize.width, height: logoSize.height)
        
        UIGraphicsBeginImageContextWithOptions(qrCodeImage.size, false, UIScreen.main.scale)
        qrCodeImage.draw(in: CGRect(origin: CGPoint.zero, size: qrCodeImage.size))
        
        // Draw the square background for the logo
        UIColor.white.setFill() // Set the square color, which in this case is white
        UIRectFill(squareRect) // Fill the square area with the selected color
        
        // Draw the logo on top of the square, just enough so the QR code still works
        logo.draw(in: logoRect, blendMode: .normal, alpha: 1.0)
        
        let finalImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return finalImage ?? qrCodeImage // Return original image if overlay fails
    }
}
