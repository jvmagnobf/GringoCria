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

    /// The "mensagem_fonte" asset catalog color resource.
    static let mensagemFonte = DeveloperToolsSupport.ColorResource(name: "mensagem_fonte", bundle: resourceBundle)

}

// MARK: - Image Symbols -

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension DeveloperToolsSupport.ImageResource {

    /// The "BarracaFundo" asset catalog image resource.
    static let barracaFundo = DeveloperToolsSupport.ImageResource(name: "BarracaFundo", bundle: resourceBundle)

    /// The "CaipiFundo" asset catalog image resource.
    static let caipiFundo = DeveloperToolsSupport.ImageResource(name: "CaipiFundo", bundle: resourceBundle)

    /// The "CriaFundo" asset catalog image resource.
    static let criaFundo = DeveloperToolsSupport.ImageResource(name: "CriaFundo", bundle: resourceBundle)

    /// The "CristoPose" asset catalog image resource.
    static let cristoPose = DeveloperToolsSupport.ImageResource(name: "CristoPose", bundle: resourceBundle)

    /// The "CristoPose1" asset catalog image resource.
    static let cristoPose1 = DeveloperToolsSupport.ImageResource(name: "CristoPose1", bundle: resourceBundle)

    /// The "CristoPose2 (1)" asset catalog image resource.
    static let cristoPose21 = DeveloperToolsSupport.ImageResource(name: "CristoPose2 (1)", bundle: resourceBundle)

    /// The "CristoPose3" asset catalog image resource.
    static let cristoPose3 = DeveloperToolsSupport.ImageResource(name: "CristoPose3", bundle: resourceBundle)

    /// The "CristoPoseChat" asset catalog image resource.
    static let cristoPoseChat = DeveloperToolsSupport.ImageResource(name: "CristoPoseChat", bundle: resourceBundle)

    /// The "CristoPoseInfo" asset catalog image resource.
    static let cristoPoseInfo = DeveloperToolsSupport.ImageResource(name: "CristoPoseInfo", bundle: resourceBundle)

    /// The "CristoPoseMicrofone" asset catalog image resource.
    static let cristoPoseMicrofone = DeveloperToolsSupport.ImageResource(name: "CristoPoseMicrofone", bundle: resourceBundle)

    /// The "EsfihaFundo" asset catalog image resource.
    static let esfihaFundo = DeveloperToolsSupport.ImageResource(name: "EsfihaFundo", bundle: resourceBundle)

    /// The "FundoChat" asset catalog image resource.
    static let fundoChat = DeveloperToolsSupport.ImageResource(name: "FundoChat", bundle: resourceBundle)

    /// The "FundoChatRio" asset catalog image resource.
    static let fundoChatRio = DeveloperToolsSupport.ImageResource(name: "FundoChatRio", bundle: resourceBundle)

    /// The "GarçomFundo" asset catalog image resource.
    static let garçomFundo = DeveloperToolsSupport.ImageResource(name: "GarçomFundo", bundle: resourceBundle)

    /// The "IconeCadeira" asset catalog image resource.
    static let iconeCadeira = DeveloperToolsSupport.ImageResource(name: "IconeCadeira", bundle: resourceBundle)

    /// The "IconeCaipi" asset catalog image resource.
    static let iconeCaipi = DeveloperToolsSupport.ImageResource(name: "IconeCaipi", bundle: resourceBundle)

    /// The "IconeCria" asset catalog image resource.
    static let iconeCria = DeveloperToolsSupport.ImageResource(name: "IconeCria", bundle: resourceBundle)

    /// The "IconeEsifiha" asset catalog image resource.
    static let iconeEsifiha = DeveloperToolsSupport.ImageResource(name: "IconeEsifiha", bundle: resourceBundle)

    /// The "IconeGarcom" asset catalog image resource.
    static let iconeGarcom = DeveloperToolsSupport.ImageResource(name: "IconeGarcom", bundle: resourceBundle)

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

    /// The "mensagem_fonte" asset catalog color.
    static var mensagemFonte: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .mensagemFonte)
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

    /// The "mensagem_fonte" asset catalog color.
    static var mensagemFonte: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .mensagemFonte)
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

    /// The "mensagem_fonte" asset catalog color.
    static var mensagemFonte: SwiftUI.Color { .init(.mensagemFonte) }

}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.ShapeStyle where Self == SwiftUI.Color {

    /// The "amarelo_mensagem" asset catalog color.
    static var amareloMensagem: SwiftUI.Color { .init(.amareloMensagem) }

    /// The "branco_mensagem" asset catalog color.
    static var brancoMensagem: SwiftUI.Color { .init(.brancoMensagem) }

    /// The "mensagem_fonte" asset catalog color.
    static var mensagemFonte: SwiftUI.Color { .init(.mensagemFonte) }

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

    /// The "CriaFundo" asset catalog image.
    static var criaFundo: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .criaFundo)
