import std.stdio;
import std.container : SList;
import std.datetime.date;
import std.algorithm;

import db;

/* Premier passage : parcours de tous les trajets possibles, n correspondances max.
   TODO: remplacer le parcours en profondeur par un parcours en largeur. */

SList!(string[]) premierPassage(Date date, MaxDB db, int n_corres, string origine, string destination) {
	writeln("Premier passage...");
	auto ret = SList!(string[])();
	int ntrouves = 0;

	void rec(string[] trajet, DateTime arrivee, int n) {
		if (n > n_corres + 1)
			return;

		if (destination is null || trajet[$ - 1] == destination) {
			ret.insertFront(trajet);
			ntrouves++;
			if (!(destination is null))
				return;
		}

		auto suivants = db.destinationsDepuis(trajet[$ - 1], arrivee);

		foreach (d, t; suivants) {
			/* On ne revient pas sur nos pas */
			if (trajet.canFind(d))
				continue;

			trajet ~= d;
			rec(trajet, t, n + 1);
			trajet.length--;
		}
	}

	rec([origine], DateTime(date.year, date.month, date.day, 0, 0), 0);

	writeln("Fin du premier passage, nombre de trajets trouvés : ", ntrouves);

	return ret;
}
