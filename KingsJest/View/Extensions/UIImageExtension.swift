import UIKit
import CoreImage

extension UIImage{
    func tintGrayImage(with color: UIColor) -> UIImage? {
        guard let cgImage = self.cgImage else { return nil }
        
        let ciImage = CIImage(cgImage: cgImage)
        let context = CIContext()
        
        // Converte a cor para componentes RGBA
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 1
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        // Cria o filtro CIColorMatrix
        guard let filter = CIFilter(name: "CIColorMatrix") else { return nil }
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        
        // Mapeia intensidade do cinza (assumindo tons de cinza == mesmo valor nos canais) para a nova cor
        filter.setValue(CIVector(x: r, y: r, z: r, w: 0), forKey: "inputRVector")
        filter.setValue(CIVector(x: g, y: g, z: g, w: 0), forKey: "inputGVector")
        filter.setValue(CIVector(x: b, y: b, z: b, w: 0), forKey: "inputBVector")
        
        // Mantém o canal alpha
        filter.setValue(CIVector(x: 0, y: 0, z: 0, w: 1), forKey: "inputAVector")
        
        // Sem bias
        filter.setValue(CIVector(x: 0, y: 0, z: 0, w: 0), forKey: "inputBiasVector")
        
        // Gera imagem de saída
        guard let outputImage = filter.outputImage,
              let cgOutput = context.createCGImage(outputImage, from: outputImage.extent) else {
            return nil
        }

        return UIImage(cgImage: cgOutput, scale: self.scale, orientation: self.imageOrientation)
    }

    func gradientMapImage(from colors: UIColor...) -> UIImage? {
        guard let cgImage = self.cgImage else { return nil }
        let ciImage = CIImage(cgImage: cgImage)
        let context = CIContext()

        // Cria imagem de gradiente 256x1 de color1 -> color2
        let size = CGSize(width: 256, height: 1)
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        guard let ctx = UIGraphicsGetCurrentContext() else { return nil }

        let cgColors = colors.map{$0.cgColor}
        let cfArray =  cgColors as CFArray
        let step:CGFloat = CGFloat(1)/(CGFloat(cgColors.count-1))
        var locations = (0..<cgColors.count-1).map {CGFloat($0)*step}
        locations.append(1)
        let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                  colors: cfArray,
                                  locations: locations)!
        
        ctx.drawLinearGradient(gradient,
                               start: CGPoint(x: 0, y: 0),
                               end: CGPoint(x: size.width, y: 0),
                               options: [])

        guard let gradientImage = UIGraphicsGetImageFromCurrentImageContext()?.cgImage else {
            UIGraphicsEndImageContext()
            return nil
        }
        UIGraphicsEndImageContext()
        
        // CIColorMap para substituir tons de cinza pelo gradiente
        let gradientCIImage = CIImage(cgImage: gradientImage)
        guard let colorMapFilter = CIFilter(name: "CIColorMap") else { return nil }
        colorMapFilter.setValue(ciImage, forKey: kCIInputImageKey)
        colorMapFilter.setValue(gradientCIImage, forKey: "inputGradientImage")

        guard let outputImage = colorMapFilter.outputImage,
              let cgOutput = context.createCGImage(outputImage, from: outputImage.extent) else {
            return nil
        }

        return UIImage(cgImage: cgOutput, scale: self.scale, orientation: self.imageOrientation)
    }
    
    func gradientMapImage(from colors: [UIColor]) -> UIImage? {
        switch colors.count {
        case 5:
            return gradientMapImage(from: colors[0], colors[1], colors[2], colors[3], colors[4])
        case 4:
            return gradientMapImage(from: colors[0], colors[1], colors[2], colors[3])
        case 3:
            return gradientMapImage(from: colors[0], colors[1], colors[2])
        case 2:
            return gradientMapImage(from: colors[0], colors[1])
        case 1:
            return gradientMapImage(from: colors[0])
        default:
            return nil
        }
    }
}
