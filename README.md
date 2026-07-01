# Pavillon Libre

Prototype Godot 4.x original pour un jeu d'aventure pirate.

Le projet n'utilise aucun asset externe et ne reprend aucune marque, aucun nom, aucun modèle et aucun contenu protégé. La v0.1 pose une base jouable propre : bateau joueur, mer de test, combat basique, ennemi et loot simple.

La v0.1 a été testée manuellement par l'utilisateur dans Godot : scène World lancée, bateau contrôlable, HUD visible, ennemi présent, combat fonctionnel et loot ajouté après destruction.

La v0.2 ajoute un port de test, une interaction au port, un menu, la réparation du bateau, trois améliorations et un HUD de progression.

La v0.3 ajoute le spawn d'ennemis, le respawn après destruction, trois variantes d'ennemis, un niveau de danger global, des zones de danger simples et un feedback de victoire plus lisible.

La v0.3.2 améliore la jouabilité de la v0.3 : attaque ennemie effective, feedback de défaite du joueur, silhouettes ennemies plus distinctes, noms au-dessus des ennemis et notifications d'entrée de zone.

La v0.3.3 rend les attaques ennemies visibles avec des boulets dédiés, ajoute un feedback HUD quand le joueur est touché et permet de réapparaître au port avec `R` après destruction.

La v0.3.4 améliore les règles de combat naval : tirs ennemis limités aux bordées, tirs joueur bloqués après destruction, limites de carte et feedback de sortie de zone jouable.

La v0.3.5 corrige les bordées ennemies : les boulets partent strictement vers bâbord ou tribord, depuis le côté de la coque, avec une manœuvre ennemie plus lisible pour présenter le flanc.

La v0.3.6 améliore le positionnement de bordée : les ennemis alignent davantage leur flanc avant de tirer, manœuvrent plus lentement à portée et ne tirent que lorsque le côté vise vraiment le joueur.

La v0.3.7 fiabilise les points de visée et de tir : le joueur possède un vrai `AimPoint`, les ennemis ont des points de canon latéraux explicites, et l'alignement de bordée utilise les axes réels du bateau.

La v0.3.8 ajoute une validation de bordée par distance à la ligne de tir : l'ennemi ne tire que si la ligne issue du canon latéral passe près du `AimPoint` du joueur.

La v0.3.9 améliore la manœuvre ennemie : rotation progressive avec inertie, vitesses de rotation par type, ralentissement de bordée plus naturel et verrouillage temporaire du côté de tir.

La v0.4 ajoute trois îles explorables, une interaction d'exploration avec `E`, des coffres uniques, des trésors, des fragments de carte et des reliques anciennes.

La v0.5 ajoute un système de missions simples au port, une progression visible dans le HUD et des récompenses de mission récupérables au port.

La v0.5.1 rend les missions plus robustes : plusieurs missions peuvent être actives en même temps, les objectifs de trésor sont générés à l'acceptation et les coffres de quête ne dépendent plus des coffres permanents des îles.

La v0.6 ajoute un premier bateau allié : le Sloop allié peut être recruté au port, suit le joueur, apporte un soutien de combat simple et peut être recruté de nouveau après destruction.

La v0.6.1 rend l'allié plus lisible et utile : coûts de port affichés, réparation dynamique, réparation alliée, ciblage par les ennemis, vraie visée de bordée, dégâts confirmés et kills alliés crédités au joueur.

La v0.7 ajoute une flotte basique : jusqu'à 3 Sloops alliés, recrutement progressif, formation de suivi, ordres simples, réparation de flotte et HUD de flotte.

La v0.8 ajoute une progression sociale : réputation pirate, rangs de réputation, titres pirates, gains liés aux actions jouables, affichage HUD et statut pirate au port.

La refonte UI pirate ajoute une premiere direction visuelle dark fantasy : barre de ressources en haut, panneau navire/flotte a gauche, panneau reputation/titre a droite, onglets bas de navigation et menu du port plus lisible.

La v0.12 ajoute une camera joueur mobile pour rendre la navigation, l'exploration et la recherche de ports plus confortables.

La v0.12.3 transforme le mode verrouille en vraie camera de poursuite derriere le bateau, avec hauteur reglable et inclinaison adaptee a la vue horizon/vue plongeante.

