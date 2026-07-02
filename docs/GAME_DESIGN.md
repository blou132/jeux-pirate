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

## Boucle de jeu v0.4

1. Le joueur navigue jusqu'à une île.
2. Le HUD indique quand `E` permet d'explorer.
3. Un panneau simple affiche le nom de l'île.
4. Le joueur fouille l'île depuis le menu.
5. Le coffre donne son trésor une seule fois pendant la session.
6. Le HUD confirme or, bois, fragments de carte et reliques anciennes.

## Boucle de jeu v0.5

1. Le joueur revient au port.
2. Il ouvre la section `Missions`.
3. Il accepte une ou plusieurs missions simples.
4. Les missions de trésor créent leur propre objectif temporaire en mer.
5. La progression se fait par combat, objectif de quête ou retour au port.
6. Le HUD affiche les missions actives.
7. Une mission terminée demande de revenir au port pour récupérer sa récompense.

## Boucle de jeu v0.6

1. Le joueur collecte assez d'or et de bois.
2. Il revient au port et recrute un Sloop allié.
3. L'allié apparaît près du port et suit le joueur en mer.
4. Il reste à distance lisible du bateau joueur.
5. Lorsqu'un ennemi est proche, il manœuvre grossièrement pour tirer de côté.
6. Si l'allié est détruit, le joueur peut continuer et en recruter un autre.

## Boucle de jeu v0.7

1. Le joueur recrute jusqu'à trois Sloops alliés au port.
2. Chaque recrutement coûte plus cher que le précédent.
3. Les alliés suivent le joueur en formation simple.
4. Le joueur donne un ordre global : suivre, attaquer, protéger ou fuir.
5. Les alliés adaptent leur comportement de navigation et de tir à l'ordre actif.
6. Le port répare toute la flotte selon les PV manquants.
7. Un allié détruit est retiré de la flotte et peut être remplacé.

## Boucle de jeu v0.8

1. Le joueur gagne de la réputation en accomplissant les actions déjà jouables.
2. Les ennemis coulés, coffres, reliques, missions et recrutements font progresser son statut.
3. Le HUD affiche le rang de réputation et le titre pirate courant.
4. Les changements importants affichent un feedback court.
5. Le port permet de consulter le statut pirate et la progression vers le prochain rang.

## Boucle de jeu v0.9

1. Le joueur revient au port.
2. Il ouvre le `Chantier naval`.
3. Il compare Barque, Chaloupe, Sloop et Goelette.
4. Il achete un navire avec or, bois et parfois fragments.
5. Il equipe le navire possede de son choix.
6. Le bateau joueur applique les stats du navire actif.
7. Les ameliorations restent des bonus au-dessus du navire de base.

## Boucle de jeu v0.10

1. Le joueur gagne de l'or par combat, missions ou exploration.
2. Il revient au port et ouvre la section `Commerce`.
3. Il achete une marchandise si son or et sa cargaison le permettent.
4. La cargaison consomme l'espace de stockage du navire actif.
5. Il peut revendre les marchandises au port contre de l'or.
6. Les navires avec plus de stockage, surtout la Goelette, deviennent plus utiles pour le commerce.

## Boucle de jeu v0.12

1. Le joueur navigue avec une camera de poursuite qui reste derriere le bateau en mode verrouille.
2. Il ajuste le zoom a la molette selon le besoin : combat rapproche ou exploration plus large.
3. Il appuie sur `V` pour deverrouiller la camera libre.
4. Il deplace la souris pour observer autour du bateau sans maintenir de bouton.
5. Il appuie de nouveau sur `V` pour verrouiller la camera sur un suivi normal.
6. Il appuie sur `C` pour recentrer la camera sur le navire.
7. Il utilise `PageUp` ou `PageDown` pour lever ou baisser la camera sans changer le zoom.
8. Le bateau peut effectuer un 360 degres fluide sans snap a 0/360 ni roll parasite.
9. Les limites de carte empechent la camera de partir trop loin hors de la zone jouable.
10. Les menus de port et d'exploration gardent la priorite sur les entrees souris et clavier.

## Boucle de jeu v0.13

1. Le joueur repere un site d'exploration en mer.
2. Il s'approche et utilise `E` pour ouvrir le menu d'exploration.
3. Le menu affiche le type de site, la zone, le tresor, les fragments requis et les recompenses.
4. Si les prerequis sont suffisants, le joueur explore le site et recupere le tresor.
5. Les fragments ou reliques requis sont consommes seulement quand le tresor est bien obtenu.
6. Les recompenses ajoutent or, bois, fragments, reliques, marchandises et renom selon le tresor.
7. Le site est marque explore et ne peut pas etre farme pendant la session.
8. Le HUD detaille affiche les tresors decouverts et les sites explores.

## Boucle de jeu v0.14

