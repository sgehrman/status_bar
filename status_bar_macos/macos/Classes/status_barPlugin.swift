import Cocoa
import FlutterMacOS

public class status_barPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "status_bar", binaryMessenger: registrar.messenger)
    let instance = status_barPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPlatformVersion":
      result("macOS " + ProcessInfo.processInfo.operatingSystemVersionString)
    case "showStatusBar":
        showStatusBar(call, result: result)
    case "hideStatusBar":
        hideStatusBar(call, result: result)
    case "setStatusBarText":
        setStatusBarText(call, result: result)
    case "setStatusBarIcon":
        setStatusBarIcon(call, result: result)
    case "isShown":
        result(self.statusBarItem != nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

   private func showStatusBar(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        self.statusBarItem = NSStatusBar.system.statusItem(withLength: CGFloat(NSStatusItem.variableLength))
        if let button = self.statusBarItem.button {
             statusBarItem.button?.title = ' '
            button.target = self
            button.action = #selector(showAppWindows(_:))
        }
        result(true)
    }
    
    private func hideStatusBar(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if self.statusBarItem != nil {
            NSStatusBar.system.removeStatusItem(statusBarItem)
        }
        self.statusBarItem = nil
        result(true)
    }
    
    private func setStatusBarText(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if self.statusBarItem != nil {
            let text = call.arguments as! String
            statusBarItem.button?.title = text
            result(true)
        } else {
            result(false)
        }
    }
    
    private func resized(from image: NSImage, to newSize: NSSize) -> NSImage? {
        if let bitmapRep = NSBitmapImageRep(
            bitmapDataPlanes: nil, pixelsWide: Int(newSize.width), pixelsHigh: Int(newSize.height),
            bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
            colorSpaceName: .calibratedRGB, bytesPerRow: 0, bitsPerPixel: 0
        ) {
            bitmapRep.size = newSize
            NSGraphicsContext.saveGraphicsState()
            NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmapRep)
            image.draw(in: NSRect(x: 0, y: 0, width: newSize.width, height: newSize.height), from: .zero, operation: .copy, fraction: 1.0)
            NSGraphicsContext.restoreGraphicsState()
            
            let resizedImage = NSImage(size: newSize)
            resizedImage.addRepresentation(bitmapRep)
            return resizedImage
        }
        
        return nil
    }
    
    private func setStatusBarIcon(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if self.statusBarItem != nil {
            let bytes = [UInt8]((call.arguments as! FlutterStandardTypedData).data)
            
            var image = NSImage(data: Data(bytes))
            if (image != nil) {
                image =  resized(from: image!, to: NSSize(width: 18.0, height: 18.0))
                
                if (image != nil) {
                    self.statusBarItem.button?.image = image
                }
            }
            
            result(true)
        } else {
            result(false)
        }
    }
    
    @objc func showAppWindows(_ sender: AnyObject?) {
        // Activate the application to the foreground (if the application window is inactive)
        NSRunningApplication.current.activate(options: [NSApplication.ActivationOptions.activateIgnoringOtherApps])
        let window = NSApp.windows[0]
        window.makeKeyAndOrderFront(self)
    }
}