La v0.13 ajoute une premiere couche de tresors et d'exploration : catalogue de tresors, sites explorables, fragments de carte utiles, recompenses de tresors et progression affichee dans le HUD detaille.

La v0.14 avance les zones de danger : catalogue central, regions de monde identifiees, HUD de zone, spawns ennemis et recompenses modules par le risque.

La v0.15 ajoute une premiere base de creatures marines : poissons, requins, crocodiles marins, serpents de mer et krakens juveniles, avec spawns par zone, combat simple et ressources rares.

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

## Correctifs v0.3.3

- Les ennemis tirent maintenant des boulets visibles vers le joueur.
- Le HUD affiche `Touché ! -X PV` quand le joueur prend des dégâts.
- Après destruction, le HUD affiche l'aide de reprise et `R` fait réapparaître le joueur près du port.

## Correctifs v0.3.4

- Les ennemis tirent seulement si le joueur est dans un arc latéral de bordée.
- Si le joueur est devant ou derrière, l'ennemi manœuvre pour présenter son flanc.
- Le joueur ne peut plus tirer après destruction.
- `WorldBounds` limite la zone jouable, pousse le joueur vers l'intérieur et le ramène près du port en cas de sortie forte.
- Le HUD affiche `Limite de la carte` ou `Retour dans la zone navigable` selon la situation.

## Correctifs v0.3.5

- Les boulets ennemis n'utilisent plus la position exacte du joueur comme direction de tir.
- Le côté bâbord ou tribord est choisi selon la position relative du joueur.
- Les projectiles ennemis apparaissent depuis le côté de la coque avec un offset vertical.
- Les ennemis manœuvrent à portée pour mieux présenter leur flanc avant de tirer.

## Correctifs v0.3.6

- L'alignement de tir ennemi est plus strict avant une bordée.
- Les ennemis manœuvrent plus lentement à portée pour présenter leur flanc.
- Le tir est revalidé juste avant le lancement du boulet.
- Le debug console de bordée est limité par cooldown pour rester lisible.

## Correctifs v0.3.7

- Le bateau joueur expose un `AimPoint` utilisé par l'IA ennemie.
- Les bateaux ennemis ont `LeftCannonPoint` et `RightCannonPoint` pour le départ des boulets.
- L'alignement de bordée utilise l'axe réel entre les points de canon.
- Des marqueurs debug temporaires rendent les points de visée et de tir visibles dans Godot.

## Correctifs v0.3.8

- Le tir ennemi est validé par la distance entre le `AimPoint` et la ligne de bordée.
- Si la ligne passe trop loin du joueur ou part dans le mauvais sens, l'ennemi ne tire pas.
- Les lignes debug de bordée montrent le rayon latéral et l'écart jusqu'au `AimPoint`.
- La manœuvre ennemie corrige légèrement sa trajectoire quand la ligne de tir passe à côté.

## Correctifs v0.3.9

- Les ennemis utilisent une vitesse angulaire avec accélération et décélération au lieu d'une rotation directe.
- Petit pirate, Brigantin pirate et Patrouilleur lourd ont des vitesses et accélérations de rotation distinctes.
- La manœuvre de bordée ralentit légèrement pendant les virages forts pour donner plus de poids aux bateaux.
- Le côté bâbord/tribord est verrouillé brièvement pour éviter les changements de bordée trop rapides.

## Etat v0.4

- Trois îles explorables : Île du Naufrage, Île des Rochers, Îlot Maudit.
- Interaction avec `E` près du rivage pour ouvrir le panneau d'exploration.
- Action `Fouiller l'île` dans un menu simple, sans personnage à pied pour l'instant.
- Un coffre unique par île, ouvert une seule fois pendant la session.
- Récompenses : or, bois, fragments de carte et reliques anciennes.
- HUD étendu avec `Fragments` et `Reliques`.

## Etat v0.5

- Système de missions en session, sans sauvegarde disque.
- Section `Missions` dans le menu du port.
- Jusqu'à trois missions actives à la fois.
- Missions de départ : Chasse pirate, Premier fragment, Relique ancienne, Retour au port.
- Progression courte affichée dans le HUD pour les missions actives.
- Récompenses de missions récupérables au port, sans double paiement.
- Objectifs temporaires créés à l'acceptation pour les missions de fragment, relique et retour au port.
- Coffres de quête séparés des coffres permanents des îles pour éviter les missions impossibles après exploration.
- Nettoyage des objectifs temporaires après récupération de la récompense.