1. Le joueur quitte les eaux sures et traverse des regions de danger mieux identifiees.
2. Le HUD compact et detaille affiche la zone courante separement du danger global.
3. Les spawns ennemis utilisent la zone pour choisir petits pirates, brigantins ou patrouilleurs lourds.
4. La densite ennemie augmente dans les zones plus dangereuses.
5. Les transitions de zone affichent le niveau et le bonus de recompense.
6. Les combats et sites d'exploration en zone dangereuse rapportent plus d'or, de bois et de renom.

## Boucle de jeu v0.15

1. Le joueur croise des creatures marines selon la zone de danger.
2. Les poissons rendent les eaux sures plus vivantes et fuient le navire.
3. Les requins, crocodiles marins, serpents de mer et krakens juveniles peuvent attaquer a courte portee.
4. Le joueur et sa flotte peuvent les combattre avec les boulets existants.
5. Les creatures vaincues donnent or, bois, renom, fragments possibles et ressources rares.
6. Les ressources rares restent des compteurs separes de la cargaison commerciale.
7. Les ports restent des zones sures : les creatures decrochent ou sont repoussees au respawn.

## Boucle de jeu v0.16

1. Le joueur navigue dans une zone deja definie par `DangerZoneCatalog`.
2. Le HUD affiche la faction dominante dans cette zone.
3. Les combats, creatures vaincues, explorations et ventes au port changent legerement l'influence locale.
4. Une faction peut devenir dominante si son influence depasse les autres.
5. Le controle modifie la densite des pirates, la presence des creatures et les effets visibles au port.
6. Le menu de port expose les effets territoriaux sans lancer encore de conquete ou diplomatie avancee.

## Boucle de jeu v0.16.1

1. Le joueur ouvre le port et consulte la section `Allegeance`.
2. Il peut rester neutre, rejoindre une faction ou redevenir neutre plus tard.
3. Le HUD compact affiche l'allegeance courante.
4. Le HUD detaille rappelle le bonus actif et le controle local.
5. Les actions deja jouables appliquent de petits bonus selon la faction choisie.
6. Les bonus influencent legerement le territoire sans creer encore de diplomatie avancee.

## Port et progression

Le port sert de premier point sûr et de première interface de progression. Il établit le rythme attendu : partir en mer, obtenir des ressources, revenir au port, réparer, améliorer le bateau, accepter des missions et recruter un premier soutien allié.

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

## Lisibilité combat v0.3.3

Le combat doit montrer clairement quand un ennemi attaque et donner une sortie propre après une défaite :

- Les attaques ennemies utilisent des boulets visibles qui partent du bateau ennemi vers le joueur.
- Le HUD affiche un message court quand le joueur prend des dégâts.
- À 0 PV, le bateau reste détruit mais le joueur peut appuyer sur `R` pour réapparaître près du port.
- Le respawn restaure les PV et le contrôle sans retirer les ressources du joueur.

## Règles navales v0.3.4

Les bateaux ennemis ne tirent plus dans toutes les directions. Ils doivent présenter un flanc au joueur avant de déclencher une bordée :

- Un tir ennemi est autorisé seulement si le joueur est dans l'arc latéral gauche ou droit.
- Si le joueur est devant ou derrière l'ennemi, l'IA manœuvre pour se réaligner.
- Le joueur détruit ne peut plus tirer tant qu'il n'a pas réapparu.
- Les limites de carte empêchent de quitter durablement la zone jouable.
- Le HUD signale l'approche ou le dépassement des limites.

## Bordées ennemies v0.3.5

La direction du joueur sert seulement à choisir le côté de tir. Le projectile ennemi part ensuite dans l'axe latéral du bateau, comme un canon de bordée :

- Bâbord : le boulet part vers la gauche locale du bateau.
- Tribord : le boulet part vers la droite locale du bateau.
- Le boulet apparaît sur le côté de la coque, pas au centre.
- À portée d'attaque, l'ennemi orbite et corrige sa distance pour placer le joueur dans un arc latéral.

## Positionnement de bordée v0.3.6

L'ennemi doit se comporter davantage comme un navire qui prépare une bordée :

- À portée, il cherche une orientation où son côté vise directement le joueur.
- Le seuil de tir est plus strict pour éviter les tirs de flanc mal alignés.
- Pendant l'alignement, il avance moins vite pour éviter de dépasser ou coller le joueur.
- Le tir est confirmé au dernier moment avant de créer le projectile.

## Points de visée v0.3.7

Les calculs de bordée ne doivent plus dépendre d'une origine invisible si elle ne correspond pas au centre perçu du bateau :

- Le joueur possède un `AimPoint` placé au centre visuel du navire.
- Les ennemis tirent depuis `LeftCannonPoint` ou `RightCannonPoint`.
- L'axe tribord est calculé depuis les points de canon quand ils existent.
- Des marqueurs debug temporaires permettent de vérifier les points dans Godot.

## Ligne de bordée v0.3.8

Une bordée ennemie doit être validée comme une vraie ligne de tir :

