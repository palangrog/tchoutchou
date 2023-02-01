import std.stdio;
import std.getopt;
import std.datetime.date;
import std.uni;

import db;
import premier_passage;
import second_passage;

void main(string[] args)
{
	string origine = null;
	string destination = null;
	int    n_corres = 2;
	bool   trajets_complets = false;
	Date   date;

	{
		string datestr = null;
		GetoptResult help_info = getopt(args,
				"origine|o", &origine,
				"destination|d", &destination,
				"date|t", &datestr,
				"corres|n", &n_corres,
				"complets|c", &trajets_complets);

		if (help_info.helpWanted || origine is null || datestr is null) {
			defaultGetoptPrinter("Tchoutchou calcule des routes TGV max.", help_info.options);
			return;
		}

		date = Date.fromISOString(datestr);
	}

	origine = origine.toUpper;
	if (!(destination is null))
		destination = destination.toUpper;

	MaxDB db = new MaxDB(date, trajets_complets);

	if (!db.origineExiste(origine)) {
		writeln(origine, " n'est pas une origine valide.");
		return;
	}

	auto trajets1 = premierPassage(date, db, n_corres, origine, destination);

	auto routes = secondPassage(date, db, trajets1);

	routes.nettoyer();
	routes.afficher(db);
}
