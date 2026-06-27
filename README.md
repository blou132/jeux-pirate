# Pavillon Libre

Prototype Godot 4.x original pour un jeu d'aventure pirate.

Le projet n'utilise aucun asset externe et ne reprend aucune marque, aucun nom, aucun modèle et aucun contenu protégé. La v0.1 pose une base jouable propre : bateau joueur, mer de test, combat basique, ennemi et loot simple.

La v0.1 a été testée manuellement par l'utilisateur dans Godot : scène World lancée, bateau contrôlable, HUD visible, ennemi présent, combat fonctionnel et loot ajouté après destruction.

La v0.2 ajoute un port de test, une interaction au port, un menu, la réparation du bateau, trois améliorations et un HUD de progression.

La v0.3 ajoute le spawn d'ennemis, le respawn après destruction, trois variantes d'ennemis, un niveau de danger global, des zones de danger simples et un feedback de victoire plus lisible.

La v0.3.2 améliore la jouabilité de la v0.3 : attaque ennemie effective, feedback de défaite du joueur, silhouettes ennemies plus distinctes, noms au-dessus des ennemis et notifications d'entrée de zone.

## Etat v0.1

- Projet Godot 4.x minimal avec scene principale.
- Bateau joueur en primitives Godot, avec inertie simple.
- Camera 3D attachee au bateau.
- HUD vitesse, PV, or et bois.
- Mer plane de test avec reperes visuels.
- Canons babord/tribord avec boulets, cooldown et degats.
- Ennemi de test avec detection, poursuite et destruction.
- Loot simple donnant or et bois.

## Etat v0.2

- Port proche du point de départ avec zone d'interaction.
- Message contextuel quand le bateau est proche du port.
- Menu "Port du Pavillon" ouvrable avec `E` et fermable avec `Échap` ou `Quitter`.
- Réparation au port : 1 bois répare 5 PV.
- Améliorations niveau 0 à 3 : coque renforcée, voiles rapides, canons améliorés.
- HUD étendu : PV, vitesse, or, bois et niveaux d'amélioration.

## Etat v0.3

- SpawnManager avec plusieurs points de spawn.
- Respawn d'ennemis après destruction avec délai.
- Variantes : Petit pirate, Brigantin pirate, Patrouilleur lourd.
- Niveau de danger global et compteur d'ennemis détruits dans le HUD.
- Zones de danger simples : portuaire, archipel, hostile.
- Spawns pondérés par niveau de danger et zone.
- Message HUD quand un ennemi est vaincu avec loot reçu.
- Debug temporaire `F1`/`F2` encore présent pour tester les achats d'amélioration.

## Equilibrage v0.3.1

- Vitesse de base du bateau joueur réduite à 7.0.
- Voiles rapides : vitesse max 8.0 au niveau 1, 9.0 au niveau 2, 10.0 au niveau 3.
- Vitesses ennemies ajustées : Petit pirate rapide, Brigantin moyen, Patrouilleur lourd lent.

## Correctifs v0.3.2

- Les ennemis attaquent le joueur avec portée, cooldown et dégâts par type.
- Le HUD affiche `Bateau détruit` quand le joueur arrive à 0 PV.
- Les variantes ennemies ont des silhouettes plus lisibles.
- Les ennemis affichent un nom et leurs PV au-dessus du bateau.
- L'entrée dans une zone affiche une notification claire : portuaire, archipel ou hostile.

## Lancement

1. Installer Godot 4.x.
2. Ouvrir le dossier du depot comme projet Godot.
3. Ouvrir la scène principale `res://scenes/world/World.tscn`.
4. Appuyer sur Play.

Godot n'est pas inclus dans ce depot.

## Controles prevus

- `Z` / `W` : avancer
- `S` : ralentir ou marche arriere legere
- `Q` / `A` : tourner a gauche
- `D` : tourner a droite
- Clic gauche : canon gauche
- Clic droit : canon droit
- `E` : interagir avec le port
- `Échap` : fermer le menu

## Debug développement

Outil temporaire pour tester les améliorations sans farmer les ressources :

- `F1` : ajoute 100 or
- `F2` : ajoute 100 bois

Ces raccourcis sont activés via `DebugTools` et doivent rester identifiés comme aide de développement.

## Structure

- `scenes/` : scenes Godot reutilisables
- `scripts/` : scripts GDScript organises par domaine
- `docs/` : design, feuille de route et notes de production

## Notes techniques

- `GameState` est configure en autoload pour suivre les ressources joueur.
- `UpgradeSystem` est configure en autoload pour suivre les niveaux d'amélioration.
- `SpawnManager` gère les ennemis actifs, le respawn et la sélection des variantes.
- `World.tscn` est la scene de test jouable.
- Les assets visuels de v0.1 sont des primitives Godot creees dans les scenes ou par script.