- La ligne part du point de canon latéral choisi.
- Elle suit l'axe bâbord ou tribord du bateau ennemi.
- Le tir est autorisé seulement si le `AimPoint` du joueur est devant la ligne et assez proche d'elle.
- Une ligne debug temporaire montre le rayon de bordée et l'écart au point de visée.

## Manœuvre ennemie v0.3.9

Les ennemis doivent tourner comme des bateaux lourds plutôt que pivoter directement vers leur objectif :

- La rotation utilise une vitesse angulaire avec accélération et décélération.
- Chaque type a son poids de manœuvre : petit pirate nerveux, brigantin moyen, patrouilleur lourd lent.
- En bordée, la vitesse avance moins fort quand le bateau tourne déjà beaucoup.
- Le choix bâbord/tribord reste verrouillé pendant un court délai pour limiter les oscillations.

## Îles et trésors v0.4

Les îles posent une première base d'exploration sans quitter le bateau :

- Île du Naufrage : petite île proche avec coffre facile.
- Île des Rochers : île moyenne avec coffre donnant aussi un fragment de carte.
- Îlot Maudit : île plus dangereuse avec coffre rare et relique ancienne.
- Les coffres sont uniques pendant la session : une île déjà fouillée ne redonne pas sa récompense.
- Les fragments de carte et reliques anciennes préparent une progression d'exploration future sans lancer les missions complexes.

## Missions simples v0.5

Les missions donnent un premier cadre aux actions déjà jouables sans créer de système narratif complexe :

- Chasse pirate : détruire 3 ennemis.
- Premier fragment : fouiller un coffre de quête dédié.
- Relique ancienne : fouiller un coffre de quête dédié.
- Retour au port : ouvrir une cargaison de quête puis revenir au port.
- Jusqu'à trois missions peuvent être actives à la fois.
- Les objectifs de quête sont générés à l'acceptation pour ne pas dépendre des coffres permanents déjà ouverts.
- Les objectifs temporaires sont nettoyés après récupération de la récompense.
- Les récompenses se récupèrent au port et ne peuvent pas être réclamées plusieurs fois.

## Premier allié v0.6

Le Sloop allié pose une première base de coopération sans lancer encore une flotte complète :

- Recrutement au port contre 150 or et 60 bois.
- Un seul allié actif à la fois pour garder le prototype lisible.
- Suivi automatique du joueur avec distance arrière-latérale.
- Soutien de combat simple contre les ennemis proches.
- Boulets alliés dédiés, visibles, qui ciblent les ennemis et pas le joueur.
- Destruction non bloquante : le HUD prévient le joueur et le port permet de recruter de nouveau.

## Correctifs allié v0.6.1

La v0.6.1 rend le premier allié testable dans une vraie boucle de combat :

- Les coûts de port doivent être lisibles avant achat ou réparation.
- La réparation du joueur et de l'allié dépend des PV manquants avec la règle 1 bois pour 5 PV.
- Les ennemis peuvent choisir le joueur ou le Sloop allié selon la cible hostile la plus proche.
- Les tirs ennemis utilisent l'AimPoint de leur cible, joueur ou allié.
- Le Sloop allié utilise une bordée comparable aux ennemis : AimPoint cible, points de canon, ligne de tir et projectile droit.
- Les dégâts alliés doivent être visibles et les kills alliés appartiennent au joueur pour loot, danger et missions.
- Un allié détruit ne bloque pas la session : le HUD revient à aucun allié et le port permet un nouveau recrutement.

## Flotte basique v0.7

La v0.7 transforme le premier allié en petite escadre sans lancer encore les systèmes lourds d'abordage, de territoire ou de hiérarchie navale :

- La flotte est limitée à 3 alliés actifs.
- Les coûts de recrutement progressent pour rendre la croissance lisible.
- Les slots de formation gardent les alliés derrière le joueur : arrière gauche, arrière droite, puis arrière centre.
- Les ordres restent globaux pour éviter une microgestion trop précoce.
- `Suivre` privilégie la formation et ne tire que si un ennemi est très proche.
- `Attaquer` cherche les ennemis proches et utilise la bordée alliée existante.
- `Protéger` reste autour du joueur et de la flotte, puis cible les ennemis proches des navires amis.
- `Fuir` coupe les tirs alliés et dirige les bateaux vers une zone sûre proche du port.
- La réparation de flotte garde la règle simple de port : 1 bois pour 5 PV réparés.
- Les kills de n'importe quel allié restent crédités au joueur pour le loot, le danger et les missions.

## Hierarchie des navires v0.9

La v0.9 introduit une progression de coque sans lancer encore le commerce complet ni la hierarchie des ports :

- Barque : navire de depart, 100 PV, vitesse 7.0, tres accessible et agile.
- Chaloupe : navire rapide pour missions legeres, 125 PV, vitesse 8.0, cout 400 or et 120 bois.
- Sloop : navire polyvalent, 175 PV, vitesse 7.5, cout 900 or et 250 bois.
- Goelette : navire plus robuste pour commerce et escorte, 220 PV, vitesse 8.5, cout 1600 or, 400 bois et 1 fragment.
- Les navires plus puissants coutent plus cher, stockent davantage et gagnent une base de degats plus haute, mais tournent moins vite.
- La flotte alliee reste volontairement sur des Sloops allies dans cette version.

