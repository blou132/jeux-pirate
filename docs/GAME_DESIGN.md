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
