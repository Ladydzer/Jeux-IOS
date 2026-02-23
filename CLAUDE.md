# CLAUDE.md — ShadowQuest iOS RPG

## Commandes de build / test

```bash
# Build le projet (depuis la racine du repo)
xcodebuild -scheme ShadowQuest -destination 'platform=iOS Simulator,name=iPhone 15,OS=17.0' build

# Lancer les tests
xcodebuild -scheme ShadowQuest -destination 'platform=iOS Simulator,name=iPhone 15,OS=17.0' test

# Build en mode release
xcodebuild -scheme ShadowQuest -configuration Release -destination 'generic/platform=iOS' build
```

> **Note** : Le projet n'a pas encore de scheme Xcode. Ces commandes seront fonctionnelles une fois le `.xcodeproj` créé manuellement dans Xcode.

---

## Architecture du projet

### MVVM stricte

```
View  →  ViewModel  →  Model / Service
(SwiftUI)  (ObservableObject)  (SwiftData / Logic)
```

- **Views** : Uniquement de l'affichage. Zéro logique métier. Bindées aux ViewModels via `@StateObject` ou `@EnvironmentObject`.
- **ViewModels** : Toute la logique de présentation. Marqués `@Observable` (iOS 17+). Appellent les Services.
- **Models** : Structures de données pures. Annotés `@Model` pour SwiftData quand persistés.
- **Services** : Logique métier lourde (combat engine, sauvegarde, audio). Injectés dans les ViewModels.

### Conventions de nommage

| Élément | Convention | Exemple |
|---|---|---|
| Fichiers Swift | PascalCase | `CombatViewModel.swift` |
| Variables / fonctions | camelCase | `playerHealth`, `calculateDamage()` |
| Constantes globales | camelCase dans enum `Constants` | `Constants.maxLevel` |
| Protocols | PascalCase + suffixe `-able` ou `-ing` | `Damageable`, `Saving` |
| Enums | PascalCase, cases en camelCase | `PlayerClass.warrior` |
| Views SwiftUI | PascalCase + suffixe `View` | `CombatView` |
| ViewModels | PascalCase + suffixe `ViewModel` | `CombatViewModel` |
| SpriteKit Scenes | PascalCase + suffixe `Scene` | `CombatScene` |

### Structure des dossiers

```
ShadowQuest/
├── App/                    # Point d'entrée de l'app
│   ├── ShadowQuestApp.swift
│   └── ContentView.swift
├── Models/                 # Modèles de données (SwiftData)
│   ├── Player.swift
│   ├── Monster.swift
│   ├── Item.swift
│   ├── Skill.swift
│   └── GameState.swift
├── ViewModels/             # Logique de présentation
│   ├── GameViewModel.swift
│   ├── CombatViewModel.swift
│   ├── InventoryViewModel.swift
│   └── MapViewModel.swift
├── Views/                  # Interface utilisateur SwiftUI
│   ├── MainMenu/
│   │   └── MainMenuView.swift
│   ├── CharacterCreation/
│   │   └── CharacterCreationView.swift
│   ├── Map/
│   │   └── WorldMapView.swift
│   ├── Combat/
│   │   ├── CombatView.swift
│   │   └── CombatScene.swift      # SpriteKit
│   ├── Inventory/
│   │   └── InventoryView.swift
│   └── Components/                 # Composants réutilisables
│       ├── HealthBar.swift
│       ├── StatView.swift
│       └── ItemCard.swift
├── Services/               # Logique métier
│   ├── DataService.swift
│   ├── AudioService.swift
│   └── CombatEngine.swift
├── Utils/                  # Utilitaires
│   ├── Constants.swift
│   ├── Extensions.swift
│   └── Theme.swift
└── Resources/              # Assets
    ├── Assets.xcassets/
    └── Sounds/
```

---

## Stack technique — Décisions et justifications

