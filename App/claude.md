# Arquitectura del Proyecto (Swift 6)

Este documento define la arquitectura objetivo del proyecto y las pautas clave para su evolución. Está alineado con Swift 6, Swift Concurrency y patrones modernos de iOS.

## Principios rectores
- MVVM + Coordinator para orquestar navegación y aislar la lógica de presentación.
- Arquitectura Hexagonal (Ports & Adapters) para desacoplar el Dominio de frameworks.
- Principios SOLID aplicados a cada capa.
- Observación moderna con `@Observable` (Observation) en lugar de `ObservableObject` cuando sea posible.
- Concurrencia segura con `async/await`, `actors` y `Sendable`.
- Diseño de UI basado en Atomic Design y un Design System propio.
- Objetivo de cobertura de tests: ~70% (unitarios + de integración ligera).

## Estructura por capas (Hexagonal)

- App (Configuración y arranque)
  - Responsabilidades: configuración de dependencias, ensamblaje de coordinadores, punto de entrada (`@main`).
  - No contiene lógica de dominio.
- Presentación
  - Contiene ViewModels (`@Observable`), Coordinators, Routers y Vistas (SwiftUI).
  - Se comunica con el Dominio a través de puertos (protocolos) definidos en Dominio.
- Dominio
  - Reglas de negocio puras, entidades, servicios y casos de uso (UseCases). Solo conoce protocolos.
  - No hace import de UIKit/SwiftUI/SwiftData.
- Data
  - Adaptadores hacia persistencia (SwiftData/CoreData/Files), red, servicios del sistema.
  - Implementa los protocolos (puertos) definidos en Dominio.
- Design System
  - Tokens de diseño, estilos, componentes atómicos reutilizables (SwiftUI), recursos.

### Árbol de carpetas sugerido

