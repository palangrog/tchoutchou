import std.net.curl;
import std.stdio;
import std.file;
import std.csv;
import std.algorithm;
import std.datetime;
import std.format;
import std.container : SList;
import std.uni;

struct Trajet {
	string oiata;
	string diata;
	string destination;
	bool TER = false;
	DateTime depart;
	DateTime arrivee;
	string train_no;
	bool places_dispo;
}

class MaxDB {
private:
	SList!Trajet[string] trajets;
	string[string] iata_dict;

	static string traduireGare(string gare)
	{
		switch (gare) {
		case "PARIS (intramuros)":
			return "PARIS";

		case "BORDEAUX ST JEAN":
			return "BORDEAUX";

		case "LYON (intramuros)":
			return "LYON";

		case "BESANCON - F COMTE TGV":
			return "BESANCON TGV";

		case "MASSY TGV":
		case "MASSY PALAISEAU":
			return "MASSY";

		default:
			return gare;
		}
	}

	static string remplacerIATA(string iata)
	{
		switch (iata) {
		case "MPU":
			return "DJU";

		default:
			return iata;
		}
	}

	void ajouterTrajetsTER() {
		void ajouter(string[] gares_iata, string[] gares_complet)
		{
			foreach (i1, g1; gares_iata) {
				foreach (i2, g2; gares_iata) {
					if (g1 == g2)
						continue;

					iata_dict[g1] = gares_complet[i1];
					iata_dict[g2] = gares_complet[i2];

					Trajet t = {
						oiata: g1,
						diata: g2,
						destination: gares_complet[i2],
						TER: true,
						places_dispo: true
					};

					if (!(gares_complet[i1] in trajets))
						trajets[gares_complet[i1]] = SList!Trajet();
					trajets[gares_complet[i1]].insertFront(t);
				}
			}
		}

		ajouter(["PMO", "DJU", "MLW", "MLV"],
				["PARIS", "MASSY", "AEROPORT CDG2 TGV ROISSY", "MARNE LA VALLEE CHESSY"]);
		ajouter(["LPD", "JDQ"], ["LYON", "LYON ST EXUPERY"]);
		ajouter(["TJB", "ABG"], ["BESANCON TGV", "BESANCON VIOTTE"]);
		ajouter(["EAH", "RHE"], ["CHAMPAGNE-ARDENNE", "REIMS"]);
		ajouter(["PIS", "TGO", "XCX"], ["POITIERS", "FUTUROSCOPE", "CHATELLERAULT"]);
		ajouter(["BOJ", "XLR"], ["BORDEAUX", "LIBOURNE"]);
		ajouter(["RIO", "CFE"], ["RIOM CHATEL GUYON", "CLERMONT FERRAND"]);
		ajouter(["MPL", "SUF"], ["MONTPELLIER SAINT-ROCH", "MONTPELLIER SUD DE FRANCE"]);
		ajouter(["AVG", "AES"], ["AVIGNON TGV", "AVIGNON CENTRE"]);
		ajouter(["VAF", "VLA"], ["VALENCE VILLE", "VALENCE TGV RHONE-ALPES SUD"]);
		ajouter(["AFW", "XSH"], ["TOURS", "ST PIERRE DES CORPS"]);
	}

public:
	this(Date date, bool trajets_complets)
	{
		if (!exists("/tmp/tgvmax.csv")) {
			writeln("Téléchargement des données...");
			download("https://ressources.data.sncf.com/explore/dataset/tgvmax/download/?format=csv&timezone=Europe/Paris&lang=fr&use_labels_for_header=true&csv_separator=%3B", "/tmp/tgvmax.csv");
			writeln("Données téléchargées.");
		}

		File file = File("/tmp/tgvmax.csv", "r");

		writeln("Lecture des données...");
		int n = 0;
		foreach (record; csvReader!(string[string])(file.byLine.joiner("\n"), null, ';')) {
			if (Date.fromISOExtString(record["DATE"]) != date)
				continue;


			if (!trajets_complets && record["Disponibilité de places MAX JEUNE et MAX SENIOR"] != "OUI")
				continue;

			DateTime depart;
			DateTime arrivee;

			{
				int heure;
				int minute;
				record["Heure_depart"].formattedRead!"%s:%s"(heure, minute);
				TimeOfDay depart_tod = TimeOfDay(heure, minute);
				record["Heure_arrivee"].formattedRead!"%s:%s"(heure, minute);
				TimeOfDay arrivee_tod = TimeOfDay(heure, minute);

				depart = DateTime(date, depart_tod);

				if (arrivee_tod > depart_tod)
					arrivee = DateTime(date, arrivee_tod);
				else
					arrivee = DateTime(date + 1.days, arrivee_tod);
			}

			Trajet nouveau_trajet = {
				oiata: remplacerIATA(record["Origine IATA"][2..5]),
				diata: remplacerIATA(record["Destination IATA"][2..5]),
				destination: traduireGare(record["Destination"]).toUpper,
				depart: depart,
				arrivee: arrivee,
				train_no: record["TRAIN_NO"],
				places_dispo: record["Disponibilité de places MAX JEUNE et MAX SENIOR"] == "OUI"
			};


			string origine = traduireGare(record["Origine"]).toUpper;

			iata_dict[nouveau_trajet.oiata] = origine;
			iata_dict[nouveau_trajet.diata] = nouveau_trajet.destination;

			if (!(origine in trajets)) {
				trajets[origine] = SList!Trajet();
			}
			trajets[origine].insertFront(nouveau_trajet);

			n++;
		}

		ajouterTrajetsTER();

		writeln("Base de données prête, nombre d'entrées : ", n);
	}

	bool origineExiste(string gare)
	{
		return (gare in trajets) != null;
	}

	string traduireIATA(string iata)
	{
		return iata_dict[iata];
	}

	DateTime[string] destinationsDepuis(string origine, DateTime arrivee)
	{
		DateTime[string] ret;

		if (!origineExiste(origine))
			return ret;

		foreach (trajet; trajets[origine][]) {
			if (trajet.depart >= arrivee || trajet.TER) {
				if (!(trajet.destination in ret))
					ret[trajet.destination] = trajet.arrivee;
				else if (trajet.TER)
					ret[trajet.destination] = arrivee;
				else if (ret[trajet.destination] > trajet.arrivee)
					ret[trajet.destination] = trajet.arrivee;
			}
		}

		return ret;
	}

	SList!Trajet trajetsDepuisVers(string origine, string destination, DateTime depart)
	{
		auto ret = SList!Trajet();

		foreach (trajet; trajets[origine][]) {
			if ((trajet.depart >= depart || trajet.TER) && trajet.destination == destination) {
				if (trajet.TER) {
					trajet.depart = depart;
					trajet.arrivee = depart;
				}

				ret.insertFront(trajet);
			}
		}

		return ret;
	}
}