La hierarchie affiche aussi les paliers futurs : Radeau, Brick, Fregate, Galion, Vaisseau de ligne et Navire legendaire.

## Ameliorations variables par navire v0.9

Les petits navires restent peu chers et vite lisibles, tandis que les navires plus puissants ouvrent plus de progression :

- Barque : coque, voiles et canons jusqu'au niveau 3.
- Chaloupe : coque, voiles et canons jusqu'au niveau 4.
- Sloop : coque, voiles et canons jusqu'au niveau 5.
- Goelette : coque, voiles et canons jusqu'au niveau 6.

Les niveaux sont stockes par navire. Une Barque amelioree ne transfere pas ses niveaux au Sloop, et revenir a la Barque retrouve sa progression propre. Cette regle evite les pertes definitives quand un navire plus petit a un plafond plus bas.

Les couts montent avec le niveau d'amelioration : niveau 1 a 20 or / 10 bois, niveau 2 a 40 / 20, niveau 3 a 80 / 40, niveau 4 a 140 / 70, niveau 5 a 220 / 110 et niveau 6 a 320 / 160.

## Ciblage ennemi v0.9.1

Les changements de navire ne doivent pas casser le combat existant. Le bateau joueur reste le meme `PlayerBoat` dans le groupe `player`, avec des stats remplacees selon le navire equipe.

- Les ennemis peuvent cibler le joueur si `can_be_targeted()` confirme qu'il est vivant.
- Les allies du groupe `ally_ships` restent des cibles hostiles valides pour les ennemis tant qu'ils ne sont pas detruits.
- La zone sure qui bloque la detection et l'attaque ennemies est limitee au port.
- Les iles et zones d'archipel ne rendent pas le joueur intouchable ; elles restent des lieux d'exploration et de danger normal.
- Le leash sert seulement a abandonner une poursuite trop lointaine. Il ne declenche pas le cooldown d'expulsion portuaire.
- Les boulets ennemis continuent de toucher uniquement le joueur et les allies, pas les autres ennemis.

## Equilibrage poursuite v0.9.2

Les navires joueur de v0.9 peuvent devenir nettement plus rapides avec les voiles ameliorees. L'IA ennemie doit donc rester capable d'engager sans transformer toute la carte en zone d'attaque.

- Detection par variante : Petit pirate 50, Brigantin pirate 60, Patrouilleur lourd 70.
- Leash par variante : Petit pirate 100, Brigantin pirate 120, Patrouilleur lourd 140.
- Portee d'engagement : Petit pirate 32, Brigantin pirate 38, Patrouilleur lourd 45.
- Bonus de vitesse seulement en poursuite/combat : x1.10, x1.15 et x1.20.
- La zone sure portuaire reste prioritaire sur la poursuite et coupe l'engagement quand le joueur revient au port.
- La vitesse des boulets ennemis est augmentee a 18.0 pour couvrir les nouvelles portees tout en restant esquivable par manoeuvre.

## Cargaison et commerce v0.10

La v0.10 donne un premier role concret au stockage sans lancer encore les ports avances ni les routes commerciales dynamiques.

- La cargaison est suivie par `GameState` en session.
- La capacite vient de la stat `storage` du navire actif : Barque 100, Chaloupe 130, Sloop 180, Goelette 260.
- Chaque marchandise a un poids unitaire : Rhum 10, Epices 5, Tissu 8, Minerai 15, Perles 3.
- Le port affiche une section `Commerce` avec quantite possedee, poids, prix d'achat et prix de vente.
- Acheter consomme de l'or et de l'espace libre ; vendre retire la marchandise et donne de l'or.
- Prix achat/vente : Rhum 60/45, Epices 90/65, Tissu 45/30, Minerai 80/55, Perles 160/120.
- Si la cargaison est pleine ou l'or insuffisant, le joueur recoit un feedback simple.
- La Goelette est volontairement la meilleure option commerciale de v0.10 grace a son stockage de 260.
- Correctif v0.10.1 : le joueur ne peut pas equiper un navire dont la capacite cargo est inferieure a la cargaison actuelle. Le jeu n'efface ni ne vend rien automatiquement ; le joueur doit d'abord vendre ou vider des marchandises.

## Ports et zones de danger v0.11

La v0.11 relie les ports a la progression de danger sans creer encore une carte immense. Le monde contient une premiere serie de ports physiques interactifs, et le menu garde une liste de ports simules pour tester rapidement les categories futures.

Hierarchie des zones de danger :

1. Eaux sures
2. Zone surveillee
3. Zone contestee
4. Zone hostile
5. Zone mortelle
6. Territoire legendaire
7. Enfers des mers

Hierarchie des ports :