## Etat v0.6

- Premier bateau allié : `Sloop allié`.
- Recrutement au port avec le bouton `Recruter un allié`.
- Coût de recrutement : 150 or et 60 bois.
- Limite volontaire à 1 allié actif pour cette version.
- Suivi du joueur avec distance arrière-latérale, ralentissement si trop proche et rattrapage si trop loin.
- Soutien de combat simple contre les ennemis proches avec boulets alliés visibles.
- HUD allié : `Allié : aucun` ou `Allié : Sloop — X/80 PV`.
- Si l'allié est détruit, le HUD affiche `Allié détruit` et un nouveau recrutement est possible au port.

## Correctifs v0.6.1

- Le bouton de recrutement affiche `Recruter un allié : 150 or, 60 bois`.
- La réparation du joueur affiche les PV manquants et le coût dynamique en bois.
- Le port permet de réparer le Sloop allié avec la même règle : 1 bois pour 5 PV.
- L'allié est réellement destructible : PV clampés à 0, HUD remis à `Allié : aucun`, nouveau recrutement possible.
- Les ennemis ciblent maintenant la cible hostile la plus proche : joueur ou allié.
- L'allié utilise `AimPoint`, points de canon latéraux et validation de ligne de bordée avant de tirer.
- Les boulets alliés appliquent bien leurs dégâts aux ennemis et affichent un feedback de touche.
- Si l'allié coule un ennemi, le loot, le danger et la quête `Chasse pirate` progressent comme pour un kill joueur.

## Etat v0.7

- Flotte alliée limitée à 3 Sloops pour garder le prototype lisible.
- Recrutement progressif au port : 150 or/60 bois, puis 250 or/100 bois, puis 400 or/160 bois.
- Formation de suivi : allié 1 arrière gauche, allié 2 arrière droite, allié 3 arrière centre.
- Ordres globaux : suivre, attaquer, protéger et fuir.
- Le HUD affiche `Flotte : x/3`, l'ordre courant et les PV de chaque allié.
- Le port propose `Réparer la flotte` avec coût total selon les PV manquants.
- Les alliés détruits sont retirés de la flotte et libèrent une place de recrutement.

## Etat v0.8

- Système global de réputation pirate en session.
- Rangs de réputation : Inconnu, Recherché, Craint, Redouté, Célèbre, Légendaire, Fléau des mers, Roi des pirates.
- Titres pirates séparés : de `Loup de mer` jusqu'à `Légende éternelle`.
- Gains de réputation : ennemis coulés, missions terminées, coffres, reliques anciennes, nouveaux emplacements de flotte remplis et flotte complète.
- Le recrutement allié donne `+20 réputation` seulement la première fois que chaque emplacement de flotte est rempli.
- Le bonus `Flotte complète` donne `+100 réputation` seulement la première fois que la flotte atteint 3/3.
- Les kills faits par la flotte donnent aussi la réputation au joueur.
- Le HUD affiche le rang de réputation, les points et le titre courant.
- Le menu du port ajoute `Statut pirate` avec titre, rang, points, prochain rang et progression.

## Refonte UI pirate

- `PirateTheme.tres` centralise les couleurs sombres, bordures dorees, boutons, listes et barres de progression.
- La barre superieure regroupe or, bois, fragments, reliques et PV du joueur.
- Le panneau gauche se concentre sur navire, vitesse, coque, ameliorations, danger, ennemis detruits, flotte et missions.
- Le panneau droit affiche reputation, progression de rang, titre pirate et progression de titre.
- Le menu du port garde ses actions existantes mais gagne un panneau central plus large, des sections et une meilleure lisibilite.
- Les onglets bas `Port`, `Missions`, `Flotte`, `Carte` et `Renom` preparent la navigation future sans ajouter de gameplay.
- Les panneaux HUD decoratifs ignorent la souris pour ne pas bloquer les clics de canon.

## Finition UI v0.8.2

