DELETE FROM PARTITADAGIOCARE;
DELETE FROM PERSONALESQUADRA;
DELETE FROM GIOCATORE;
DELETE FROM SQUADRA;
DELETE FROM ARBITRO;
DELETE FROM PALESTRA;
DELETE FROM SOCIETA;

INSERT INTO ADMIN
VALUES
	("admin","admin")
	;

INSERT INTO SOCIETA
VALUES
	("aurora"),
	("marsango"),
	("albatross"),
	("ASPbrenta"),
	("rambla")
	;

INSERT INTO PALESTRA
VALUES
	("camisano vicentino", 	"scuola elementare", 	  100),
	("marsango",			"scuola media", 		  10),
	("abano terme", 		"palazzetto dello sport", 350),
	("roncajette", 			"palazzetto del basket",  150)
	;

INSERT INTO ARBITRO
VALUES
	("1234567890123456", "Matteo", 		"Badan"),
	("2345678901234567", "Roberto", 	"Peron"),
	("3456789012345678", "Gabriele", 	"Fregonese")
	;

INSERT INTO SQUADRA
VALUES
	("aurora76",	"aurora",		"camisano vicentino"),
	("phoenix",		"marsango",		"marsango"),
	("bugabar", 	"marsango",		"marsango"),
	("albatross_A",	"albatross",	"abano terme"),
	("albatross_B", "albatross",	"abano terme"),
	("ramblatori", 	"rambla", 		"marsango"),
	("brenta3", 	"ASPbrenta", 	"roncajette"),
	("pieve_B",		"aurora",		"camisano vicentino")
	;

INSERT INTO PERSONALESQUADRA
VALUES
	("pierantoniofacco", "Pierantonio", "Facco", "allenatore", "aurora76")
	;