```
ProjectRoot/
├── App/
│   ├── AppDelegate.swift                    # Solo si necesitas UIKit lifecycle
│   ├── SceneDelegate.swift                  # Solo si necesitas scenes específicos
│   ├── MainApp.swift                        # @main entry point con SwiftUI
│   ├── AppCoordinator.swift                 # Coordinator principal de la app
│   └── DependencyContainer.swift            # Inyección de dependencias (DI Container)
│
├── Domain/
│   ├── Entities/
│   │   ├── User.swift
│   │   ├── Product.swift
│   │   └── Order.swift
│   │
│   ├── UseCases/
│   │   ├── Authentication/
│   │   │   ├── LoginUseCase.swift
│   │   │   ├── LogoutUseCase.swift
│   │   │   └── RegisterUserUseCase.swift
│   │   ├── Products/
│   │   │   ├── FetchProductsUseCase.swift
│   │   │   └── SearchProductsUseCase.swift
│   │   └── Orders/
│   │       ├── CreateOrderUseCase.swift
│   │       └── FetchOrderHistoryUseCase.swift
│   │
│   ├── RepositoryProtocols/                 # Puertos (Ports)
│   │   ├── UserRepositoryProtocol.swift
│   │   ├── ProductRepositoryProtocol.swift
│   │   └── OrderRepositoryProtocol.swift
│   │
│   ├── ServiceProtocols/                    # Puertos para servicios externos
│   │   ├── AuthenticationServiceProtocol.swift
│   │   ├── NotificationServiceProtocol.swift
│   │   └── AnalyticsServiceProtocol.swift
│   │
│   └── ValueObjects/                        # Value objects inmutables
│       ├── Email.swift
│       ├── Password.swift
│       └── Money.swift
│
├── Data/
│   ├── Repositories/                        # Adaptadores (Adapters)
│   │   ├── UserRepository.swift
│   │   ├── ProductRepository.swift
│   │   └── OrderRepository.swift
│   │
│   ├── DataSources/
│   │   ├── Local/
│   │   │   ├── SwiftData/
│   │   │   │   ├── SwiftDataModels/
│   │   │   │   │   ├── UserDataModel.swift
│   │   │   │   │   ├── ProductDataModel.swift
│   │   │   │   │   └── OrderDataModel.swift
│   │   │   │   └── SwiftDataStack.swift
│   │   │   ├── UserDefaults/
│   │   │   │   └── UserDefaultsManager.swift
│   │   │   └── FileSystem/
│   │   │       └── FileStorageManager.swift
│   │   │
│   │   └── Remote/
│   │       ├── API/
│   │       │   ├── APIClient.swift
│   │       │   ├── APIEndpoint.swift
│   │       │   ├── APIError.swift
│   │       │   └── RequestBuilder.swift
│   │       └── DTOs/                        # Data Transfer Objects
│   │           ├── UserDTO.swift
│   │           ├── ProductDTO.swift
│   │           └── OrderDTO.swift
│   │
│   ├── Services/                            # Implementación de ServiceProtocols
│   │   ├── AuthenticationService.swift
│   │   ├── NotificationService.swift
│   │   └── AnalyticsService.swift
│   │
│   └── Mappers/                             # Conversión DTO <-> Entity
│       ├── UserMapper.swift
│       ├── ProductMapper.swift
│       └── OrderMapper.swift
│
├── Presentation/
│   ├── Common/
│   │   ├── Navigation/
│   │   │   ├── AppRouter.swift
│   │   │   ├── NavigationCoordinator.swift
│   │   │   └── Route.swift
│   │   │
│   │   ├── ViewModifiers/
│   │   │   ├── LoadingModifier.swift
│   │   │   ├── ErrorAlertModifier.swift
│   │   │   └── KeyboardAdaptiveModifier.swift
│   │   │
│   │   └── Extensions/
│   │       ├── View+Extensions.swift
│   │       ├── Color+Extensions.swift
│   │       └── Image+Extensions.swift
│   │
│   ├── Modules/
│   │   ├── Authentication/
│   │   │   ├── Login/
│   │   │   │   ├── LoginView.swift
│   │   │   │   └── LoginViewModel.swift
│   │   │   ├── Register/
│   │   │   │   ├── RegisterView.swift
│   │   │   │   └── RegisterViewModel.swift
│   │   │   └── AuthenticationCoordinator.swift
│   │   │
│   │   ├── Home/
│   │   │   ├── HomeView.swift
│   │   │   ├── HomeViewModel.swift
│   │   │   └── HomeCoordinator.swift
│   │   │
│   │   ├── Products/
│   │   │   ├── ProductList/
│   │   │   │   ├── ProductListView.swift
│   │   │   │   └── ProductListViewModel.swift
│   │   │   ├── ProductDetail/
│   │   │   │   ├── ProductDetailView.swift
│   │   │   │   └── ProductDetailViewModel.swift
│   │   │   └── ProductsCoordinator.swift
│   │   │
│   │   └── Profile/
│   │       ├── ProfileView.swift
│   │       ├── ProfileViewModel.swift
│   │       └── ProfileCoordinator.swift
│   │
│   └── Utilities/
│       ├── ImagePicker.swift
│       └── DocumentPicker.swift
│
├── DesignSystem/
│   ├── Tokens/
│   │   ├── Colors.swift
│   │   ├── Typography.swift
│   │   ├── Spacing.swift
│   │   ├── BorderRadius.swift
│   │   └── Shadows.swift
│   │
│   ├── Atoms/                               # Componentes básicos (Atomic Design)
│   │   ├── Buttons/
│   │   │   ├── PrimaryButton.swift
│   │   │   ├── SecondaryButton.swift
│   │   │   └── IconButton.swift
│   │   ├── TextFields/
│   │   │   ├── StandardTextField.swift
│   │   │   ├── SecureTextField.swift
│   │   │   └── SearchTextField.swift
│   │   ├── Labels/
│   │   │   ├── TitleLabel.swift
│   │   │   ├── BodyLabel.swift
│   │   │   └── CaptionLabel.swift
│   │   └── Icons/
│   │       └── IconView.swift
│   │
│   ├── Molecules/                           # Componentes compuestos
│   │   ├── Cards/
│   │   │   ├── ProductCard.swift
│   │   │   └── UserCard.swift
│   │   ├── ListItems/
│   │   │   ├── StandardListItem.swift
│   │   │   └── DetailListItem.swift
│   │   └── Forms/
│   │       ├── FormField.swift
│   │       └── FormSection.swift
│   │
│   ├── Organisms/                           # Componentes complejos
│   │   ├── NavigationBars/
│   │   │   ├── StandardNavigationBar.swift
│   │   │   └── SearchNavigationBar.swift
│   │   ├── TabBars/
│   │   │   └── MainTabBar.swift
│   │   └── EmptyStates/
│   │       ├── EmptyStateView.swift
│   │       └── ErrorStateView.swift
│   │
│   ├── Resources/
│   │   ├── Localizable.xcstrings            # String Catalog principal
│   │   ├── InfoPlist.xcstrings              # Localización de Info.plist
│   │   └── Assets.xcassets/
│   │       ├── Colors/
│   │       ├── Images/
│   │       └── Icons/
│   │
│   └── Localization/
│       └── LocalizedString.swift            # Enum type-safe para strings
│
├── Core/                                     # Utilidades transversales
│   ├── Networking/
│   │   ├── NetworkMonitor.swift             # Monitoreo de conectividad
│   │   └── HTTPMethod.swift
│   │
│   ├── Storage/
│   │   └── KeychainManager.swift
│   │
│   ├── Extensions/
│   │   ├── String+Extensions.swift
│   │   ├── Date+Extensions.swift
│   │   └── Collection+Extensions.swift
│   │
│   ├── Utilities/
│   │   ├── Logger.swift
│   │   ├── Validator.swift
│   │   └── DateFormatter+Custom.swift
│   │
│   └── Protocols/
│       ├── Coordinator.swift
│       ├── ViewModel.swift
│       └── UseCase.swift
│
├── Tests/
│   ├── DomainTests/
│   │   ├── UseCases/
│   │   │   ├── LoginUseCaseTests.swift
│   │   │   └── FetchProductsUseCaseTests.swift
│   │   └── Entities/
│   │       └── UserTests.swift
│   │
│   ├── DataTests/
│   │   ├── Repositories/
│   │   │   └── UserRepositoryTests.swift
│   │   └── Mappers/
│   │       └── UserMapperTests.swift
│   │
│   ├── PresentationTests/
│   │   └── ViewModels/
│   │       ├── LoginViewModelTests.swift
│   │       └── ProductListViewModelTests.swift
│   │
│   ├── IntegrationTests/
│   │   └── AuthenticationFlowTests.swift
│   │
│   └── Mocks/
│       ├── MockUserRepository.swift
│       ├── MockAuthenticationService.swift
│       └── MockAPIClient.swift
│
└── Resources/
    ├── Info.plist
    ├── Entitlements.entitlements
    └── Configuration/
        ├── Development.xcconfig
        ├── Staging.xcconfig
        └── Production.xcconfig
```

