import std.datetime.date;
import std.typecons;
import std.container : SList;
import std.algorithm;
import std.stdio;

import db;

/* Les trajets emploient une structure d'arbre, adaptée pour l'affichage. */

struct Routes {
	Routes[Trajet] suivants;

	void iter(void delegate(Trajet[]) act)
	{
		void rec(Trajet[] route, Routes routes)
		{
			foreach (trajet, suite; routes.suivants) {
				route ~= trajet;
				if (suite.suivants.length == 0)
					act(route);
				else
					rec(route, suite);
				route.length--;
			}
		}

		rec([], this);
	}

	void ajouterRoute(Trajet[] route)
	{
		if (route.length == 0)
			return;

		if (!(route[0] in suivants))
			suivants[route[0]] = Routes();

		suivants[route[0]].ajouterRoute(route[1 .. $]);
	}

	bool meilleurQue(Trajet[] route)
	{
		bool rec(Routes routes)
		{
			foreach (trajet, suite; routes.suivants) {
				bool depart_trouve = false;
				bool arrivee_trouvee = false;
				foreach (t2; route) {
					if (trajet.oiata == t2.oiata && trajet.depart >= t2.depart)
						depart_trouve = true;
					if (trajet.diata == t2.diata && trajet.arrivee <= t2.arrivee)
						arrivee_trouvee = true;
				}
				if (!depart_trouve || !arrivee_trouvee)
					continue;

				if (suite.suivants.length == 0 || rec(suite))
					return true;
			}

			return false;
		}

		return rec(this);
	}

	void afficherAvecEspaces(int espaces, ref string[] dict)
	{
		bool first = true;

		auto suivants_tab = new Tuple!(Trajet, Routes)[suivants.length];

		{
			int i = 0;
			foreach (trajet, suite; suivants) {
				suivants_tab[i] = tuple(trajet, suite);
				i++;
			}
		}

		suivants_tab.sort!((a, b) => a[0].depart < b[0].depart);

		foreach (e; suivants_tab) {
			auto trajet = e[0];
			auto suite = e[1];

			if (!first) {
				foreach (i; 0 .. espaces)
					write(" ");
			}

			if (!dict.canFind(trajet.oiata))
				dict ~= trajet.oiata;
			if (!dict.canFind(trajet.diata))
				dict ~= trajet.diata;

			if (!trajet.places_dispo)
				write("\x1b[90m");

			if (trajet.TER)
				write(trajet.oiata, " (--:--) >----> ",
						trajet.diata, " (--:--)");
			else
				write(trajet.oiata, " (", trajet.depart.timeOfDay.toISOExtString[0 .. 5], ") >",
						trajet.train_no, "> ",
						trajet.diata, " (", trajet.arrivee.timeOfDay.toISOExtString[0 .. 5], ")");

			if (!trajet.places_dispo)
				write("\x1b[0m");

			if (suite.suivants.length == 0) {
				write("\n");
			} else {
				write(" / ");
				suite.afficherAvecEspaces(espaces + 33, dict);
			}

			first = false;
		}
	}
}

struct RoutesPrio {
	Routes[] routes;

	void ajouterRoute(Trajet[] route)
	{
		while (routes.length < route.length)
			routes ~= Routes();
		routes[route.length - 1].ajouterRoute(route);
	}

	void nettoyer()
	{
		/* Cette fonction efface les routes qui se contentent de rajouter des gares dans une autre route */

		foreach (i; 1 .. routes.length) {
			Routes nouvelles_routes = Routes();

			void act(Trajet[] route) {
				bool ajouter = true;
				foreach (r; routes[0 .. i]) {
					if (r.meilleurQue(route)) {
						ajouter = false;
						break;
					}
				}

				if (ajouter)
					nouvelles_routes.ajouterRoute(route);
			}
			routes[i].iter(&act);

			routes[i] = nouvelles_routes;
		}
	}

	void afficher(MaxDB db)
	{
		string[] dict;

		foreach (i, r; routes) {
			if (i == 0)
				writeln("\nDIRECT\n");
			else if (i == 1)
				writeln("1 CORRESPONDANCE\n");
			else
				writeln(i, " CORRESPONDANCES\n");

			r.afficherAvecEspaces(0, dict);
			writeln();
		}

		dict.sort();

		writeln();
		foreach (e; dict)
			writeln(e, " : ", db.traduireIATA(e));
	}
}

RoutesPrio secondPassageTrajet(Date date, ref RoutesPrio ret, MaxDB db, string[] trajet1)
{
	void rec(Trajet[] route, string[] etapes_restantes, DateTime heure, string point)
	{
		if (etapes_restantes.length == 0) {
			ret.ajouterRoute(route);
			return;
		}

		auto ponts = db.trajetsDepuisVers(point, etapes_restantes[0], heure);
		foreach (p; ponts[]) {
			route ~= p;

			rec(route, etapes_restantes[1 .. $], p.arrivee, p.destination);

			route.length--;
		}
	}

	rec([], trajet1[1 .. $], DateTime(date.year, date.month, date.day, 0, 0), trajet1[0]);

	return ret;
}

RoutesPrio secondPassage(Date date, MaxDB db, SList!(string[]) trajets1)
{
	writeln("Second passage...");

	RoutesPrio ret;

	foreach (t; trajets1[])
		secondPassageTrajet(date, ret, db, t);

	writeln("Fin du second passage.");

	return ret;
}
