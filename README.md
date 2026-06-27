# Pavillon Libre

Prototype Godot 4.x original pour un jeu d'aventure pirate.

Le projet n'utilise aucun asset externe et ne reprend aucune marque, aucun nom, aucun modele et aucun contenu protege. La v0.1 pose une base jouable propre : bateau joueur, mer de test, combat basique, ennemi et loot simple.

## Etat v0.1

- Projet Godot 4.x minimal avec scene principale.
- Bateau joueur en primitives Godot, avec inertie simple.
- Camera 3D attachee au bateau.
- HUD vitesse, PV, or et bois.
- Mer plane de test avec reperes visuels.
- Canons babord/tribord avec boulets, cooldown et degats.
- Ennemi de test avec detection, poursuite et destruction.
- Loot simple donnant or et bois.

## Lancement

1. Installer Godot 4.x.
2. Ouvrir le dossier du depot comme projet Godot.
3. Lancer la scene principale `res://scenes/world/World.tscn` ou appuyer sur Play.

Godot n'est pas inclus dans ce depot.

## Controles prevus

- `Z` / `W` : avancer
- `S` : ralentir ou marche arriere legere
- `Q` / `A` : tourner a gauche
- `D` : tourner a droite
- Clic gauche : tirer a gauche
- Clic droit : tirer a droite

## Structure

- `scenes/` : scenes Godot reutilisables
- `scripts/` : scripts GDScript organises par domaine
- `docs/` : design, feuille de route et notes de production

## Notes techniques

- `GameState` est configure en autoload pour suivre les ressources joueur.
- `World.tscn` est la scene de test jouable.
- Les assets visuels de v0.1 sont des primitives Godot creees dans les scenes ou par script.
