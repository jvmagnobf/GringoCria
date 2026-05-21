import Foundation
#if canImport(AppKit)
import AppKit
#endif
#if canImport(UIKit)
import UIKit
#endif
#if canImport(SwiftUI)
import SwiftUI
#endif
#if canImport(DeveloperToolsSupport)
import DeveloperToolsSupport
#endif

#if SWIFT_PACKAGE
private let resourceBundle = Foundation.Bundle.module
#else
private class ResourceBundleClass {}
private let resourceBundle = Foundation.Bundle(for: ResourceBundleClass.self)
#endif

// MARK: - Color Symbols -

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension DeveloperToolsSupport.ColorResource {

    /// The "amarelo_mensagem" asset catalog color resource.
    static let amareloMensagem = DeveloperToolsSupport.ColorResource(name: "amarelo_mensagem", bundle: resourceBundle)

    /// The "branco_mensagem" asset catalog color resource.
    static let brancoMensagem = DeveloperToolsSupport.ColorResource(name: "branco_mensagem", bundle: resourceBundle)

}

// MARK: - Image Symbols -

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension DeveloperToolsSupport.ImageResource {

    /// The "BarracaFundo" asset catalog image resource.
    static let barracaFundo = DeveloperToolsSupport.ImageResource(name: "BarracaFundo", bundle: resourceBundle)

    /// The "CaipiFundo" asset catalog image resource.
    static let caipiFundo = DeveloperToolsSupport.ImageResource(name: "CaipiFundo", bundle: resourceBundle)

    /// The "EsfihaFundo" asset catalog image resource.
    static let esfihaFundo = DeveloperToolsSupport.ImageResource(name: "EsfihaFundo", bundle: resourceBundle)

    /// The "FundoChat" asset catalog image resource.
    static let fundoChat = DeveloperToolsSupport.ImageResource(name: "FundoChat", bundle: resourceBundle)

    /// The "IconeCadeira" asset catalog image resource.
    static let iconeCadeira = DeveloperToolsSupport.ImageResource(name: "IconeCadeira", bundle: resourceBundle)

    /// The "IconeCaipi" asset catalog image resource.
    static let iconeCaipi = DeveloperToolsSupport.ImageResource(name: "IconeCaipi", bundle: resourceBundle)

    /// The "IconeEsifiha" asset catalog image resource.
    static let iconeEsifiha = DeveloperToolsSupport.ImageResource(name: "IconeEsifiha", bundle: resourceBundle)

    /// The "IconeMatte" asset catalog image resource.
    static let iconeMatte = DeveloperToolsSupport.ImageResource(name: "IconeMatte", bundle: resourceBundle)

    /// The "IconePolicia" asset catalog image resource.
    static let iconePolicia = DeveloperToolsSupport.ImageResource(name: "IconePolicia", bundle: resourceBundle)

    /// The "IconeSalvaVidas" asset catalog image resource.
    static let iconeSalvaVidas = DeveloperToolsSupport.ImageResource(name: "IconeSalvaVidas", bundle: resourceBundle)

    /// The "MatteFundo" asset catalog image resource.
    static let matteFundo = DeveloperToolsSupport.ImageResource(name: "MatteFundo", bundle: resourceBundle)

    /// The "PolicialFundo2" asset catalog image resource.
    static let policialFundo2 = DeveloperToolsSupport.ImageResource(name: "PolicialFundo2", bundle: resourceBundle)

    /// The "SalvavidasFundo" asset catalog image resource.
    static let salvavidasFundo = DeveloperToolsSupport.ImageResource(name: "SalvavidasFundo", bundle: resourceBundle)

    /// The "menu_background" asset catalog image resource.
    static let menuBackground = DeveloperToolsSupport.ImageResource(name: "menu_background", bundle: resourceBundle)

    /// The "telaWelcome" asset catalog image resource.
    static let telaWelcome = DeveloperToolsSupport.ImageResource(name: "telaWelcome", bundle: resourceBundle)

}

// MARK: - Color Symbol Extensions -

#if canImport(AppKit)
@available(macOS 14.0, *)
@available(macCatalyst, unavailable)
extension AppKit.NSColor {