1. Quai
2. Petit port
3. Port marchand
4. Grand port
5. Arsenal naval
6. Capitale maritime
7. Port legendaire
8. Sanctuaire pirate

Le port de depart reste dans les Eaux sures. Les ports faibles offrent peu de services mais sont faciles d'acces ; les ports avances offrent plus de commerce, de reparations et de chantier naval, mais ils sont associes a des zones plus dangereuses. Chaque port declare son nom, niveau, categorie, zone de danger, services, niveaux de commerce/reparation/chantier naval, navires accessibles, marchandises et missions.

Ports physiques v0.11 :

- `starter_quay` : Quai du Pavillon, Eaux sures, proche du spawn, reparations et commerce limite.
- `merchant_port` : Port marchand des Alizes, Zone surveillee, plus de marchandises et chantier intermediaire.
- `great_port` : Grand port de Briselame, Zone contestee, chantier plus complet et acces a la Goelette.
- `naval_arsenal` : Arsenal naval de Ferhoule, Zone hostile, meilleur atelier de combat de cette premiere carte.

Les ports physiques utilisent `Port.gd` avec un `port_id` exporte. `World.gd` transmet le port actif au menu, et `PortMenu.gd` lit `PortCatalog` pour afficher la zone, les services, les marchandises, les missions et les navires accessibles.

Le menu de port doit rester utilisable en 1280x720. L'en-tete et le bouton de fermeture restent fixes, tandis que les services, listes et details defilent dans un `ScrollContainer`. Les listes de ports, navires, marchandises et missions ont une hauteur limitee pour eviter que les boutons critiques, notamment Acheter/Equiper au chantier naval, sortent de l'ecran.

Le catalogue contient maintenant plusieurs ports simules par zone de danger en plus des ports physiques. Les fonctions `get_ports_for_danger_zone`, `get_ports_by_level` et `get_world_port_ids` preparent les futures routes commerciales et le placement de ports sans changer la carte actuelle.

## Camera mobile v0.12

La camera doit ameliorer le confort d'exploration sans devenir un outil de triche ni masquer l'UI :

- Le script `PlayerCamera.gd` suit le bateau avec un lissage de position et de rotation.
- En mode verrouille, la position cible est calculee derriere le bateau avec sa direction horizontale, une distance et une hauteur reglables.
- La camera regarde un point au-dessus du navire avec un lissage de rotation pour eviter snap et roll parasite.
- La molette ajuste un zoom borne pour passer d'une lecture proche du bateau a une vue plus large des environs.
- `PageUp` et `PageDown` ajustent la hauteur camera entre 5 et 18 unites, independamment du zoom.
- Quand la camera est basse, elle regarde davantage vers l'horizon ; quand elle est haute, elle donne une vue plus plongeante.
- `V` verrouille ou deverrouille la camera libre.
- Quand la camera libre est deverrouillee, la souris cree un decalage manuel limite autour du joueur depuis son point d'ancrage au moment du deverrouillage.
- Quand la camera est reverrouillee, le decalage revient progressivement a zero et la camera reprend sa position derriere le bateau.
- Le clic droit reste reserve au combat et au canon tribord.
- `C` annule le decalage manuel et recentre progressivement la camera sur le navire sans changer l'etat verrouille/deverrouille.
- La position camera est clampée avec les limites de `WorldBounds`.
- Si le port ou le menu d'exploration est ouvert, la camera ignore ses controles pour laisser les boutons et le scroll fonctionner.

## Tresors et exploration v0.13

La v0.13 donne une premiere utilite claire aux fragments de carte sans creer encore une grande carte ni des donjons :

- `TreasureCatalog` definit sept categories : Bourse, Coffre, Chambre forte, Cave au tresor, Tresor royal, Tresor imperial et Tresor mythique.
- Les tresors ont un niveau, une rarete, une zone de danger recommandee, des prerequis et des recompenses.
- Repartition par danger : Eaux sures = Bourse/Coffre, Zone surveillee = Coffre/Chambre forte, Zone contestee = Chambre forte/Cave au tresor, Zone hostile = Cave au tresor/Tresor royal, Zone mortelle = Tresor royal/Tresor imperial, Territoire legendaire = Tresor imperial/Tresor mythique, Enfers des mers = Tresor mythique.
- Les fragments requis montent avec la rarete : 0, 0, 1, 2, 3, 4, puis 5 fragments et 1 relique pour le Tresor mythique.
- Les sites v0.13 sont des primitives simples : epave, grotte cotiere, ruines anciennes, camp abandonne et ile au tresor.
- Chaque site est unique pendant la session et stocke son etat dans `GameState`.
- Les recompenses restent simples : or, bois, fragments, reliques, marchandises et renom.
- Le renom des tresors passe par `ReputationSystem.record_treasure_discovered` pour mettre a jour rangs, titres et score de titre.
- Si la cargaison est insuffisante pour une recompense en marchandises, le site refuse l'exploration avant de consommer des fragments.
- Les coffres d'iles v0.4 et les coffres de quete v0.5 continuent d'utiliser leur flux existant.

