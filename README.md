# Tchoutchou

Tchoutchou est un outil de recherche d'itinéraires TGV Max. Il utilise le jeu de données de la SNCF : https://ressources.data.sncf.com/explore/dataset/tgvmax/

## Utilisation

```
$ tchoutchou -h
Tchoutchou calcule des routes TGV max.
-o     --origine
-d --destination
-t        --date
-n      --corres
-c    --complets
-h        --help This help information.
```

## Exemple

```
$ tchoutchou -o lyon -d bordeaux -t 20230205
Lecture des données...
Base de données prête, nombre d'entrées : 3835
Premier passage...
Fin du premier passage, nombre de trajets trouvés : 56
Second passage...
Fin du second passage.

DIRECT


1 CORRESPONDANCE

LPE (06:16) >5351> XSH (09:43) / XSH (10:10) >5202> BOJ (12:02)
                                 XSH (11:11) >8437> BOJ (13:02)
                                 XSH (15:21) >8485> BOJ (17:37)
                                 XSH (22:49) >8461> BOJ (00:42)
LPE (06:16) >5351> DJU (08:34) / DJU (09:09) >5202> BOJ (12:02)
LPD (06:30) >5351> DJU (08:34) / DJU (09:09) >5202> BOJ (12:02)
LPD (06:30) >5351> XSH (09:43) / XSH (10:10) >5202> BOJ (12:02)
                                 XSH (11:11) >8437> BOJ (13:02)
                                 XSH (15:21) >8485> BOJ (17:37)
                                 XSH (22:49) >8461> BOJ (00:42)
LPD (06:40) >6821> XSY (09:00) / XSY (09:23) >4756> BOJ (13:32)
LPD (06:40) >6821> MPL (08:37) / MPL (09:07) >4756> BOJ (13:32)
LPD (06:40) >6821> XYT (11:02) / XYT (11:24) >4756> BOJ (13:32)
                                 XYT (12:32) >8512> BOJ (14:40)
                                 XYT (19:24) >4764> BOJ (21:32)
                                 XYT (20:03) >8522> BOJ (22:13)
                                 XYT (21:24) >4766> BOJ (23:32)
LPD (06:40) >6821> XNA (09:44) / XNA (10:04) >4756> BOJ (13:32)
LPD (06:40) >6821> CCF (10:17) / CCF (10:35) >4756> BOJ (13:32)
LPD (06:40) >6821> FNI (08:04) / FNI (08:38) >4756> BOJ (13:32)

2 CORRESPONDANCES

LPE (06:16) >5351> XSH (09:43) / XSH (15:21) >8485> XLR (17:15) / XLR (--:--) >----> BOJ (--:--)
                                 XSH (20:23) >12295> PIS (20:55) / PIS (21:54) >8495> BOJ (23:43)
                                 XSH (20:23) >8393> PIS (20:55) / PIS (21:54) >8495> BOJ (23:43)
LPE (06:16) >5351> DJU (08:34) / DJU (20:46) >8514> PMO (20:58) / PMO (21:45) >8461> BOJ (00:42)
LPD (06:30) >5351> XSH (09:43) / XSH (15:21) >8485> XLR (17:15) / XLR (--:--) >----> BOJ (--:--)
                                 XSH (20:23) >12295> PIS (20:55) / PIS (21:54) >8495> BOJ (23:43)
                                 XSH (20:23) >8393> PIS (20:55) / PIS (21:54) >8495> BOJ (23:43)
LPD (06:30) >5351> DJU (08:34) / DJU (20:46) >8514> PMO (20:58) / PMO (21:45) >8461> BOJ (00:42)


BOJ : BORDEAUX
CCF : CARCASSONNE
DJU : MASSY
FNI : NIMES
LPD : LYON
LPE : LYON
MPL : MONTPELLIER SAINT-ROCH
PIS : POITIERS
PMO : PARIS
XLR : LIBOURNE
XNA : NARBONNE
XSH : ST PIERRE DES CORPS
XSY : SETE
XYT : TOULOUSE MATABIAU
```