#else
        .init()
#endif
    }

    /// The "CristoPose" asset catalog image.
    static var cristoPose: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .cristoPose)
#else
        .init()
#endif
    }

    /// The "CristoPose1" asset catalog image.
    static var cristoPose1: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .cristoPose1)
#else
        .init()
#endif
    }

    /// The "CristoPose2 (1)" asset catalog image.
    static var cristoPose21: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .cristoPose21)
#else
        .init()
#endif
    }

    /// The "CristoPose3" asset catalog image.
    static var cristoPose3: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .cristoPose3)
#else
        .init()
#endif
    }

    /// The "CristoPoseChat" asset catalog image.
    static var cristoPoseChat: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .cristoPoseChat)
#else
        .init()
#endif
    }

    /// The "CristoPoseInfo" asset catalog image.
    static var cristoPoseInfo: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .cristoPoseInfo)
#else
        .init()
#endif
    }

    /// The "CristoPoseMicrofone" asset catalog image.
    static var cristoPoseMicrofone: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .cristoPoseMicrofone)
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

    /// The "FundoChatRio" asset catalog image.
    static var fundoChatRio: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .fundoChatRio)
#else
        .init()
#endif
    }

    /// The "GarçomFundo" asset catalog image.
    static var garçomFundo: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .garçomFundo)
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

    /// The "IconeCria" asset catalog image.
    static var iconeCria: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .iconeCria)
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

    /// The "IconeGarcom" asset catalog image.
    static var iconeGarcom: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .iconeGarcom)
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

    /// The "CriaFundo" asset catalog image.
    static var criaFundo: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .criaFundo)
#else
        .init()
#endif
    }

    /// The "CristoPose" asset catalog image.
    static var cristoPose: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .cristoPose)
#else
        .init()
#endif
    }

    /// The "CristoPose1" asset catalog image.
    static var cristoPose1: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .cristoPose1)
#else
        .init()
#endif
    }

    /// The "CristoPose2 (1)" asset catalog image.
    static var cristoPose21: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .cristoPose21)
#else
        .init()
#endif
    }

    /// The "CristoPose3" asset catalog image.
    static var cristoPose3: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .cristoPose3)
#else
        .init()
#endif
    }

    /// The "CristoPoseChat" asset catalog image.
    static var cristoPoseChat: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .cristoPoseChat)
#else
        .init()
#endif
    }

    /// The "CristoPoseInfo" asset catalog image.
    static var cristoPoseInfo: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .cristoPoseInfo)
#else
        .init()
#endif
    }

    /// The "CristoPoseMicrofone" asset catalog image.
    static var cristoPoseMicrofone: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .cristoPoseMicrofone)
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

    /// The "FundoChatRio" asset catalog image.
    static var fundoChatRio: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .fundoChatRio)
#else
        .init()
#endif
    }

    /// The "GarçomFundo" asset catalog image.
    static var garçomFundo: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .garçomFundo)
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

    /// The "IconeCria" asset catalog image.
    static var iconeCria: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .iconeCria)
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

    /// The "IconeGarcom" asset catalog image.
    static var iconeGarcom: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .iconeGarcom)
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