## Zones de danger avancees v0.14

`DangerZoneCatalog` devient la source commune pour les regions de danger. Chaque zone declare son nom, niveau, description, types d'ennemis, densite, ports, tresors et multiplicateur de recompense.

Zones officielles :

1. Eaux sures : densite x0.35, recompenses x1.00, surtout Petits pirates.
2. Zone surveillee : densite x0.65, recompenses x1.15, Petits pirates et Brigantins.
3. Zone contestee : densite x1.00, recompenses x1.30, melange de menaces.
4. Zone hostile : densite x1.30, recompenses x1.50, Brigantins et Patrouilleurs lourds.
5. Zone mortelle : densite x1.65, recompenses x1.80, menaces lourdes plus frequentes.
6. Territoire legendaire : densite x2.00, recompenses x2.20, prepare pour une future carte avancee.
7. Enfers des mers : densite x2.40, recompenses x2.80, reserve aux versions futures.

La v0.14 ne cree pas une carte immense. Elle ajoute une premiere Zone mortelle autour de l'ile au tresor et convertit les regions existantes vers les identifiants officiels. Les zones legendaires restent surtout des donnees de preparation pour les ports, tresors et routes futures.

Le danger global issu du nombre d'ennemis detruits reste conserve pour la progression historique. La zone courante est separee dans le HUD pour eviter de confondre niveau de region et escalade globale.

## Creatures marines v0.15

La v0.15 ajoute une premiere couche de vie et de menace non pirate sans lancer encore de boss complexe :

- Poisson : passif, fuit le joueur, surtout Eaux sures.
- Requin : rapide, agressif a courte portee, rare en Eaux sures puis plus frequent.
- Crocodile marin : lent et robuste, apparait a partir de la Zone surveillee.
- Serpent de mer : rapide et agressif, reserve aux zones contestee, hostile et mortelle.
- Kraken juvenile : rare, lent, dangereux, surtout Zone hostile et Zone mortelle.

Les creatures futures restent dans le catalogue mais ne spawnent pas en v0.15 : Leviathan, Kraken ancestral et Dieu des oceans.

Repartition de spawn :

- Eaux sures : poissons, requins rares.
- Zone surveillee : poissons, requins, crocodiles marins rares.
- Zone contestee : requins, crocodiles marins, serpents de mer rares.
- Zone hostile : crocodiles marins, serpents de mer, krakens juveniles rares.
- Zone mortelle : serpents de mer, krakens juveniles.

Les ressources rares v0.15 sont Perle noire, Dents de requin, Corail sacre, Ecaille de serpent et Oeil de kraken. Elles sont stockees dans `GameState` comme compteurs separes pour eviter de casser la cargaison et le commerce.

Correctif v0.15.1 :

- Les ennemis pirates et les creatures marines ont des spawners, compteurs et limites separes.
- Chaque spawner relance regulierement le remplissage de ses emplacements, meme si les premieres tentatives echouent temporairement.
- La zone de danger courante utilise un fallback sur les Eaux sures si l'etat est vide ou invalide.
- Les ports restent des zones sures, mais les points de spawn peuvent utiliser une distance de secours pour eviter que les zones sures bloquent toute la carte.
- Des diagnostics desactives par defaut affichent les actifs, la zone, le type choisi et la raison d'un echec de spawn.

Correctif v0.15.2 :

- La densite pirate passe a 0.4, 0.8, 1.2, 1.6 et 2.0 des Eaux sures a la Zone mortelle.
- La densite des creatures devient separee : 0.7, 1.0, 1.3, 1.6 et 2.0 selon la zone.
- Le monde contient plus de points de spawn par zone pour eviter les rencontres trop rares ou concentrees.
- Les creatures agressives touchent a distance de contact reelle autour des coques au lieu d'attendre un chevauchement impossible.
- Degats : Requin 8, Crocodile marin 12, Serpent de mer 18, Kraken juvenile 28.
- Les ports gardent une exclusion stricte, puis une distance de secours si toute la carte serait rejetee.

## Réputation et titres v0.8

La réputation donne une progression sociale simple sans ajouter encore de contrôle de territoire ou de hiérarchie de ports :

- Les points de réputation montent avec les actions de base : combat, missions, exploration, reliques et flotte.
- Les rangs de réputation représentent la notoriété du joueur dans le monde pirate.
- Les titres pirates sont séparés des rangs pour rester extensibles avec d'autres critères plus tard.
- Le score de titre dépend surtout de la réputation, avec de petits bonus pour missions, ennemis, trésors et taille de flotte atteinte.
- Le HUD reste volontairement sobre : rang, points et titre.
- Le port affiche un statut plus complet avec progression vers le prochain rang.
- Les gains sont branchés sur des événements déjà uniques pour éviter les doubles récompenses.
- La réputation de recrutement est liée aux nouveaux emplacements de flotte : un remplacement après destruction ne redonne pas le bonus.
- Le bonus de flotte complète est accordé seulement la première fois que la flotte atteint 3/3.

