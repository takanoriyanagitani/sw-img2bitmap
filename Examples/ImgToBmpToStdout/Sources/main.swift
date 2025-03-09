import struct CoreGraphics.CGPoint
import struct CoreGraphics.CGRect
import struct CoreGraphics.CGSize
import class CoreImage.CIContext
import class CoreImage.CIImage
import typealias FpUtil.IO
import func ImageToBitmap.DataToStdout
import typealias ImageToBitmap.DataWriter
import typealias ImageToBitmap.ImageToBitmapData
import func ImageToBitmap.ImageToBitmapRGBA8
import typealias ImageToBitmap.ImageWriter
import struct ImageToBitmap.WriteImageBitmap

@main
struct ImgToBmpToStdout {
  static func main() {
    let writer: DataWriter = DataToStdout()
    let img2bmp: ImageToBitmapData = ImageToBitmapRGBA8(ictx: CIContext())
    let wibmp: WriteImageBitmap = .emptyWriter()
      .withWriter(writer: writer)
      .withImageToBitmap(img2bmp: img2bmp)
    let iwtr: ImageWriter = wibmp.toImageWriter()

    let origin: CGPoint = .zero
    let size: CGSize = CGSize(width: 4, height: 3)
    let cgr: CGRect = CGRect(origin: origin, size: size)

    let cimgBlue: CIImage = .blue
      .cropped(to: cgr)

    let cimg2stdout: IO<Void> = iwtr(cimgBlue)

    let res: Result<(), _> = cimg2stdout()

    do {
      try res.get()
    } catch {
      print("\( error )")
    }
  }
}