### Notas sobre la estructura:

#### **App** - Configuración y arranque
- Solo orquestación de alto nivel
- `DependencyContainer` construye todos los repositorios, use cases y coordinadores
- `AppCoordinator` maneja el flujo principal de navegación

#### **Domain** - Núcleo de negocio
- **100% independiente** de frameworks (no imports de SwiftUI/UIKit/SwiftData)
- `Entities`: Modelos de negocio puros con lógica de validación
- `UseCases`: Orquestadores de reglas de negocio (un caso de uso = una acción)
- `RepositoryProtocols` y `ServiceProtocols`: Contratos (puertos) que Data debe implementar
- `ValueObjects`: Tipos inmutables con validación intrínseca (ej: Email valida formato)

#### **Data** - Adaptadores e infraestructura
- Implementa todos los protocolos definidos en Domain
- `Repositories`: Coordinan entre DataSources y proveen datos al Domain
- `DataSources/Local`: SwiftData, UserDefaults, FileSystem, Keychain
- `DataSources/Remote`: API REST/GraphQL, servicios externos
- `DTOs`: Representación JSON/API (se convierte a Entities vía Mappers)
- `Mappers`: Traducción DTO ↔ Entity (aísla cambios de API)

#### **Presentation** - UI y lógica de presentación
- **Modules**: Un módulo por feature (Login, Products, Profile)
- Cada módulo tiene sus Views, ViewModels y Coordinator
- `ViewModels`: `@Observable` (Observation framework) con async/await
- `Coordinators`: Manejan navegación y dependencias del módulo
- `Common`: Componentes reutilizables, extensiones, modifiers

#### **DesignSystem** - Sistema de diseño
- **Tokens**: Variables de diseño (colores, tipografías, espaciados)
- **Atomic Design**:
  - `Atoms`: Botones, inputs, labels (no divisibles)
  - `Molecules`: Cards, list items (combinan atoms)
  - `Organisms`: Barras de navegación, tab bars (combinan molecules)
- `Resources`: Assets, String Catalogs, fonts
- `Localization`: Enum type-safe para strings localizados

#### **Core** - Utilidades compartidas
- Código transversal que puede usar cualquier capa
- Networking, Keychain, extensiones, loggers
- Protocolos base (Coordinator, UseCase, ViewModel)