## Interface pirate

La premiere refonte UI doit rendre le prototype plus lisible sans changer les systemes jouables :

- Les ressources et PV importants restent visibles en permanence dans une barre superieure.
- Le panneau gauche sert au pilotage : vitesse, coque, ameliorations, danger, flotte et missions.
- Le panneau droit sert au statut social : reputation, progression de rang, titre et progression de titre.
- Le menu du port reste central et fonctionnel, mais se lit comme un tableau de capitaine avec services, missions, ameliorations, flotte et statut pirate.
- Les onglets bas annoncent les futures sections de navigation sans encore lancer de nouvelle mecanique.
- Les elements HUD non interactifs ne doivent pas intercepter la souris pour preserver le combat naval.

### Finition v0.8.2

- En mer, le HUD compact est le mode par defaut pour garder le champ de vision libre.
- Le HUD detaille reste disponible avec `TAB` et pendant l'utilisation du menu du port.
- La barre de ressources reste en haut avec or, bois, fragments, reliques et PV.
- Les informations compactes reviennent dans un panneau vertical gauche : vitesse, danger, flotte, ordre, missions, rang et titre.
- Les notifications de zone sont centrees sous la barre de ressources et ne font pas partie du panneau compact.
- Les gains de reputation de recrutement restent non farmables : chaque slot de flotte ne donne son bonus qu'une fois, et le bonus flotte complete ne se declenche qu'au premier 3/3.
- Les controles gameplay ne doivent pas etre consommes par le HUD, sauf `TAB` pour la bascule d'affichage.

### Correctifs v0.8.3

- Les recompenses de mission sont le moment officiel du gain de renommee de mission.
- Une defaite du bateau principal fait perdre de la renommee, avec clamp a 0 et recalcul du rang/titre.
- Les tirs du joueur et de la flotte ignorent les navires amis ; les ennemis restent capables de toucher joueur et allies.
- Le respawn au port cree une courte fenetre d'invulnerabilite et libere la zone sure autour du port.
- Les aides debug de visee et de lignes de bordee sont desactivees par defaut pour le jeu normal.

### Correctifs v0.8.4

- La renommee ne depasse plus 3500 points et le score de titre ne depasse plus 7000 points.
- Les gains debug `F3` passent par le meme pipeline que les gains normaux : ajout, recalcul, signaux et rafraichissement UI.
- Le statut pirate du port se synchronise avec les changements de renommee pendant que le panneau est ouvert.
- Les affichages de maximum privilegient `Maximum atteint`, `MAX` ou une valeur plafonnee.
- Le HUD compact utilise des libelles courts definis par rang/titre au lieu d'une coupure automatique.
- Les notifications de zone occupent leur propre ligne sous les ressources, separee du HUD compact.
- Les ennemis utilisent un rayon de detection court par type et une distance de poursuite separee.
- Les cibles detruites, au port ou proches d'une ile sont ignorees par l'acquisition ennemie.
- La zone sure du port force les ennemis a decrocher, a s'eloigner et a attendre avant de reengager.
- Une aide debug desactivee par defaut peut afficher le cercle de detection ennemi.

### Correctifs v0.8.5

- Les ennemis doivent redevenir menacants sans attaquer depuis toute la carte : detection 40 pour le Petit pirate, 48 pour le Brigantin pirate et 55 pour le Patrouilleur lourd.
- Le leash de poursuite laisse le combat respirer : 65 pour le Petit pirate, 75 pour le Brigantin pirate et 85 pour le Patrouilleur lourd.
- La zone sure du port garde un rayon de protection de 45, repousse a 60 et autorise un reengagement apres 3 secondes quand le joueur repart.
- La densite de rencontre vise un rythme plus present : 5 ennemis actifs maximum, respawn toutes les 5 secondes.
- Les rangs de renom sont : Inconnu, Recherché, Craint, Redouté, Célèbre, Légendaire, Fléau des mers, Roi des pirates.
- Les titres pirates sont : Loup de mer, Capitaine, Seigneur des vagues, Maître des flottes, Conquérant des mers, Fléau des mers, Souverain des mers, Roi des océans, Empereur des océans, Légende éternelle.
- L'interface doit nommer clairement `Renom` ou `Réputation` pour la premiere liste, et `Titre pirate` pour la deuxieme.

## Controle de territoire v0.16

La v0.16 ajoute une couche de monde dynamique legere. Elle ne cree pas encore de guerre totale, de diplomatie avancee ou de conquete de port, mais elle donne aux zones un etat politique lisible.

Factions officielles :

- Pirates : pillage, chaos, combat naval ; augmente les spawns pirates et rend les zones moins sures.
- Marine royale : ordre et securite ; reduit les pirates, securise les ports et rend les reparations plus favorables.
- Ligue marchande : routes maritimes et richesse ; rend le commerce plus avantageux et reduit legerement le danger direct.
- Contrebandiers : marche noir et objets rares ; valorise les ressources rares et cree une influence mixte.
- Cultes abyssaux : monstres marins et zones maudites ; augmente les creatures marines et les menaces dangereuses.