- Le HUD de navigation est compact par defaut pour liberer l'ecran en mer et en combat.
- La barre superieure garde les ressources principales et les PV : or, bois, fragments, reliques et coque.
- Le HUD compact revient en panneau vertical a gauche avec vitesse, danger, flotte, ordre, missions, rang et titre.
- `TAB` bascule entre HUD compact et HUD detaille.
- Le menu du port force le HUD detaille pendant son ouverture, puis rend le controle au mode compact/TAB.
- Le HUD detaille separe mieux les sections Navire, Ameliorations, Mer et combat, Flotte et Missions.
- Les notifications de zone restent separees du HUD compact, centrees sous la barre de ressources.
- L'anti-farm de reputation alliee reste base sur le premier remplissage de chaque emplacement de flotte et sur le premier 3/3.

## Correctifs v0.8.3

- `F3` ajoute temporairement 50 renommee pour les tests de progression.
- Les recompenses de mission donnent maintenant leur renommee a la recuperation au port, une seule fois.
- La destruction du bateau joueur retire 25 renommee sans passer sous 0.
- Les boulets joueur/flotte ne blessent plus les navires allies.
- Le respawn au port donne 3 secondes d'invulnerabilite et repousse les ennemis trop proches de la zone sure.
- Le HUD compact abrege le renom et les aides debug de visee sont masquees par defaut.

## Correctifs v0.8.4

- `F3` utilise le meme flux de renommee que les gains normaux et rafraichit HUD compact, HUD detaille et statut pirate.
- La renommee est plafonnee a 3500 points.
- Le score de titre pirate est plafonne a 7000 points.
- Au maximum, les panneaux affichent `Maximum atteint`, `MAX` ou `3500/3500` au lieu de valeurs depassant les seuils.
- Le HUD compact utilise deux lignes courtes pour le rang et le titre, par exemple `Rang: Roi pirate` puis `Titre: Legende`.
- Les notifications de zone sont deplacees sous la barre de ressources pour ne plus chevaucher le HUD compact.
- Les ennemis ont un rayon de detection par variante : 28, 32 ou 36 unites.
- Les ennemis abandonnent la poursuite si la cible sort du leash : 40, 45 ou 50 unites.
- La zone portuaire reste sure : les ennemis n'engagent pas les cibles au port, s'eloignent a 70 unites et attendent avant de reengager.
- Les iles servent aussi de petites zones de decrochage pour eviter une redetection immediate pendant l'exploration.
- `debug_show_enemy_detection` peut afficher le rayon de detection ennemi pendant les tests, desactive par defaut.

## Correctifs v0.8.5

- Les ennemis retrouvent une detection plus agressive : Petit pirate 40, Brigantin pirate 48, Patrouilleur lourd 55.
- Le leash de poursuite est augmente : Petit pirate 65, Brigantin pirate 75, Patrouilleur lourd 85.
- La zone sure portuaire protege le port sans vider la mer : rayon de protection 45, expulsion 60, cooldown de reengagement 3 secondes.
- La densite de rencontre remonte legerement avec 5 ennemis actifs maximum et 5 secondes de delai de respawn.
- Rangs de renom officiels : Inconnu, Recherché, Craint, Redouté, Célèbre, Légendaire, Fléau des mers, Roi des pirates.
- Titres pirates officiels : Loup de mer, Capitaine, Seigneur des vagues, Maître des flottes, Conquérant des mers, Fléau des mers, Souverain des mers, Roi des océans, Empereur des océans, Légende éternelle.
- L'UI distingue le `Renom` du `Titre pirate`, avec des libelles courts propres dans le HUD compact.

## Etat v0.9

- `ShipCatalog` centralise les navires joueur, leurs stats, leurs couts et la hierarchie future.
- Navires jouables : Barque, Chaloupe, Sloop et Goelette.
- Le joueur commence avec la Barque possedee et equipee.
- Le port ajoute un `Chantier naval` pour consulter les stats, acheter et equiper les navires.
- Les navires non possedes affichent leur cout ou `ressources insuffisantes`.
- La hierarchie complete est visible : Radeau, Barque, Chaloupe, Sloop, Goelette, Brick, Fregate, Galion, Vaisseau de ligne, Navire legendaire.
- Le bateau joueur applique les stats du navire equipe : PV, vitesse, maniabilite, stockage prepare et degats de canon de base.
- Le HUD compact et detaille affiche le navire actif.

