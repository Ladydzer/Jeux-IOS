# ShadowQuest — Dark Fantasy RPG pour iOS

Un jeu RPG dark fantasy en tour par tour, construit entierement en Swift natif avec SwiftUI et SpriteKit.

## Concept

Le joueur incarne un heros dans un univers dark fantasy. Il explore une carte du monde node par node, affronte des monstres en combat tour par tour, collecte du loot et fait progresser son personnage.

**3 classes jouables :**
- **Guerrier** — Fort en defense, degats physiques eleves, competences de tank
- **Mage** — Degats magiques de zone, fragile mais puissant, competences elementaires
- **Assassin** — Rapide, critique eleve, competences de furtivite et poison

## Stack technique

| Composant | Technologie |
|---|---|
| Interface | SwiftUI |
| Combat (rendu) | SpriteKit |
| Persistance | SwiftData |
| Architecture | MVVM |
| Target | iOS 17.0+ |
| Dependances | Aucune (100% natif Apple) |
| Swift | 5.9+ |

## Structure du projet

```
ShadowQuest/
├── App/                 # Point d'entree
├── Models/              # Modeles de donnees (SwiftData)
├── ViewModels/          # Logique de presentation
├── Views/               # Ecrans SwiftUI + SpriteKit
│   ├── MainMenu/
│   ├── CharacterCreation/
│   ├── Map/
│   ├── Combat/
│   ├── Inventory/
│   └── Components/
├── Services/            # Logique metier
├── Utils/               # Constantes, extensions, theme
└── Resources/           # Assets et sons
```

## Comment builder le projet

### Prerequis
- macOS 14.0+ (Sonoma)
- Xcode 15.0+
- iOS 17.0+ Simulator ou device

### Build
1. Cloner le repo
2. Ouvrir `ShadowQuest.xcodeproj` dans Xcode
3. Selectionner un simulateur iOS 17+
4. Cmd+R pour lancer

### Tests
```bash
Cmd+U dans Xcode
# ou
xcodebuild -scheme ShadowQuest -destination 'platform=iOS Simulator,name=iPhone 15,OS=17.0' test
```

## Screenshots

> *A venir — le projet est en cours de developpement.*

## Roadmap

- [x] Phase 1 — Fondations (modeles, navigation, persistence)
- [ ] Phase 2 — Carte du monde & exploration
- [ ] Phase 3 — Systeme de combat (SpriteKit)
- [ ] Phase 4 — Inventaire & equipement
- [ ] Phase 5 — Progression & contenu
- [ ] Phase 6 — Polish (audio, animations, tests)

## Licence

Projet personnel — Tous droits reserves.