Chaque zone possede une influence par faction totalisant environ 100 %, une faction dominante, une stabilite et un niveau de conflit. Les influences initiales suivent la progression de danger : les Eaux sures sont surtout Marine/Ligue marchande, la Zone contestee est partagee avec les pirates, et les zones mortelles/abyssales favorisent les Cultes abyssaux.

Actions joueur :

- Detruire un pirate reduit legerement les Pirates et renforce Marine/Ligue marchande dans la zone courante.
- Vaincre une creature dangereuse reduit les Cultes abyssaux et rassure les routes maritimes.
- Explorer un site ou recuperer un tresor affaiblit un peu Pirates ou Cultes abyssaux selon le niveau de zone.
- Faire du commerce au port renforce la Ligue marchande de la zone du port.

Effets de gameplay :

- Les spawns pirates sont multiplies par l'influence territoriale, avec un minimum de rencontres conserve.
- Les creatures marines augmentent sous influence abyssale, surtout les creatures dangereuses.
- Les ports affichent les effets actifs : commerce, reparations, securite ou marche noir.
- Le HUD compact affiche le controle dominant, tandis que le HUD detaille affiche influence, stabilite, conflit et effets.
- Un feedback apparait seulement quand une nouvelle faction devient dominante dans la zone courante.

## Allegeance joueur v0.16.1

L'allegeance du joueur est volontairement reversible. Elle ne doit pas bloquer la progression et ne transforme pas encore les factions en ennemis ou allies permanents.

Choix disponibles :

- Neutre : aucun bonus, aucune penalite.
- Pirates : +10 % or sur les combats contre navires ennemis.
- Marine royale : +10 % renom contre les pirates et reduction supplementaire de leur influence.
- Ligue marchande : +5 % sur les ventes commerciales et influence marchande accrue par commerce.
- Contrebandiers : +10 % de chance d'obtenir les ressources rares de creatures, plus un leger gain d'influence par exploration/ressources rares.
- Cultes abyssaux : +10 % or sur creatures marines dangereuses, sans rendre les creatures alliees.

Le choix se fait au port dans une section `Allegeance`. La faction actuelle, la description et le bonus sont affiches avant validation. Un bouton permet de redevenir neutre.

Le HUD compact affiche l'allegeance en mer. Le HUD detaille affiche l'allegeance, le bonus actif et la faction dominante locale pour aider le joueur a comprendre s'il navigue dans un territoire favorable ou hostile.

## Voies de faction v0.16.2

La v0.16.2 transforme l'allegeance en choix de voie pour la partie courante. Le joueur commence toujours neutre, sans bonus ni penalite, puis peut choisir une seule vraie faction depuis le port.

Regle de partie :

- Neutre est l'etat de depart et ne verrouille pas la partie.
- Choisir Pirates, Marine royale, Ligue marchande, Contrebandiers ou Cultes abyssaux verrouille immediatement cette voie apres confirmation.
- Une voie verrouillee ne peut plus etre changee pendant la partie.
- Le joueur ne peut pas redevenir neutre apres validation.
- Pour tester une autre voie, il faudra recommencer une nouvelle partie quand le systeme de nouvelle partie/sauvegarde sera ajoute.

Cette contrainte donne plus de poids au roleplay et aux bonus de gameplay : Pirates oriente vers les combats navals, Marine royale vers la chasse aux pirates, Ligue marchande vers le commerce, Contrebandiers vers les ressources rares, et Cultes abyssaux vers les creatures marines dangereuses.

Le port doit afficher clairement l'avertissement avant validation : ce choix est definitif pour cette partie. Le HUD compact indique l'allegeance et le statut verrouille, tandis que le HUD detaille rappelle le statut, le bonus actif et le controle local.

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

## Hors scope v0.4

- Déplacement à pied sur les îles.
- Donjons, PNJ ou énigmes.
- Missions narratives.
- Carte du monde complète.
- Sauvegarde disque persistante.

## Hors scope v0.5

- Missions longues ou scénarisées.
- PNJ de quête.
- Flotte alliée.
- Abordage.
- Sauvegarde persistante des missions.

## Hors scope v0.6

- Flotte complète avec plusieurs alliés.
- Ordres de flotte détaillés.
- Réparations ou améliorations dédiées aux alliés.
- Abordage.
- Sauvegarde persistante de l'allié recruté.

## Hors scope v0.7

- Abordage.
- Contrôle de territoire.
- Monstres marins.
- Hiérarchie détaillée des navires.
- Sauvegarde persistante de la flotte.

## Hors scope v0.8

- Contrôle de territoire.
- Monstres marins.
- Hiérarchie complète des ports.
- Réputation persistante sur disque.
- Factions pirates concurrentes.