| Décision | Choix | Pourquoi |
|---|---|---|
| UI Framework | SwiftUI | Framework moderne Apple, déclaratif, parfait pour les menus/inventaire/map |
| Combat rendering | SpriteKit | SwiftUI n'est pas fait pour du rendu temps réel. SpriteKit est natif et intégré via `SpriteView` |
| Persistance | SwiftData | Successeur natif de CoreData, API Swift-native, compatible iOS 17+ |
| Architecture | MVVM | Standard industrie pour SwiftUI, séparation claire des responsabilités |
| Target iOS | 17.0+ | Requis pour SwiftData et `@Observable` macro |
| Dépendances | Aucune (0 SPM) | Zéro dépendance externe = zéro risque de casse, tout natif Apple |
| Navigation | NavigationStack | API moderne iOS 16+, path-based navigation |
| State management | `@Observable` (Observation framework) | Plus performant que `ObservableObject`, moins de boilerplate, iOS 17+ |

---

## Pièges iOS à éviter

### SwiftUI
- **Ne jamais mettre de logique dans les `body`** des Views. Le `body` est recalculé souvent — garder ça pur.
- **`@State` est pour l'état local de la View uniquement.** Pour l'état partagé → `@Observable` ViewModel.
- **`NavigationStack` et pas `NavigationView`** — `NavigationView` est deprecated depuis iOS 16.
- **Les animations dans SwiftUI doivent utiliser `withAnimation {}`** ou le modifier `.animation()`. Ne pas mélanger les deux approches dans la même View.
- **Attention aux closures qui capturent `self`** dans les ViewModels — risque de retain cycles avec `[weak self]`.

### SpriteKit + SwiftUI
- **`SpriteView` doit être wrappé correctement.** Ne pas recréer la `SKScene` à chaque re-render SwiftUI → stocker la scene dans un `@State` ou le ViewModel.
- **Le coordinate system SpriteKit est inversé** par rapport à SwiftUI (Y=0 en bas pour SK, en haut pour SwiftUI).
- **Ne pas oublier `isPaused`** sur la SpriteView quand on navigue ailleurs — sinon la scene continue de tourner en arrière-plan.

### SwiftData
- **`@Model` classes doivent avoir un `init()` par défaut** sinon SwiftData crash silencieusement.
- **Les relations SwiftData doivent être optionnelles** ou avoir des valeurs par défaut.
- **Ne pas appeler `modelContext.save()` manuellement** sauf besoin explicite — SwiftData auto-save.
- **Tester les migrations tôt.** Changer un `@Model` après avoir des données locales = migration obligatoire.

### Général iOS
- **Jamais de force unwrap (`!`) en production.** Utiliser `guard let` ou `if let`.
- **Les images/assets doivent être dans `Assets.xcassets`** pour le cache et la mémoire.
- **Tester sur simulateur ET device** — les performances SpriteKit diffèrent fortement.
- **Jamais modifier le `.pbxproj` à la main** — toujours passer par Xcode pour ajouter des fichiers au projet.

---

## Roadmap du projet

### Phase 1 — Fondations
- Setup du projet Xcode (manuellement)
- Modèles de données (Player, Monster, Item, Skill, GameState)
- Écran menu principal
- Écran de création de personnage (choix nom + classe)
- Navigation de base entre les écrans
- Persistance SwiftData (sauvegarder/charger une partie)

### Phase 2 — Carte du monde & Exploration
- WorldMapView avec des nodes cliquables
- Système de progression (nodes débloqués au fur et à mesure)
- Différents types de nodes : Combat, Repos, Marchand, Boss
- Transitions animées entre les écrans

### Phase 3 — Système de combat
- CombatScene en SpriteKit (rendu des sprites, animations)
- CombatEngine : logique tour par tour
- Système de compétences par classe (3-4 skills par classe)
- IA des monstres (basique : aléatoire pondéré)
- UI de combat (barre de vie, boutons skills, feedback visuel)

### Phase 4 — Inventaire & Équipement
- Modèle Item complet (armes, armures, potions)
- InventoryView avec grille d'items
- Système d'équipement (modifier les stats du joueur)
- Loot après combat
- Marchand (acheter/vendre)

### Phase 5 — Progression & Contenu
- Système d'XP et de montée de niveau
- Statistiques qui augmentent par niveau et par classe
- Bestiaire varié (10+ monstres différents)
- 3 zones avec boss de fin de zone
- Balancing des stats et dégâts

### Phase 6 — Polish
- Effets sonores et musique (AudioService)
- Animations et transitions soignées
- Écran de game over / victoire
- Écran de stats/résumé de partie
- Tests unitaires sur CombatEngine et modèles
