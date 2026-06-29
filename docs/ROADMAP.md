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
- Correctif v0.6.1 : coûts de port affichés, réparation dynamique joueur/allié, allié ciblable, vraie visée de bordée, dégâts garantis et kills alliés crédités au joueur.

## v0.7 - Flotte basique avec ordres simples

- Gérer jusqu'à 3 bateaux alliés.
- Ajouter un recrutement progressif au port.
- Ajouter une formation simple de suivi.
- Éviter les collisions les plus visibles entre alliés et joueur.
- Ajouter des ordres simples : suivre, attaquer, protéger, fuir.
- Afficher la flotte, l'ordre courant et les PV alliés dans le HUD.
- Ajouter une réparation de flotte au port.

## v0.8 - Réputation et titres pirates

- Ajouter une réputation pirate simple.
- Ajouter des rangs de réputation.
- Débloquer des titres selon les actions du joueur.
- Donner de la réputation via combat, missions, coffres, reliques et flotte.
- Afficher réputation et titre dans le HUD.
- Ajouter un panneau `Statut pirate` au port.

- Correctif v0.8.1 : empecher le farm de reputation par rachat d'allies apres destruction.
- Refonte UI pirate : theme sombre, barre de ressources haute, panneau navire/flotte, panneau reputation/titre, menu portuaire central et onglets bas.
- Finition v0.8.2 : HUD compact en mer, HUD detaille avec `TAB`, sections plus lisibles et verification des entrees gameplay.
- Correctifs v0.8.3 : F3 renommee debug, renommee de recompense mission, perte de renommee a la defaite, anti-friendly-fire flotte, respawn port securise et HUD compacte.
- Correctifs v0.8.4 : plafonds renommee/titre, refresh UI apres F3, affichage maximum propre, libelles compacts ameliores, notifications de zone separees, detection/leash ennemis et zone sure portuaire renforcee.
- Ajustement HUD compact : retour a un panneau vertical gauche, barre de ressources conservee en haut et notifications de zone separees.

## v0.9 - Hiérarchie des navires

- Différencier davantage les rôles des navires alliés et ennemis.
- Préparer des classes de navires plus lisibles.
- Relier la hiérarchie aux coûts, PV, vitesse et puissance de bordée.

## v1.0 - Démo jouable complète

- Boucle complète : partir du port, naviguer, combattre, looter, réparer, améliorer, recruter et accomplir des missions.
- Zone de jeu limitée mais cohérente.
- Interface propre pour ressources, PV, missions, flotte et ordres.
- Build exportable pour test externe.

## v1.1 - Hiérarchie des ports et commerce

- Ajouter plus d'options de port.
- Préparer un commerce simple entre ressources.
- Donner plus de rôle aux ports dans la progression.

## v1.2 - Hiérarchie des trésors avancée

- Différencier les types de trésors.
- Relier les reliques et fragments à des récompenses plus rares.
- Préparer des collections ou découvertes majeures.

## v1.3 - Zones de danger avancées

- Rendre les zones de danger plus évolutives.
- Relier danger, réputation et types d'ennemis.
- Préparer des routes maritimes plus risquées.