## Ameliorations par navire v0.9

- Chaque navire garde ses propres niveaux de coque, voiles et canons.
- Changer de navire ne supprime pas les niveaux deja achetes sur un autre navire.
- Plafonds v0.9 : Barque 3/3/3, Chaloupe 4/4/4, Sloop 5/5/5, Goelette 6/6/6.
- Le menu d'ameliorations affiche le navire actif et ses plafonds.
- Le HUD affiche les niveaux avec le maximum actif, par exemple `Coque: niv. 3/5`.
- Couts par niveau : 20/10, 40/20, 80/40, 140/70, 220/110, 320/160 en or/bois.

## Correctifs ciblage ennemi v0.9.1

- Le `PlayerBoat` reste explicitement ciblable apres les changements de navire avec `is_alive()` et `can_be_targeted()`.
- Les ennemis cherchent une cible hostile vivante : joueur dans le groupe `player`, puis allies dans `ally_ships`.
- La zone sure qui bloque l'engagement ennemi s'applique uniquement au port, pas aux iles ou a l'archipel.
- Le leash de poursuite abandonne la cible hors portee sans declencher le cooldown d'expulsion portuaire.
- Les rayons attendus restent : detection 40/48/55 et leash 65/75/85 selon Petit pirate, Brigantin pirate et Patrouilleur lourd.
- `debug_enemy_ai` peut etre active dans `EnemyShipAI` pour imprimer cible, distance, detection, leash et statut de zone portuaire.

## Equilibrage poursuite v0.9.2

- Les ennemis detectent mieux les navires rapides sans engager depuis toute la carte : 50, 60 et 70 unites.
- Le leash de poursuite passe a 100, 120 et 140 unites pour eviter les decrochages immediats apres detection.
- Les portees d'engagement passent a 32, 38 et 45 unites selon la variante ennemie.
- En poursuite ou alignement de bordee, les ennemis appliquent un petit bonus de vitesse : x1.10, x1.15 ou x1.20.
- La zone sure du port garde la priorite : elle coupe toujours l'engagement et force l'ennemi a s'eloigner.
- Les boulets ennemis passent a 18.0 de vitesse pour rester coherents avec les nouvelles portees.

## Etat v0.10

- Premiere boucle de commerce simple au port avec une section `Commerce`.
- La cargaison utilise la capacite `stockage` du navire actif.
- Capacites : Barque 100, Chaloupe 130, Sloop 180, Goelette 260.
- Marchandises : Rhum, Epices, Tissu, Minerai et Perles.
- Poids : Rhum 10, Epices 5, Tissu 8, Minerai 15, Perles 3.
- Prix achat/vente : Rhum 60/45, Epices 90/65, Tissu 45/30, Minerai 80/55, Perles 160/120.
- Acheter consomme de l'or et de la place en cargaison ; vendre rend de l'or.
- La Goelette devient le meilleur navire de commerce grace a sa grande capacite.
- Le HUD affiche la cargaison utilisee et la capacite du navire actif.
- Correctif v0.10.1 : le chantier naval bloque l'equipement d'un navire dont la capacite est inferieure a la cargaison actuelle. Il faut vendre ou vider assez de marchandises avant de repasser sur un navire plus petit.

## Etat v0.11

