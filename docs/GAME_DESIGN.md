# Game Design - Pavillon Libre

## Intention

Creer une aventure pirate originale, lisible et evolutive, centree sur la navigation, le combat naval simple, l'exploration et la progression d'un equipage.

Le joueur incarne le capitaine d'un petit navire independant qui construit progressivement sa route, ses ressources, son equipage et sa flotte. La v0.1 ne cherche pas encore a raconter une campagne : elle valide le socle navigation-combat-loot.

## Principes

- Direction artistique simple basee sur des primitives Godot en v0.1.
- Aucun asset externe pour la premiere base jouable.
- Aucun contenu protege, aucune marque ou licence existante reprise.
- Gameplay prioritaire sur le rendu : chaque ajout doit etre testable rapidement.
- Scenes et scripts separes par domaine pour faciliter les prochaines versions.

## Boucle de jeu v0.1

1. Le joueur controle un bateau.
2. Il navigue sur une mer de test.
3. Il tire au canon a gauche ou a droite.
4. Il affronte un bateau ennemi basique.
5. La destruction de l'ennemi donne des ressources simples.

## Boucle de jeu v0.2

1. Le joueur navigue, combat et récupère or et bois.
2. Il revient au port proche du spawn.
3. Il ouvre le menu du port avec `E`.
4. Il répare sa coque avec du bois.
5. Il dépense or et bois pour améliorer coque, voiles et canons.
6. Le HUD confirme la progression du bateau.

## Port et progression

Le port sert de premier point sûr et de première interface de progression. Il ne contient pas encore de commerce avancé, de missions ou de PNJ, mais il établit le rythme attendu : partir en mer, obtenir des ressources, revenir au port, réparer et améliorer le bateau.

Les améliorations de v0.2 restent volontairement simples :

- Coque renforcée : augmente les PV max.
- Voiles rapides : augmente la vitesse max.
- Canons améliorés : augmente les dégâts des boulets.

## Piliers a long terme

- Navigation lisible : le joueur doit toujours comprendre son cap, sa vitesse et les menaces proches.
- Combat naval direct : tirs lateraux, placement, cooldowns et risques de collision.
- Progression claire : ressources, reparations, ameliorations et nouveaux bateaux.
- Exploration : iles, ports, routes maritimes, missions et rencontres.
- Flotte : recruter des allies et gerer une petite escadre.

## Hors scope v0.1

- Ocean realiste.
- Systeme de port.
- Inventaire detaille.
- Sauvegarde.
- Missions narratives.
- Assets definitifs.

## Hors scope v0.2

- Respawn d'ennemis.
- Sauvegarde des ressources et améliorations.
- Économie de port complète.
- Îles explorables.
- Missions.
- Gestion de flotte.
