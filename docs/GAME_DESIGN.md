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

## Boucle de jeu v0.3

1. Le joueur quitte la zone portuaire.
2. Des ennemis apparaissent depuis plusieurs points de spawn.
3. Le joueur combat des variantes de menace différente.
4. Chaque ennemi détruit augmente le compteur global.
5. Tous les 3 ennemis détruits, le niveau de danger augmente.
6. Le danger et la zone influencent les ennemis qui apparaissent.
7. Le HUD affiche danger, ennemis détruits et feedback de loot.

## Port et progression

Le port sert de premier point sûr et de première interface de progression. Il ne contient pas encore de commerce avancé, de missions ou de PNJ, mais il établit le rythme attendu : partir en mer, obtenir des ressources, revenir au port, réparer et améliorer le bateau.

Les améliorations de v0.2 restent volontairement simples :

- Coque renforcée : augmente les PV max.
- Voiles rapides : augmente la vitesse max.
- Canons améliorés : augmente les dégâts des boulets.

## Ennemis et danger v0.3

Trois variantes posent la base de difficulté :

- Petit pirate : faible PV, rapide, dégâts faibles, loot faible.
- Brigantin pirate : PV moyens, vitesse moyenne, dégâts moyens, loot moyen.
- Patrouilleur lourd : beaucoup de PV, lent, dégâts élevés, loot meilleur.

Les zones de danger structurent la carte de test :

- Zone portuaire : danger faible, surtout petits pirates.
- Zone d'archipel : danger moyen, petits pirates et brigantins.
- Zone hostile : danger élevé, brigantins et patrouilleurs lourds.

Le niveau de danger global démarre à 1 et augmente tous les 3 ennemis détruits. Il ne remplace pas les zones : il rend progressivement les spawns plus dangereux dans toutes les zones.

## Lisibilité combat v0.3.2

Les ennemis doivent être immédiatement lisibles et réellement menaçants :

- Chaque variante possède une portée d'attaque, un cooldown et des dégâts propres.
- Le joueur reçoit un feedback clair quand son bateau est détruit.
- Les silhouettes ennemies utilisent des primitives différentes pour distinguer vitesse, taille et danger.
- Les nameplates affichent le type et les PV des ennemis.
- Les zones de danger affichent une notification quand le joueur change de zone.

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

## Hors scope v0.3

- Îles explorables.
- Coffres et trésors.
- Missions.
- Alliés et flotte.
- Abordage.
- Sauvegarde persistante.