- `PortCatalog` prepare une hierarchie de ports liee aux zones de danger.
- Zones de danger : Eaux sures, Zone surveillee, Zone contestee, Zone hostile, Zone mortelle, Territoire legendaire, Enfers des mers.
- Ports : Quai, Petit port, Port marchand, Grand port, Arsenal naval, Capitale maritime, Port legendaire, Sanctuaire pirate.
- Le port de depart reste en Eaux sures.
- Le menu du port affiche une liste de ports simules v0.11 pour tester les services sans creer une grande carte.
- Le menu du port est responsive en 1280x720 : en-tete et bouton de sortie restent fixes, le contenu principal defile dans un `ScrollContainer`, et les longues listes sont limitees en hauteur.
- Le chantier naval garde les actions Acheter/Equiper accessibles avant le texte long de hierarchie.
- Chaque port definit sa categorie, sa zone de danger, ses services, ses niveaux de commerce/reparation/chantier naval, ses navires, ses marchandises et ses missions.
- Le catalogue prepare plusieurs ports par zone et expose des helpers pour filtrer par zone de danger, niveau ou ports deja places sur la carte.
- Les services du menu sont limites par le port actif : commerce, chantier naval, missions, flotte, reparations et ameliorations.
- Quatre ports physiques sont places dans `World.tscn` : `starter_quay`, `merchant_port`, `great_port` et `naval_arsenal`.
- Repartition physique : Quai en Eaux sures pres du spawn, Port marchand en Zone surveillee, Grand port en Zone contestee, Arsenal naval en Zone hostile.
- Chaque port physique transmet son `port_id` au menu et affiche sa categorie plus sa zone dans le prompt d'interaction.

## Etat v0.12

- Camera joueur dediee dans `scripts/camera/PlayerCamera.gd`.
- Suivi fluide du bateau joueur, sans camera rigide directement collee au parent.
- En mode verrouille, la camera reste derriere le bateau et suit sa direction sans roll parasite pendant les 360 degres.
- Zoom molette borne entre une vue proche et une vue large.
- `V` verrouille ou deverrouille la camera libre.
- Souris pour observer autour du bateau avec offset limite quand la camera libre est deverrouillee.
- `C` recentre la camera derriere le bateau sans changer le zoom ni l'etat lock/unlock.
- `PageUp` / `PageDown` ajustent la hauteur camera entre vue plus haute et vue plus proche de l'horizon.
- L'inclinaison s'adapte a la hauteur : camera basse plus orientee horizon, camera haute plus plongeante.
- La camera respecte les limites de carte exposees par `WorldBounds`.
- Les controles camera sont ignores quand le port ou le menu d'exploration est ouvert, pour laisser le scroll et les clics UI fonctionner.

## Etat v0.13

- `TreasureCatalog` centralise la hierarchie des tresors : Bourse, Coffre, Chambre forte, Cave au tresor, Tresor royal, Tresor imperial et Tresor mythique.
- Cinq sites d'exploration sont ajoutes a la carte : epave, grotte cotiere, ruines anciennes, camp abandonne et ile au tresor.
- Les sites utilisent `E` puis le menu d'exploration existant avec une action `Explorer le site`.
- Les tresors sont lies aux zones de danger : tresors faibles en Eaux sures, tresors plus rares dans les zones plus dangereuses.
- Les fragments de carte servent a debloquer les tresors avances : 1 fragment pour Chambre forte, 2 pour Cave au tresor, 3 pour Tresor royal, 4 pour Tresor imperial, 5 plus 1 relique pour Tresor mythique.
- Si les fragments ou reliques manquent, le menu affiche un message clair et ne consomme rien.
- Les recompenses peuvent donner or, bois, fragments, reliques, marchandises et renom.
- Un site explore ne redonne jamais sa recompense pendant la session.
- Le HUD detaille affiche maintenant le nombre de tresors decouverts et de sites explores.

## Etat v0.14

- `DangerZoneCatalog` centralise les sept zones : Eaux sures, Zone surveillee, Zone contestee, Zone hostile, Zone mortelle, Territoire legendaire et Enfers des mers.
- Le monde jouable expose des regions de danger avec identifiant officiel, dont une premiere Zone mortelle pres de l'ile au tresor.
- Le HUD affiche la zone courante separement du danger global historique.
- Les notifications de transition indiquent le niveau de zone et le bonus de recompense quand il existe.
- Les points de spawn utilisent les zones officielles pour choisir les variantes ennemies adaptees.
- La densite ennemie et le delai de respawn augmentent avec le danger de la zone courante.
- Les recompenses de combat et d'exploration gagnent un multiplicateur de zone sur or, bois et renom.

## Etat v0.15

