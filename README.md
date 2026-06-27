# Pavillon Libre

Prototype Godot 4.x original pour un jeu d'aventure pirate.

Le projet n'utilise aucun asset externe et ne reprend aucune marque, aucun nom, aucun modèle et aucun contenu protégé. La v0.1 pose une base jouable propre : bateau joueur, mer de test, combat basique, ennemi et loot simple.

La v0.1 a été testée manuellement par l'utilisateur dans Godot : scène World lancée, bateau contrôlable, HUD visible, ennemi présent, combat fonctionnel et loot ajouté après destruction.

La v0.2 ajoute un port de test, une interaction au port, un menu, la réparation du bateau, trois améliorations et un HUD de progression.

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
- `World.tscn` est la scene de test jouable.
- Les assets visuels de v0.1 sont des primitives Godot creees dans les scenes ou par script.