INSERT INTO GIOCATORE
VALUES
	("matteorigonmatte",	"Matteo", 		"Rigon", 		"piazzola sul brenta via nizza 1", 			60000,  "opposto", 	"aurora76"),
	("matteofaccinmatt", 	"Matteo", 		"Faccin", 		"piazzola sul brenta via f.lli cervi 15", 	50000,  "banda", 	"aurora76"),
	("albertodeagostin", 	"Alberto", 		"De Agostini", 	"piazzola sul brenta via f.lli cervi 23", 	35000,  "libero", 	"aurora76"),
	("vittoriomarinivi", 	"Vittorio", 	"Marini", 		"piazzola sul brenta via garibaldi 1", 		6000, 	"centrale", "aurora76"),
	("emanuelefontolan", 	"Emanuele", 	"Fontolan", 	"campo san martino via dei lupi 5", 		0, 		NULL, 	NULL),
	("filippofaccofili", 	"Filippo", 		"Facco", 		"piazzola sul brenta via scuole 61", 		80000, 	"centrale", "aurora76"),
	("lucasemenzatoluc", 	"Luca", 		"Semenzato", 	"camisano vicentino via XX settembre 21", 	160000, "alzatore", "aurora76"),
	("davidelupatidavi",	"Davide", 		"Lupati", 		"campo san martino via dei lupi 12", 		60500, 	"banda", 	"phoenix"),
	("marcodalbonmarco", 	"Marco", 		"Dal Bon", 		"campo san martino via agriturismo 6", 		15000, 	"libero", 	"phoenix"),
	("manuelmeneghetti",	"Manuel", 		"Meneghetti", 	"piazzola sul brenta via roma 5", 			15000, 	"alzatore", "phoenix"),
	("pieroguidolinpie", 	"Piero", 		"Guidolin", 	"marsango via buga 11", 					25000, 	"opposto",	"phoenix"),
	("alexgrosselealex", 	"Alex", 		"Grossele", 	"villa del conte via alessandro 3", 		20000, 	"banda", 	"phoenix"),
	("stefanotrentoste", 	"Stefano", 		"Trento", 		"campo san martino via trento 30", 			30000, 	"centrale", "phoenix"),
	("gianniperuzzogia", 	"Gianni", 		"Peruzzo", 		"vaccarino via design 99", 					30000, 	"centrale", "ramblatori"),
	("federicofrizzari", 	"Federico", 	"Frizzarin", 	"piazzola sul brenta via federico 41", 		25000, 	"centrale", "ramblatori"),
	("alessiomalossoal", 	"Alessio", 		"Malosso", 		"limena via limenella 13", 					5000, 	"banda", 	"ramblatori"),
	("nicolabordinnico", 	"Nicola", 		"Bordin", 		"vaccarino via design 61", 					50000, 	"banda", 	"ramblatori"),
	("fabriziobicciofa", 	"Fabrizio", 	"Biccio", 		"vaccarino via roverati 12", 				65000, 	"opposto", 	"ramblatori"),
	("nicolaroveratoni", 	"Nicola", 		"Roverato", 	"vaccarino via roverati 15", 				58000, 	"alzatore", "ramblatori"),
	("stevenseagalstev", 	"Steven", 		"Seagal", 		"padova via guido reni 15", 				84000, 	"banda", 	"pieve_B"),
	("sylvesterstallon", 	"Sylvester", 	"Stallone", 	"padova via guido reni 92", 				43000, 	"banda", 	"pieve_B"),
	("jeancleaudvandam", 	"Jean Claude", 	"Van Damme", 	"padova via anelli 2", 						16000, 	"alzatore", "pieve_B"),
	("chucknorrischuck", 	"Chuck", 		"Norris", 		"padova prato della valle 1", 				475000, "opposto", 	"pieve_B"),
	("arnoldschwarzene", 	"Arnold", 	  "Schwarzenegger", "limena via aosta 5", 						463000, "centrale", "pieve_B"),
	("terrycrewsterryc", 	"Terry", 		"Crews", 		"abano terme via columbus 48",			 	3000, 	"centrale", "pieve_B"),
	("stanleykubrickst", 	"Stanley", 		"Kubrick", 		"milano via delle opere 6", 				46000, 	"opposto", 	"albatross_A"),
	("federicofellinif", 	"Federico", 	"Fellini", 		"milano via delle opere 19", 				76000, 	"banda", 	"albatross_A"),
	("alfredhitchcocka", 	"Alfred", 		"Hitchcock", 	"milano via oscar 1", 						47000, 	"centrale", "albatross_A"),
	("quentintarantino", 	"Quentin", 		"Tarantino", 	"torino via roma 8", 						75000, 	"centrale", "albatross_A"),
	("sergioleonesergi", 	"Sergio", 		"Leone", 		"brescia via degli ulivi 18", 				30000, 	"banda", 	"albatross_A"),
	("stevenspielbergs", 	"Steven", 		"Spielberg", 	"padova prato della valle 17", 				65000, 	"alzatore", "albatross_A"),
	("robertobaggiorob", 	"Roberto", 		"Baggio", 		"brescia via roma 124", 					50000, 	"opposto", 	"albatross_B"),
	("gianniriveragian", 	"Gianni", 		"Rivera", 		"milano via dello stadio 74", 				55000, 	"centrale", "albatross_B"),
	("francescotottifr", 	"Francesco", 	"Totti", 		"roma via centrale 10", 					45000, 	"libero", 	"albatross_B"),
	("alessandrodelpie", 	"Alessandro", 	"Del Piero", 	"padova via guido reni 96", 				35000, 	"banda", 	"albatross_B"),
	("giuseppemeazzagi", 	"Giuseppe", 	"Meazza", 		"milano via dello stadio 11", 				63000, 	"banda", 	"albatross_B"),
	("gigirivagigiriva", 	"Gigi", 		"Riva", 		"milano via centrale 24", 					21000, 	"alzatore", "albatross_B"),
	("gabrieleborgatog", 	"Gabriele", 	"Borgato", 		"legnaro via agripolis 2", 					21000, 	"opposto", 	"brenta3"),
	("andreatosattoand", 	"Andrea", 		"Tosatto", 		"cadoneghe via trieste 65", 				25000, 	"opposto", 	"brenta3"),
	("alessandrosalvia", 	"Alessandro", 	"Salvi", 		"padova via del tram 28", 					27000, 	"banda", 	"brenta3"),
	("jacopoperuzzojac", 	"Jacopo", 		"Peruzzo", 		"piazzola sul brenta via nizza 15", 		52000, 	"centrale", "brenta3"),
	("albertoperuzzoal", 	"Alberto", 		"Peruzzo", 		"piazzola sul brenta via nizza 15", 		53000, 	"centrale", "brenta3"),
	("andreaperuzzoand", 	"Andrea", 		"Peruzzo", 		"piazzola sul brenta via nizza 15", 		64000, 	"alzatore", "brenta3"),
	("damianofassinada", 	"Damiano", 		"Fassina", 		"limena via dell'orto 84", 					51000, 	"banda", 	"bugabar"),
	("leonardomasonleo", 	"Leonardo", 	"Mason", 		"limena via dell'orto 41", 					65000, 	"alzatore", "bugabar"),
	("giovannibrogiogi", 	"Giovanni", 	"Brogio", 		"vigodarzere via lecce 43", 				1000, 	"centrale", "bugabar"),
	("lucatornieroluca", 	"Luca", 		"Torniero", 	"piazzola sul brenta via garibaldi 68", 	10000, 	"centrale", "bugabar"),
	("mattiabertomatti", 	"Mattia", 		"Berto", 		"piazzola sul brenta via roma 14", 			42000, 	"opposto", 	"bugabar"),
	("mattiabruseghinm", 	"Mattia", 		"Bruseghin", 	"piazzola sul brenta via etna 6", 			100000, "libero", 	"bugabar")
	;

INSERT INTO UTENTE
VALUES
	("alberto","deagostini","albertodeagostin"),
	("syl","stallone","sylvesterstallon")
	;

call creaPartita('aurora76','phoenix','2015-08-20');
call creaPartita('aurora76','phoenix','2015-08-21');
call creaPartita('aurora76','phoenix','2015-08-22');
call creaPartita('aurora76','phoenix','2015-08-23');
call creaPartita('phoenix','aurora76','2015-08-20');
call creaPartita('phoenix','aurora76','2015-08-21');
call creaPartita('phoenix','aurora76','2015-08-22');
call creaPartita('phoenix','aurora76','2015-08-23');
call creaPartita('phoenix','albatross_A','2015-08-28');
call creaPartita('phoenix','albatross_A','2015-08-29');
call creaPartita('phoenix','albatross_A','2015-08-30');