- `MarineCreatureCatalog` centralise la hierarchie marine : Poissons, Requins, Crocodiles marins, Kraken juvenile, Serpent de mer, Leviathan, Kraken ancestral et Dieu des oceans.
- Creatures jouables en v0.15 : Poisson passif, Requin, Crocodile marin, Serpent de mer et Kraken juvenile.
- Creatures reservees plus tard : Leviathan, Kraken ancestral et Dieu des oceans.
- `MarineCreatureSpawner` utilise des points de spawn dedies et les zones de danger pour choisir les creatures.
- Repartition : Eaux sures = poissons/requins rares, Zone surveillee = poissons/requins/crocodiles rares, Zone contestee = requins/crocodiles/serpents rares, Zone hostile = crocodiles/serpents/krakens rares, Zone mortelle = serpents/krakens.
- Les creatures agressives detectent joueur ou allies, poursuivent a courte portee, attaquent au contact et decrochent pres des ports.
- Les boulets joueur et allies peuvent toucher les creatures ; les boulets pirates restent reserves au joueur et a la flotte.
- Ressources rares suivies separement de la cargaison : Perle noire, Dents de requin, Corail sacre, Ecaille de serpent et Oeil de kraken.
- Le HUD detaille affiche creatures vaincues et ressources marines possedees.
- Une aide debug desactivee par defaut peut afficher l'etat IA des creatures et les spawns marins.

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
- Molette souris : zoom camera
- `V` : verrouiller / deverrouiller camera libre
- Souris : observer autour du bateau quand la camera libre est deverrouillee
- `C` : recentrer la camera sur le bateau
- `PageUp` / `PageDown` : lever / baisser la camera
- `E` : interagir avec le port ou explorer une île selon la zone
- `Échap` : fermer le menu
- `R` : réapparaître au port après destruction
- `F` : ordre flotte suivre
- `G` : ordre flotte attaquer
- `H` : ordre flotte protéger
- `J` : ordre flotte fuir

- `TAB` : basculer HUD compact / HUD detaille

## Debug développement

Outil temporaire pour tester les améliorations sans farmer les ressources :

- `F1` : ajoute 100 or
- `F2` : ajoute 100 bois
- `F3` : ajoute jusqu'a 50 renommee, sans depasser le plafond

Ces raccourcis sont activés via `DebugTools` et doivent rester identifiés comme aide de développement.

Les marqueurs `AimPoint`, `LeftCannonPoint` et `RightCannonPoint` peuvent être affichés pendant les tests avec `debug_show_aim_points` sur les bateaux. Cette aide est temporaire pour vérifier l'alignement des bordées.

Les lignes de bordée ennemies peuvent être affichées avec `debug_show_broadside_lines` dans `EnemyShipAI`. Elles servent à vérifier si la ligne latérale passe près du `AimPoint`.

## Structure

- `scenes/` : scenes Godot reutilisables
- `scripts/` : scripts GDScript organises par domaine
- `docs/` : design, feuille de route et notes de production

## Notes techniques

- `GameState` est configure en autoload pour suivre les ressources joueur.
- `UpgradeSystem` est configure en autoload pour suivre les niveaux d'amélioration.
- `QuestSystem` est configure en autoload pour suivre les missions actives et les récompenses.
- `ReputationSystem` est configure en autoload pour suivre réputation, rangs, titres pirates et feedback de progression.
- `DangerZoneCatalog` centralise les zones de danger, leurs niveaux, types d'ennemis, densites, ports, tresors et multiplicateurs de recompense.
- `MarineCreatureCatalog` centralise les creatures marines, leurs zones, comportements, stats et recompenses.
- `MarineCreatureSpawner` gere les creatures actives, les points de spawn marins et la densite par zone.
- `TreasureCatalog` centralise les types de tresors, prerequis, zones recommandees et recompenses.
- `ExplorationSite` et `ExplorationSiteSpawner` ajoutent des sites explorables uniques sur la carte.
- `QuestObjectiveSpawner` crée les objectifs temporaires de mission dans la scène jouable.
- `ShipCatalog` centralise les donnees des navires joueur et leur hierarchie.
- `FleetManager` gère les alliés actifs, la limite de flotte, les ordres, la formation et la réparation de flotte.
- `AllyShip` et `AllyShipAI` gèrent le comportement individuel des bateaux alliés recrutés en session.
- `SpawnManager` gère les ennemis actifs, le respawn et la sélection des variantes.
- `World.tscn` est la scene de test jouable.
- Les assets visuels de v0.1 sont des primitives Godot creees dans les scenes ou par script.
