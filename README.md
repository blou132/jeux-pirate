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
- Gains de réputation : ennemis coulés, missions terminées, coffres, reliques anciennes, recrutement allié et flotte complète.
- Les kills faits par la flotte donnent aussi la réputation au joueur.
- Le HUD affiche le rang de réputation, les points et le titre courant.
- Le menu du port ajoute `Statut pirate` avec titre, rang, points, prochain rang et progression.

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
- `E` : interagir avec le port ou explorer une île selon la zone
- `Échap` : fermer le menu
- `R` : réapparaître au port après destruction
- `F` : ordre flotte suivre
- `G` : ordre flotte attaquer
- `H` : ordre flotte protéger
- `J` : ordre flotte fuir

## Debug développement

Outil temporaire pour tester les améliorations sans farmer les ressources :

- `F1` : ajoute 100 or
- `F2` : ajoute 100 bois

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
- `QuestObjectiveSpawner` crée les objectifs temporaires de mission dans la scène jouable.
- `FleetManager` gère les alliés actifs, la limite de flotte, les ordres, la formation et la réparation de flotte.
- `AllyShip` et `AllyShipAI` gèrent le comportement individuel des bateaux alliés recrutés en session.
- `SpawnManager` gère les ennemis actifs, le respawn et la sélection des variantes.
- `World.tscn` est la scene de test jouable.
- Les assets visuels de v0.1 sont des primitives Godot creees dans les scenes ou par script.