    /// The "amarelo_mensagem" asset catalog color.
    static var amareloMensagem: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .amareloMensagem)
#else
        .init()
#endif
    }

    /// The "branco_mensagem" asset catalog color.
    static var brancoMensagem: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .brancoMensagem)
#else
        .init()
#endif
    }

}
#endif

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIColor {

    /// The "amarelo_mensagem" asset catalog color.
    static var amareloMensagem: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .amareloMensagem)
#else
        .init()
#endif
    }

    /// The "branco_mensagem" asset catalog color.
    static var brancoMensagem: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .brancoMensagem)
#else
        .init()
#endif
    }

}
#endif

#if canImport(SwiftUI)
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.Color {

    /// The "amarelo_mensagem" asset catalog color.
    static var amareloMensagem: SwiftUI.Color { .init(.amareloMensagem) }

    /// The "branco_mensagem" asset catalog color.
    static var brancoMensagem: SwiftUI.Color { .init(.brancoMensagem) }

}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.ShapeStyle where Self == SwiftUI.Color {

    /// The "amarelo_mensagem" asset catalog color.
    static var amareloMensagem: SwiftUI.Color { .init(.amareloMensagem) }

    /// The "branco_mensagem" asset catalog color.
    static var brancoMensagem: SwiftUI.Color { .init(.brancoMensagem) }

}
#endif

// MARK: - Image Symbol Extensions -

#if canImport(AppKit)
@available(macOS 14.0, *)
@available(macCatalyst, unavailable)
extension AppKit.NSImage {

    /// The "BarracaFundo" asset catalog image.
    static var barracaFundo: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .barracaFundo)
#else
        .init()
#endif
    }

    /// The "CaipiFundo" asset catalog image.
    static var caipiFundo: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .caipiFundo)
#else
        .init()
#endif
    }

    /// The "EsfihaFundo" asset catalog image.
    static var esfihaFundo: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .esfihaFundo)
#else
        .init()
#endif
    }

    /// The "FundoChat" asset catalog image.
    static var fundoChat: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .fundoChat)
#else
        .init()
#endif
    }

    /// The "IconeCadeira" asset catalog image.
    static var iconeCadeira: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .iconeCadeira)
#else
        .init()
#endif
    }

    /// The "IconeCaipi" asset catalog image.
    static var iconeCaipi: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .iconeCaipi)
#else
        .init()
#endif
    }

    /// The "IconeEsifiha" asset catalog image.
    static var iconeEsifiha: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .iconeEsifiha)
#else
        .init()
#endif
    }

    /// The "IconeMatte" asset catalog image.
    static var iconeMatte: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .iconeMatte)
#else
        .init()
#endif
    }

    /// The "IconePolicia" asset catalog image.
    static var iconePolicia: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .iconePolicia)
#else
        .init()
#endif
    }

    /// The "IconeSalvaVidas" asset catalog image.
    static var iconeSalvaVidas: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .iconeSalvaVidas)
#else
        .init()
#endif
    }

    /// The "MatteFundo" asset catalog image.
    static var matteFundo: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .matteFundo)
#else
        .init()
#endif
    }

    /// The "PolicialFundo2" asset catalog image.
    static var policialFundo2: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .policialFundo2)
#else
        .init()
#endif
    }

    /// The "SalvavidasFundo" asset catalog image.
    static var salvavidasFundo: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .salvavidasFundo)
#else
        .init()
#endif
    }

    /// The "menu_background" asset catalog image.
    static var menuBackground: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .menuBackground)
#else
        .init()
#endif
    }

    /// The "telaWelcome" asset catalog image.
    static var telaWelcome: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .telaWelcome)
#else
        .init()
#endif
    }

}
#endif

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIImage {

    /// The "BarracaFundo" asset catalog image.
    static var barracaFundo: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .barracaFundo)
#else
        .init()
#endif
    }

    /// The "CaipiFundo" asset catalog image.
    static var caipiFundo: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .caipiFundo)
#else
        .init()
#endif
    }

    /// The "EsfihaFundo" asset catalog image.
    static var esfihaFundo: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .esfihaFundo)
