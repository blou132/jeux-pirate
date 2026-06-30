# Roadmap

## v0.1 - Base jouable

- Projet Godot 4.x organise.
- Bateau joueur controlable.
- Scene de mer de test.
- Combat naval basique.
- Ennemi simple.
- Loot et ressources simples.

## v0.2 - Port, reparations et ameliorations

- Ajouter un port de test.
- Permettre au joueur de reparer le bateau contre du bois.
- Ajouter une zone d'amarrage simple.
- Ajouter trois ameliorations : coque, voiles, canons.
- Afficher la progression dans le HUD.

## v0.3 - Respawn ennemis et difficulte progressive

- Faire reapparaitre des ennemis apres destruction.
- Augmenter progressivement la difficulte.
- Ajouter des variantes d'ennemis.
- Afficher danger et ennemis detruits dans le HUD.
- Ajouter des zones de danger simples.
- Correctif v0.3.2 : attaque ennemie, feedback de defaite joueur, variantes plus lisibles, nameplates, notifications de zone.
- Correctif v0.3.3 : tirs ennemis visibles, feedback quand le joueur est touche, respawn avec `R` apres destruction.
- Correctif v0.3.4 : tirs ennemis limites aux bordees, tirs joueur desactives apres destruction, limites de carte et feedback de sortie.
- Correctif v0.3.5 : direction des tirs ennemis corrigee, projectiles tires depuis les cotes, manoeuvre de flanc amelioree.
- Correctif v0.3.6 : orientation ennemie avant tir amelioree, manoeuvre de bordee ralentie, tir autorise seulement avec un flanc bien aligne.
- Correctif v0.3.7 : point de visee joueur, points de tir lateraux ennemis, alignement de bordee sur axes reels et debug visuel temporaire.
- Correctif v0.3.8 : validation de tir par distance a la ligne de bordee, lignes debug de visee et reglage du positionnement ennemi.
- Correctif v0.3.9 : rotation ennemie plus fluide avec inertie, valeurs de rotation par type, manoeuvre de bordee moins rigide et verrouillage temporaire du cote de tir.

## v0.4 - Iles explorables, coffres et tresors

- Ajouter trois iles explorables.
- Ajouter une interaction avec `E` pres du rivage.
- Ajouter un menu simple de fouille.
- Ajouter un coffre unique par ile.
- Ajouter fragments de carte et reliques anciennes.

## v0.5 - Missions simples

- Ajouter un systeme de missions simple.
- Ajouter une section `Missions` au port.
- Ajouter des missions de combat, exploration, relique et retour au port.
- Afficher les missions actives dans le HUD.
- Ajouter des recompenses de missions recuperables au port.
- Correctif v0.5.1 : plusieurs missions actives, objectifs de quete generes a l'acceptation, coffres de quete independants et nettoyage des objectifs termines.

## v0.6 - Premier bateau allie

- Ajouter un Sloop allie de base.
- Ajouter le recrutement au port contre ressources.
- Lui faire suivre le joueur a distance lisible.
- Ajouter un soutien de combat simple contre les ennemis proches.
- Gerer sa destruction et permettre un nouveau recrutement.
- Correctif v0.6.1 : couts de port affiches, reparation dynamique joueur/allie, allie ciblable, vraie visee de bordee, degats garantis et kills allies credites au joueur.

## v0.7 - Flotte basique avec ordres simples

- Gerer jusqu'a 3 bateaux allies.
- Ajouter un recrutement progressif au port.
- Ajouter une formation simple de suivi.
- Eviter les collisions les plus visibles entre allies et joueur.
- Ajouter des ordres simples : suivre, attaquer, proteger, fuir.
- Afficher la flotte, l'ordre courant et les PV allies dans le HUD.
- Ajouter une reparation de flotte au port.

## v0.8 - Reputation et titres pirates

