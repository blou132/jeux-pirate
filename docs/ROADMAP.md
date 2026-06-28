# Roadmap

## v0.1 - Base jouable

- Projet Godot 4.x organise.
- Bateau joueur controlable.
- Scene de mer de test.
- Combat naval basique.
- Ennemi simple.
- Loot et ressources simples.

## v0.2 - Port, réparations et améliorations

- Ajouter un port de test.
- Permettre au joueur de reparer le bateau contre du bois.
- Ajouter une zone d'amarrage simple.
- Ajouter trois améliorations : coque, voiles, canons.
- Afficher la progression dans le HUD.

## v0.3 - Respawn ennemis et difficulté progressive

- Faire réapparaître des ennemis après destruction.
- Augmenter progressivement la difficulté.
- Ajouter des variantes d'ennemis.
- Afficher danger et ennemis détruits dans le HUD.
- Ajouter des zones de danger simples.
- Correctif v0.3.2 : attaque ennemie, feedback de défaite joueur, variantes plus lisibles, nameplates, notifications de zone.
- Correctif v0.3.3 : tirs ennemis visibles, feedback quand le joueur est touché, respawn avec `R` après destruction.
- Correctif v0.3.4 : tirs ennemis limités aux bordées, tirs joueur désactivés après destruction, limites de carte et feedback de sortie.
- Correctif v0.3.5 : direction des tirs ennemis corrigée, projectiles tirés depuis les côtés, manœuvre de flanc améliorée.
- Correctif v0.3.6 : orientation ennemie avant tir améliorée, manœuvre de bordée ralentie, tir autorisé seulement avec un flanc bien aligné.
- Correctif v0.3.7 : point de visée joueur, points de tir latéraux ennemis, alignement de bordée sur axes réels et debug visuel temporaire.
- Correctif v0.3.8 : validation de tir par distance à la ligne de bordée, lignes debug de visée et réglage du positionnement ennemi.
- Correctif v0.3.9 : rotation ennemie plus fluide avec inertie, valeurs de rotation par type, manœuvre de bordée moins rigide et verrouillage temporaire du côté de tir.

## v0.4 - Îles explorables, coffres et trésors

- Ajouter trois îles explorables.
- Ajouter une interaction avec `E` près du rivage.
- Ajouter un menu simple de fouille.
- Ajouter un coffre unique par île.
- Ajouter fragments de carte et reliques anciennes.

## v0.5 - Missions simples

- Ajouter un système de missions simple.
- Ajouter une section `Missions` au port.
- Ajouter des missions de combat, exploration, relique et retour au port.
- Afficher les missions actives dans le HUD.
- Ajouter des récompenses de missions récupérables au port.
- Correctif v0.5.1 : plusieurs missions actives, objectifs de quête générés à l'acceptation, coffres de quête indépendants et nettoyage des objectifs terminés.

## v0.6 - Premier bateau allié

- Ajouter un Sloop allié de base.
- Ajouter le recrutement au port contre ressources.
- Lui faire suivre le joueur à distance lisible.
- Ajouter un soutien de combat simple contre les ennemis proches.
- Gérer sa destruction et permettre un nouveau recrutement.

## v0.7 - Flotte basique avec ordres simples

- Gerer plusieurs bateaux allies.
- Ajouter une formation simple.
- Eviter les collisions les plus visibles.
- Ajouter des ordres simples : suivre, tenir position, attaquer.

## v0.8 - Abordage simple

- Ajouter une action d'abordage à courte portée.
- Récompenser l'abordage avec plus de ressources.
- Poser une première base de risque/recompense.

## v0.9 - Carte du monde

- Préparer une carte simple des zones découvertes.
- Utiliser les fragments de carte comme première ressource d'exploration.
- Afficher les îles connues et les zones dangereuses.

## v1.0 - Demo jouable

- Boucle complete : partir du port, naviguer, combattre, looter, reparer et ameliorer.
- Zone de jeu limitee mais coherente.
- Interface propre pour les ressources, PV et objectifs.
- Build exportable pour test externe.