#else
        .init()
#endif
    }

    /// The "FundoChat" asset catalog image.
    static var fundoChat: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .fundoChat)
#else
        .init()
#endif
    }

    /// The "IconeCadeira" asset catalog image.
    static var iconeCadeira: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .iconeCadeira)
#else
        .init()
#endif
    }

    /// The "IconeCaipi" asset catalog image.
    static var iconeCaipi: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .iconeCaipi)
#else
        .init()
#endif
    }

    /// The "IconeEsifiha" asset catalog image.
    static var iconeEsifiha: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .iconeEsifiha)
#else
        .init()
#endif
    }

    /// The "IconeMatte" asset catalog image.
    static var iconeMatte: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .iconeMatte)
#else
        .init()
#endif
    }

    /// The "IconePolicia" asset catalog image.
    static var iconePolicia: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .iconePolicia)
#else
        .init()
#endif
    }

    /// The "IconeSalvaVidas" asset catalog image.
    static var iconeSalvaVidas: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .iconeSalvaVidas)
#else
        .init()
#endif
    }

    /// The "MatteFundo" asset catalog image.
    static var matteFundo: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .matteFundo)
#else
        .init()
#endif
    }

    /// The "PolicialFundo2" asset catalog image.
    static var policialFundo2: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .policialFundo2)
#else
        .init()
#endif
    }

    /// The "SalvavidasFundo" asset catalog image.
    static var salvavidasFundo: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .salvavidasFundo)
#else
        .init()
#endif
    }

    /// The "menu_background" asset catalog image.
    static var menuBackground: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .menuBackground)
#else
        .init()
#endif
    }

    /// The "telaWelcome" asset catalog image.
    static var telaWelcome: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .telaWelcome)
#else
        .init()
#endif
    }

}
#endif

// MARK: - Thinnable Asset Support -

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
@available(watchOS, unavailable)
extension DeveloperToolsSupport.ColorResource {

    private init?(thinnableName: Swift.String, bundle: Foundation.Bundle) {
#if canImport(AppKit) && os(macOS)
        if AppKit.NSColor(named: NSColor.Name(thinnableName), bundle: bundle) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#elseif canImport(UIKit) && !os(watchOS)
        if UIKit.UIColor(named: thinnableName, in: bundle, compatibleWith: nil) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}

#if canImport(AppKit)
@available(macOS 14.0, *)
@available(macCatalyst, unavailable)
extension AppKit.NSColor {

    private convenience init?(thinnableResource: DeveloperToolsSupport.ColorResource?) {
#if !targetEnvironment(macCatalyst)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIColor {

    private convenience init?(thinnableResource: DeveloperToolsSupport.ColorResource?) {
#if !os(watchOS)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

#if canImport(SwiftUI)
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.Color {

    private init?(thinnableResource: DeveloperToolsSupport.ColorResource?) {
        if let resource = thinnableResource {
            self.init(resource)
        } else {
            return nil
        }
    }

}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.ShapeStyle where Self == SwiftUI.Color {

    private init?(thinnableResource: DeveloperToolsSupport.ColorResource?) {
        if let resource = thinnableResource {
            self.init(resource)
        } else {
            return nil
        }
    }

}
#endif

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
@available(watchOS, unavailable)
extension DeveloperToolsSupport.ImageResource {

    private init?(thinnableName: Swift.String, bundle: Foundation.Bundle) {
#if canImport(AppKit) && os(macOS)
        if bundle.image(forResource: NSImage.Name(thinnableName)) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#elseif canImport(UIKit) && !os(watchOS)
        if UIKit.UIImage(named: thinnableName, in: bundle, compatibleWith: nil) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}

#if canImport(AppKit)
@available(macOS 14.0, *)
@available(macCatalyst, unavailable)
extension AppKit.NSImage {

    private convenience init?(thinnableResource: DeveloperToolsSupport.ImageResource?) {
#if !targetEnvironment(macCatalyst)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIImage {

    private convenience init?(thinnableResource: DeveloperToolsSupport.ImageResource?) {
#if !os(watchOS)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