- Ajouter une reputation pirate simple.
- Ajouter des rangs de reputation.
- Debloquer des titres selon les actions du joueur.
- Donner de la reputation via combat, missions, coffres, reliques et flotte.
- Afficher reputation et titre dans le HUD.
- Ajouter un panneau `Statut pirate` au port.
- Correctif v0.8.1 : empecher le farm de reputation par rachat d'allies apres destruction.
- Refonte UI pirate : theme sombre, barre de ressources haute, panneau navire/flotte, panneau reputation/titre, menu portuaire central et onglets bas.
- Finition v0.8.2 : HUD compact en mer, HUD detaille avec `TAB`, sections plus lisibles et verification des entrees gameplay.
- Correctifs v0.8.3 : F3 renommee debug, renommee de recompense mission, perte de renommee a la defaite, anti-friendly-fire flotte, respawn port securise et HUD compacte.
- Correctifs v0.8.4 : plafonds renommee/titre, refresh UI apres F3, affichage maximum propre, libelles compacts ameliores, notifications de zone separees, detection/leash ennemis et zone sure portuaire renforcee.
- Ajustement HUD compact : retour a un panneau vertical gauche, barre de ressources conservee en haut et notifications de zone separees.
- Correctifs v0.8.5 : detection ennemie 40/48/55, leash 65/75/85, zone portuaire 45/60/3s, densite de rencontres restauree et noms Renom/Titres clarifies.

## v0.9 - Hierarchie des navires

- Ajouter `ShipCatalog` comme catalogue central des navires joueur.
- Ajouter Barque, Chaloupe, Sloop et Goelette comme navires jouables.
- Ajouter un chantier naval au port pour acheter et equiper les navires.
- Appliquer les stats du navire joueur : PV, vitesse, maniabilite, stockage prepare et degats de canon.
- Afficher le navire actif dans le HUD.
- Afficher la hierarchie complete avec les navires futurs marques `a venir`.
- Donner a chaque navire ses propres plafonds d'amelioration et ses propres niveaux conserves.
- Correctif v0.9.1 : restaurer le ciblage ennemi apres changement de navire, limiter la zone sure au port et separer leash de poursuite et cooldown portuaire.
- Correctif v0.9.2 : augmenter detection, leash, portee d'engagement, bonus de vitesse en poursuite et vitesse des boulets ennemis contre les navires rapides.

## v0.10 - Cargaison et commerce

- Ajouter une cargaison limitee par le stockage du navire actif.
- Ajouter les marchandises Rhum, Epices, Tissu, Minerai et Perles.
- Ajouter poids, prix d'achat et prix de vente par marchandise.
- Ajouter une section `Commerce` au port avec achat et vente.
- Afficher la cargaison dans le HUD.
- Donner un premier role clair a la Goelette comme navire marchand.
- Correctif v0.10.1 : interdire l'equipement d'un navire trop petit pour la cargaison actuelle, sans vente ni suppression automatique.

## v0.11 - Ports avances

- Ajouter plus d'options de port.
- Differencier progressivement les services et prix selon les ports.
- Relier chaque categorie de port a une zone de danger.
- Ajouter une premiere liste de ports simules dans le menu du port.
- Rendre le menu du port responsive en 1280x720 avec contenu principal scrollable et listes compactes.
- Preparer plusieurs ports par zone via le catalogue, avec filtrage par zone, niveau et ports physiques.
- Ajouter quatre ports physiques : Quai, Port marchand, Grand port et Arsenal naval.
- Connecter chaque port physique a un `port_id` du `PortCatalog`.
- Limiter commerce, chantier naval, missions, flotte, reparations et ameliorations selon le port actif.
- Preparer des routes commerciales entre ports.

## v0.12 - Camera mobile

- Ajouter une camera joueur dediee.
- Ajouter le zoom a la molette.
- Ajouter un decalage manuel limite autour du joueur.
- Ajouter `C` pour recentrer la camera.
- Clamper la camera aux limites de carte.
- Desactiver les controles camera quand les menus sont ouverts.

## v0.13 - Tresors et exploration

- Differencier les types de tresors.
- Relier les reliques et fragments a des recompenses plus rares.
- Preparer des collections ou decouvertes majeures.

## v0.14 - Zones de danger avancees

- Rendre les zones de danger plus evolutives.
- Relier danger, reputation et types d'ennemis.
- Preparer des routes maritimes plus risquees.

## v0.15 - Creatures marines

- Ajouter les premieres menaces non humaines.
- Tester des comportements simples distincts des navires.
- Garder les combats lisibles avec les regles de navigation existantes.

## v0.16 - Controle de territoire

- Preparer des zones controlables ou contestables.
- Relier territoire, ports et reputation.
- Garder une version simple avant toute strategie avancee.

## v1.0 - Polish global

- Boucle complete : partir du port, naviguer, combattre, looter, reparer, ameliorer, recruter, commercer et accomplir des missions.
- Zone de jeu limitee mais coherente.
- Interface propre pour ressources, PV, missions, flotte, commerce et ordres.
- Build exportable pour test externe.
