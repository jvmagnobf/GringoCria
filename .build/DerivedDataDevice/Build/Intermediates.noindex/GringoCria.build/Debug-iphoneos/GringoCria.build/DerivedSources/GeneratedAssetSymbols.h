#import <Foundation/Foundation.h>

#if __has_attribute(swift_private)
#define AC_SWIFT_PRIVATE __attribute__((swift_private))
#else
#define AC_SWIFT_PRIVATE
#endif

/// The resource bundle ID.
static NSString * const ACBundleID AC_SWIFT_PRIVATE = @"br.com.GringoCria";

/// The "amarelo_mensagem" asset catalog color resource.
static NSString * const ACColorNameAmareloMensagem AC_SWIFT_PRIVATE = @"amarelo_mensagem";

/// The "branco_mensagem" asset catalog color resource.
static NSString * const ACColorNameBrancoMensagem AC_SWIFT_PRIVATE = @"branco_mensagem";

/// The "BarracaFundo" asset catalog image resource.
static NSString * const ACImageNameBarracaFundo AC_SWIFT_PRIVATE = @"BarracaFundo";

/// The "CaipiFundo" asset catalog image resource.
static NSString * const ACImageNameCaipiFundo AC_SWIFT_PRIVATE = @"CaipiFundo";

/// The "EsfihaFundo" asset catalog image resource.
static NSString * const ACImageNameEsfihaFundo AC_SWIFT_PRIVATE = @"EsfihaFundo";

/// The "FundoChat" asset catalog image resource.
static NSString * const ACImageNameFundoChat AC_SWIFT_PRIVATE = @"FundoChat";

/// The "IconeCadeira" asset catalog image resource.
static NSString * const ACImageNameIconeCadeira AC_SWIFT_PRIVATE = @"IconeCadeira";

/// The "IconeCaipi" asset catalog image resource.
static NSString * const ACImageNameIconeCaipi AC_SWIFT_PRIVATE = @"IconeCaipi";

/// The "IconeEsifiha" asset catalog image resource.
static NSString * const ACImageNameIconeEsifiha AC_SWIFT_PRIVATE = @"IconeEsifiha";

/// The "IconeMatte" asset catalog image resource.
static NSString * const ACImageNameIconeMatte AC_SWIFT_PRIVATE = @"IconeMatte";

/// The "IconePolicia" asset catalog image resource.
static NSString * const ACImageNameIconePolicia AC_SWIFT_PRIVATE = @"IconePolicia";

/// The "IconeSalvaVidas" asset catalog image resource.
static NSString * const ACImageNameIconeSalvaVidas AC_SWIFT_PRIVATE = @"IconeSalvaVidas";

/// The "MatteFundo" asset catalog image resource.
static NSString * const ACImageNameMatteFundo AC_SWIFT_PRIVATE = @"MatteFundo";

/// The "PolicialFundo2" asset catalog image resource.
static NSString * const ACImageNamePolicialFundo2 AC_SWIFT_PRIVATE = @"PolicialFundo2";

/// The "SalvavidasFundo" asset catalog image resource.
static NSString * const ACImageNameSalvavidasFundo AC_SWIFT_PRIVATE = @"SalvavidasFundo";

/// The "menu_background" asset catalog image resource.
static NSString * const ACImageNameMenuBackground AC_SWIFT_PRIVATE = @"menu_background";

/// The "telaWelcome" asset catalog image resource.
static NSString * const ACImageNameTelaWelcome AC_SWIFT_PRIVATE = @"telaWelcome";

#undef AC_SWIFT_PRIVATE