#### **Tests**
- Estructura espejo del código fuente
- `Mocks/`: Implementaciones fake de protocolos para testing
- Tests unitarios (Domain, Data, Presentation)
- Tests de integración (flujos completos)

---

## Sistema Multilenguaje (Localization)

### Principios de localización
- **Idiomas soportados**: Inglés (base) y Español.
- **Código en inglés**: Nombres de variables, funciones, clases, comentarios técnicos.
- **Mensajes de usuario**: Completamente localizables (inglés/español).
- **Type-safe localization**: Usar Swift Macros o enums generados automáticamente para evitar strings mágicos.
- **Separación de responsabilidades**: La localización vive en la capa de Presentación y Design System, nunca en Dominio.

### Estrategia recomendada: String Catalogs (Xcode 15+)

Apple introdujo **String Catalogs** (`.xcstrings`) que reemplazan los antiguos `.strings` y `.stringsdict`. Proporcionan:
- Formato JSON legible y merge-friendly en control de versiones.
- Soporte nativo para pluralización, variaciones de género y dispositivo.
- Integración automática con SwiftUI (`Text`, `LocalizedStringKey`).
- Validación en tiempo de compilación.
- Extracción automática de strings desde código.

### Estructura de archivos de localización

```
DesignSystem/
  Resources/
    Localizable.xcstrings          # String catalog principal
    InfoPlist.xcstrings            # Localización de Info.plist
    
Presentation/
  Modules/
    Feature1/
      Resources/
        Feature1.xcstrings         # Strings específicos del módulo (opcional)
```

**Recomendación**: Usar un único `Localizable.xcstrings` centralizado en DesignSystem para la mayoría de strings, salvo que un módulo sea muy grande y requiera separación.

### Uso en SwiftUI

```swift
// ✅ Forma directa (Xcode extrae automáticamente al String Catalog)
Text("Welcome to the app")

// ✅ Con interpolación
Text("Hello, \(userName)")

// ✅ Con comentarios para traductores
Text("Save", comment: "Button to save user changes")

// ✅ Para strings en ViewModels o lógica
let message = String(localized: "Error loading data")
let formatted = String(localized: "You have \(count) notifications")
```

### Type-safe Localization: Enum generado

Para evitar typos y tener autocompletado, genera un enum a partir del String Catalog:

```swift
// DesignSystem/Localization/LocalizedString.swift
enum LocalizedString {
    enum Common {
        static let ok = String(localized: "common.ok")
        static let cancel = String(localized: "common.cancel")
        static let save = String(localized: "common.save")
        static let delete = String(localized: "common.delete")
    }
    
    enum Authentication {
        static let loginTitle = String(localized: "auth.login.title")
        static let emailPlaceholder = String(localized: "auth.email.placeholder")
        static func welcomeUser(_ name: String) -> String {
            String(localized: "auth.welcome.user \(name)")
        }
    }
    
    enum Errors {
        static let networkError = String(localized: "error.network")
        static let unknownError = String(localized: "error.unknown")
    }
}

// Uso en ViewModels
@Observable
final class LoginViewModel {
    var errorMessage: String = ""
    
    func login() async {
        do {
            try await authUseCase.login()
        } catch {
            errorMessage = LocalizedString.Errors.networkError
        }
    }
}

// Uso en Views
struct LoginView: View {
    @State private var viewModel: LoginViewModel
    
    var body: some View {
        VStack {
            Text(LocalizedString.Authentication.loginTitle)
            Button(LocalizedString.Common.save) {
                // action
            }
        }
    }
}
```

