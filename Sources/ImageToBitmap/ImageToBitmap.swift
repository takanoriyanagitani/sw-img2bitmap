import class CoreGraphics.CGColorSpace
import func CoreGraphics.CGColorSpaceCreateDeviceGray
import func CoreGraphics.CGColorSpaceCreateDeviceRGB
import struct CoreGraphics.CGRect
import struct CoreGraphics.CGSize
import class CoreImage.CIContext
import struct CoreImage.CIFormat
import class CoreImage.CIImage
import struct Foundation.Data
import class Foundation.FileHandle
import func FpUtil.Bind
import typealias FpUtil.IO

public typealias ImageToBitmapData = (CIImage) -> IO<Data>

public typealias DataWriter = (Data) -> IO<Void>

public typealias ImageWriter = (CIImage) -> IO<Void>

public enum ImgToBitmapErr: Error {
  case unexpected(String)
  case unimplemented
}

public func ImageToBitmapDataInvalid() -> ImageToBitmapData {
  return {
    let _: CIImage = $0
    return {
      return .failure(ImgToBitmapErr.unimplemented)
    }
  }
}

public func DataWriterInvalid() -> DataWriter {
  return {
    let _: Data = $0
    return {
      return .failure(ImgToBitmapErr.unimplemented)
    }
  }
}

public func DataToStdout() -> DataWriter {
  return {
    let dat: Data = $0
    return {
      let file: FileHandle = .standardOutput
      return Result(catching: {
        try file.write(contentsOf: dat)
      })
    }
  }
}

public func ImageToBitmap(
  ictx: CIContext,
  format: CIFormat,
  color: CGColorSpace,
  bytesPerComponent: Int
) -> ImageToBitmapData {
  return {
    let img: CIImage = $0
    return {
      let bounds: CGRect = img.extent

      let size: CGSize = bounds.size
      let width: Double = size.width
      let height: Double = size.height

      let bytesPerRow: Int = bytesPerComponent * Int(width)

      let totalBytes: Int = bytesPerRow * Int(height)

      var dat: Data = Data(count: totalBytes)

      let res: Result<(), Error> = dat.withUnsafeMutableBytes {
        let umrbp: UnsafeMutableRawBufferPointer = $0
        let oumrp: UnsafeMutableRawPointer? = umrbp.baseAddress
        guard let umrp = oumrp else {
          return .failure(
            ImgToBitmapErr.unexpected("unsafe mutable raw pointer was nil")
          )
        }

        ictx.render(
          img, toBitmap: umrp,
          rowBytes: bytesPerRow,
          bounds: bounds,
          format: format,
          colorSpace: color
        )
        return .success(())
      }

      return res.map {
        let _: () = $0
        return dat
      }
    }
  }
}

public func ImageToBitmapRGBA8(ictx: CIContext) -> ImageToBitmapData {
  return ImageToBitmap(
    ictx: ictx,
    format: .RGBA8,
    color: CGColorSpaceCreateDeviceRGB(),
    bytesPerComponent: 4
  )
}

public func ImageToBitmapMono8(ictx: CIContext) -> ImageToBitmapData {
  return ImageToBitmap(
    ictx: ictx,
    format: .L8,
    color: CGColorSpaceCreateDeviceGray(),
    bytesPerComponent: 1
  )
}

public struct WriteImageBitmap {
  public let img2bitmap: ImageToBitmapData
  public let writer: DataWriter

  public func withWriter(writer: @escaping DataWriter) -> Self {
    Self(img2bitmap: self.img2bitmap, writer: writer)
  }

  public func withImageToBitmap(img2bmp: @escaping ImageToBitmapData) -> Self {
    Self(img2bitmap: img2bmp, writer: self.writer)
  }

  public func toImageWriter() -> ImageWriter {
    return {
      let img: CIImage = $0
      return Bind(
        self.img2bitmap(img),
        self.writer
      )
    }
  }

  public static func emptyWriter() -> Self {
    Self(
      img2bitmap: ImageToBitmapDataInvalid(),
      writer: DataWriterInvalid()
    )
  }
}