**Alternativa automatizada**: Usar herramientas como [SwiftGen](https://github.com/SwiftGen/SwiftGen) para generar enums automáticamente desde los String Catalogs.

### Pluralización y variaciones

Los String Catalogs soportan pluralización automática:

```swift
// En Localizable.xcstrings se define automáticamente:
// Key: "items.count"
// EN: "You have %lld item(s)" -> Variaciones: zero, one, other
// ES: "Tienes %lld artículo(s)" -> Variaciones: one, other

let count = 3
let message = String(localized: "You have \(count) items")
// EN: "You have 3 items"
// ES: "Tienes 3 artículos"
```

### Cambio dinámico de idioma

Por defecto, iOS usa el idioma del sistema. Para cambio manual dentro de la app:

```swift
// ❌ NO recomendado: Cambiar UserDefaults afecta toda la app y requiere reinicio

// ✅ Recomendado: Usar Environment override en SwiftUI (iOS 17+)
struct ContentView: View {
    @AppStorage("selectedLanguage") private var language = "en"
    
    var body: some View {
        MainAppView()
            .environment(\.locale, Locale(identifier: language))
    }
}
```

**Nota**: Para cambios persistentes, la mayoría de apps usan el idioma del sistema. Solo implementa cambio manual si es requisito específico.

### Testing de localización

```swift
import Testing

@Suite("Localization Tests")
struct LocalizationTests {
    
    @Test("All keys exist in both languages")
    func allKeysExistInBothLanguages() async throws {
        let bundle = Bundle.main
        
        // Verificar que todas las keys tienen traducción en español
        let esBundle = Bundle(path: bundle.path(forResource: "es", ofType: "lproj")!)
        #expect(esBundle != nil)
        
        // Validar keys críticas
        let okButton = String(localized: "common.ok", locale: Locale(identifier: "es"))
        #expect(okButton != "common.ok") // No debe devolver la key
    }
    
    @Test("Pluralization works correctly")
    func pluralizationWorks() {
        let oneItem = String(localized: "You have 1 items")
        let multipleItems = String(localized: "You have 5 items")
        
        #expect(oneItem.contains("1"))
        #expect(multipleItems.contains("5"))
    }
}
```

### Buenas prácticas

1. **Keys descriptivas**: Usa namespacing con puntos (`auth.login.title`, `error.network`).
2. **Contexto para traductores**: Siempre incluye `comment:` para strings ambiguos.
3. **No concatenes strings**: Usa interpolación para que traductores puedan reordenar.
   ```swift
   // ❌ Malo
   let msg = userName + " " + String(localized: "has logged in")
   
   // ✅ Bueno
   let msg = String(localized: "\(userName) has logged in")
   ```
4. **Extrae strings periódicamente**: Xcode puede extraer automáticamente strings del código al String Catalog (Product > Export Localizations).
5. **Revisa el String Catalog en Git**: El formato JSON es legible y hace merge fácil.
6. **Accesibilidad**: Los strings localizados funcionan automáticamente con VoiceOver.

### Localización de imágenes y assets

```swift
// En Asset Catalog, marca imágenes como "Localize" si tienen variantes por idioma
Image("onboarding_hero") // Carga automáticamente "onboarding_hero_es" si existe
```

### Dominio sin dependencia de localización

**Regla estricta**: El Dominio NO debe conocer `String(localized:)` ni `LocalizedString`.

```swift
// ❌ Mal: Dominio con localización
class AuthenticationUseCase {
    func login() throws {
        throw AuthError.invalidCredentials(message: String(localized: "Invalid credentials"))
    }
}

// ✅ Bien: Dominio con errores tipados
enum AuthError: Error {
    case invalidCredentials
    case networkFailure
    case sessionExpired
}

// La capa de Presentación mapea errores a strings localizados
@Observable
final class LoginViewModel {
    func handleError(_ error: AuthError) {
        switch error {
        case .invalidCredentials:
            errorMessage = LocalizedString.Errors.invalidCredentials
        case .networkFailure:
            errorMessage = LocalizedString.Errors.networkError
        case .sessionExpired:
            errorMessage = LocalizedString.Errors.sessionExpired
        }
    }
}
```

### Checklist de implementación

- [ ] Crear `Localizable.xcstrings` en DesignSystem/Resources
- [ ] Configurar idiomas en Project Settings > Info > Localizations (English, Spanish)
- [ ] Definir enum `LocalizedString` con namespaces claros
- [ ] Extraer todas las strings hardcodeadas a localizables
- [ ] Agregar comentarios (`comment:`) para contexto de traductores
- [ ] Implementar tests de localización básicos
- [ ] (Opcional) Integrar SwiftGen para generación automática
- [ ] Validar que Dominio no importa recursos de localización
- [ ] Revisar que AccessibilityLabels también están localizados

### Herramientas recomendadas

- **Xcode String Catalogs**: Herramienta nativa, sin dependencias externas.
- **SwiftGen**: Generación de código type-safe desde String Catalogs.
- **Localazy/Crowdin**: Plataformas de traducción colaborativa (si trabajas con traductores externos).
- **Pseudo-localization**: Técnica para detectar strings no localizables (añade caracteres especiales para testing).

