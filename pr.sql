/* questo file contiene tutto, l'esecuzione di esso crea un database completo */

DROP TABLE IF EXISTS CLASSIFICA;
DROP TABLE IF EXISTS PARTITADAGIOCARE;
DROP TABLE IF EXISTS PARTITAGIOCATA;
DROP TABLE IF EXISTS PERSONALESQUADRA;
DROP TABLE IF EXISTS UTENTE;
DROP TABLE IF EXISTS GIOCATORE;
DROP TABLE IF EXISTS SPONSORSQUADRA;
DROP TABLE IF EXISTS SPONSOR;
DROP TABLE IF EXISTS SQUADRA;
DROP TABLE IF EXISTS ARBITRO;
DROP TABLE IF EXISTS PALESTRA;
DROP TABLE IF EXISTS SOCIETA;
DROP TABLE IF EXISTS ADMIN;
DROP TABLE IF EXISTS ERROR;


CREATE TABLE IF NOT EXISTS ADMIN(
	`username` VARCHAR(20) NOT NULL,
	`password` VARCHAR(20) NOT NULL,
	PRIMARY KEY(`username`)
)ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS ERROR(
	`msg` VARCHAR(255)
)ENGINE=InnoDB;


CREATE TABLE IF NOT EXISTS SOCIETA(
	`nome`					VARCHAR(25) NOT NULL,
	PRIMARY KEY(`nome`)
)
ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS PALESTRA(
	`indirizzo`				VARCHAR(50) NOT NULL,
	`nome`					VARCHAR(25) NOT NULL,
	`capienza`				SMALLINT UNSIGNED,
	PRIMARY KEY(`indirizzo`)
)
ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS ARBITRO(
	`CF`					CHAR(16) NOT NULL,
	`nome`					VARCHAR(25) NOT NULL,
	`cognome`				VARCHAR(25) NOT NULL,
	PRIMARY KEY(`CF`)	
)
ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS SPONSOR(
	`nome` 					VARCHAR(25) NOT NULL,
	`importo_donazione`		INT UNSIGNED,
	PRIMARY KEY(`nome`)
)
ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS SQUADRA(
	`nome` 					VARCHAR(25) NOT NULL,
	`societa`				VARCHAR(25),
	`indirizzoPal`			VARCHAR(50),
	PRIMARY KEY(`nome`),
	FOREIGN KEY(`societa`)
	REFERENCES SOCIETA(`nome`)
	ON DELETE SET NULL 
	ON UPDATE CASCADE,
	FOREIGN KEY(`indirizzoPal`)
	REFERENCES PALESTRA(`indirizzo`)
	ON DELETE SET NULL 
	ON UPDATE CASCADE
)
ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS SPONSORSQUADRA(
	`sponsor`				VARCHAR(25) NOT NULL,
	`squadra`				VARCHAR(25) NOT NULL,
	PRIMARY KEY(`squadra`,`sponsor`),
	FOREIGN KEY(`squadra`) REFERENCES SQUADRA(`nome`)
	ON DELETE RESTRICT ON UPDATE CASCADE,
	FOREIGN KEY(`sponsor`) REFERENCES SPONSOR(`nome`)
	ON DELETE RESTRICT ON UPDATE CASCADE
)
ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS GIOCATORE(
	`CF`					CHAR(16) NOT NULL,
	`nome` 					VARCHAR(25) NOT NULL,
	`cognome` 				VARCHAR(25) NOT NULL,
	`indirizzo` 			VARCHAR(50),
	`ingaggio` 				INT UNSIGNED,
	`ruoloPreferito`		VARCHAR(20),
	`squadra` 				VARCHAR(25),
	PRIMARY KEY(`CF`),
	FOREIGN KEY(`squadra`) REFERENCES SQUADRA(`nome`)
	ON DELETE SET NULL ON UPDATE CASCADE
)
ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS UTENTE(
	`username` VARCHAR(20) NOT NULL,
	`password` VARCHAR(20) NOT NULL,
	`CodFisc`  CHAR(16),
	PRIMARY KEY(`username`),
	FOREIGN KEY(`CodFisc`) REFERENCES GIOCATORE(`CF`)
	ON DELETE SET NULL ON UPDATE CASCADE
)ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS PERSONALESQUADRA(
	`CF`					CHAR(16) NOT NULL,
	`nome`					VARCHAR(25) NOT NULL,
	`cognome`				VARCHAR(25) NOT NULL,
	`Ruolo`					ENUM('manager','allenatore','presidente'),
	`squadra` 				VARCHAR(25),
	PRIMARY KEY (`CF`),
	FOREIGN KEY(`squadra`) REFERENCES SQUADRA(`nome`)
	ON DELETE SET NULL ON UPDATE CASCADE
)
ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS PARTITAGIOCATA(
	`id`					INT UNSIGNED,
	`data`					DATE NOT NULL,
	`locali`				VARCHAR(25) NOT NULL,
	`ospiti`				VARCHAR(25) NOT NULL,
	`palestra`				VARCHAR(50) NOT NULL,
	`arbitro`				CHAR(16) NOT NULL,
	`setLocali`				SMALLINT UNSIGNED NOT NULL,
	`setOspiti` 			SMALLINT UNSIGNED NOT NULL,
	PRIMARY KEY(`id`),
	FOREIGN KEY(`locali`) REFERENCES SQUADRA(`nome`),
	FOREIGN KEY(`ospiti`) REFERENCES SQUADRA(`nome`),
	FOREIGN KEY(`arbitro`) REFERENCES ARBITRO(`CF`)
	ON DELETE RESTRICT ON UPDATE CASCADE,
	FOREIGN KEY(`palestra`) REFERENCES PALESTRA(`indirizzo`)
	ON DELETE RESTRICT ON UPDATE CASCADE
)
ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS PARTITADAGIOCARE(
	`id`					INT UNSIGNED,
	`data`					DATE NOT NULL,
	`locali`				VARCHAR(25) NOT NULL,
	`ospiti`				VARCHAR(25) NOT NULL,
	`palestra`				VARCHAR(50) NOT NULL,
	`arbitro`				CHAR(16) NOT NULL,
	PRIMARY KEY(`id`),
	FOREIGN KEY(`locali`) REFERENCES SQUADRA(`nome`)
	ON DELETE RESTRICT ON UPDATE CASCADE,
	FOREIGN KEY(`ospiti`) REFERENCES SQUADRA(`nome`)
	ON DELETE RESTRICT ON UPDATE CASCADE,
	FOREIGN KEY(`arbitro`) REFERENCES ARBITRO(`CF`)
	ON DELETE RESTRICT ON UPDATE CASCADE,
	FOREIGN KEY(`palestra`) REFERENCES PALESTRA(`indirizzo`)
	ON DELETE RESTRICT ON UPDATE CASCADE
)
ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS CLASSIFICA(
	`squadra`				VARCHAR(25) NOT NULL,
	`punteggio`				SMALLINT UNSIGNED NOT NULL DEFAULT 0,
	`pGiocate`				SMALLINT UNSIGNED NOT NULL DEFAULT 0,
	`pVinte` 				SMALLINT UNSIGNED NOT NULL DEFAULT 0,
	`pPerse`				SMALLINT UNSIGNED NOT NULL DEFAULT 0,
	`setVinti`				SMALLINT UNSIGNED NOT NULL DEFAULT 0,
	`setPersi`				SMALLINT UNSIGNED NOT NULL DEFAULT 0,
	PRIMARY KEY(`squadra`),
	FOREIGN KEY(`squadra`) REFERENCES SQUADRA(`nome`)
	ON DELETE CASCADE ON UPDATE CASCADE
)
ENGINE = InnoDB;



/**************** PROCEDURE **********************/

/* sposta partita serve per modellare la richiesta di spostare una determinatata partita,
   tramite trigger viene controllato che la palestra nella data richiesta sia libera 
   in caso opposto viene scritto un errore nella tabella ERROR 		*/
DROP PROCEDURE IF EXISTS spostaPartita;
DELIMITER $
CREATE PROCEDURE spostaPartita(IN squadraA VARCHAR(25), squadraB VARCHAR(25), dataVecchia DATE, dataNuova DATE)
BEGIN
	DECLARE idPartita INT UNSIGNED;
	DECLARE idTemp INT UNSIGNED;
	DECLARE palestraP VARCHAR(50);
	SELECT id, palestra INTO idPartita, palestraP FROM PARTITADAGIOCARE WHERE
	locali=squadraA AND ospiti=squadraB AND data=dataVecchia;
	SELECT id INTO idTemp FROM PARTITADAGIOCARE WHERE
	locali=squadraA AND ospiti=squadraB AND data=dataNuova AND palestra=palestraP;

	IF idPartita IS NOT NULL THEN
		IF idTemp IS NULL THEN
			UPDATE PARTITADAGIOCARE SET data=dataNuova WHERE id=idPartita;
		ELSE
			INSERT INTO ERROR VALUES('palestra gia occupata quel giorno');
		END IF;
	ELSE
		INSERT INTO ERROR VALUES('nessuna partita da spostare in quella data tra le due squadre');
	END IF;
END;
$
DELIMITER ;

/* chiamando crea partita si inserisce una row sulla tabella partitadagiocare con squadraA
   squadraB in data scelta (se possibile), il resto dei dati e' auto compilato */
DROP PROCEDURE IF EXISTS creaPartita;
DELIMITER $
CREATE PROCEDURE creaPartita(IN squadraA VARCHAR(25), squadraB VARCHAR(25), dataPartita DATE)
BEGIN
	DECLARE luogoPartita VARCHAR(50);
	DECLARE idPartita INT;
	DECLARE arbitroPartita CHAR(16);
	-- prendo l'indirizzo della squadra di casa --
	SELECT indirizzoPal INTO luogoPartita 
	FROM SQUADRA WHERE nome=squadraA;
	-- aumento sempre l'identificatore della partita --
	SELECT MAX(id) INTO idPartita
	FROM PARTITADAGIOCARE;
	SET idPartita=idPartita+1;
	IF idPartita IS NULL THEN
		SET idPartita=0;
	END IF;
	-- ad ogni partita assegno un arbitro casuale --
	SELECT CF INTO arbitroPartita
	FROM ARBITRO ORDER BY RAND() LIMIT 1;

	INSERT INTO PARTITADAGIOCARE VALUES(
		idPartita, dataPartita, squadraA, squadraB, luogoPartita, arbitroPartita
	);
END;
$
DELIMITER ;


/* chiamando chiudiPartita si va a togliere una entry da PARTITEDAGIOCARE e la si 
   inserisce con il risultato richiesto in PARTITEGIOCATE. Qualche trigger si occupera'
   di controllare che i dati immessi siano validi e di aggiornare la classifica */
DROP PROCEDURE IF EXISTS chiudiPartita;
DELIMITER $
CREATE PROCEDURE chiudiPartita(IN squadraA VARCHAR(25), squadraB VARCHAR(25), dataPartita DATE, punteggioA SMALLINT UNSIGNED, punteggioB SMALLINT UNSIGNED)
BEGIN 
	DECLARE idPartita INT;
	DECLARE palestraP VARCHAR(25);
	DECLARE arbitroP  CHAR(16);
	DECLARE nuovoId   INT;
	/* recupero tutti i dati che mi servono della partita appena giocata */
	SELECT	id, palestra, arbitro INTO idPartita, palestraP, arbitroP
	FROM PARTITADAGIOCARE
	WHERE locali=squadraA AND ospiti=squadraB AND data=dataPartita;
	IF idPartita IS NOT NULL THEN
		/* id autoincrementante */
		SELECT MAX(id) INTO nuovoId
		FROM PARTITAGIOCATA;
		SET nuovoId=nuovoId+1;
		IF nuovoId IS NULL THEN
			SET nuovoId=0;
		END IF;
		/* inserisco i dati come partita giocata (un trigger si occupera' di eliminare la entry relativa alla partitadagiocare*/
		INSERT INTO PARTITAGIOCATA VALUES(
			nuovoId, dataPartita, squadraA, squadraB, palestraP, arbitroP, punteggioA, punteggioB
		);
	ELSE
		INSERT INTO ERROR VALUES('nessuna partita da chiudere in quella data tra le due squadre');
	END IF;
END;
$
DELIMITER ;

/* procedura per controllare se un login e' valido, ritorna vari dati dell'utente */
DROP PROCEDURE IF EXISTS login;
DELIMITER $
CREATE PROCEDURE login
(IN nomeUtente VARCHAR(20), IN passwordUtente VARCHAR(20), OUT  esito BOOL, OUT admin BOOL, OUT giocatore BOOL, OUT usernameU VARCHAR(20), OUT squadraU VARCHAR(25), OUT codfiscU CHAR(16))
BEGIN
	SET esito=FALSE;
	SET admin=FALSE;
	SELECT COUNT(*)>0 INTO admin FROM ADMIN
	WHERE username=nomeUtente AND password=passwordUtente;
	IF(admin) THEN
		SET admin=TRUE;
		SET esito=TRUE;
	ELSE
		SELECT COUNT(*)>0 INTO esito FROM UTENTE
		WHERE username=nomeUtente AND password=passwordUtente;
		IF(esito) THEN
			SET esito=TRUE;
			SET usernameU=nomeUtente;
			SELECT CodFisc INTO codfiscU FROM UTENTE 
			WHERE username=nomeUtente;
			IF codfiscU IS NOT NULL THEN
				SET giocatore=TRUE;
				SELECT SQUADRA.nome INTO squadraU FROM GIOCATORE,SQUADRA 
				WHERE GIOCATORE.CF=codfiscU AND GIOCATORE.squadra=SQUADRA.nome;
			END IF;
		END IF; 
	END IF;
END;
$
DELIMITER ;




/*********************** TRIGGERS **************************/

/* ogniqualvolta inserisco una squadra la aggiungo alla classifica */
DROP TRIGGER IF EXISTS aggiungiSquadraAllaClassifica;
CREATE TRIGGER aggiungiSquadraAllaClassifica
AFTER insert ON SQUADRA
FOR EACH ROW
INSERT INTO CLASSIFICA values(new.nome, 0, 0, 0, 0, 0, 0);

/* trigger per controllare che la data della partita creata sia accettabile */
/* in caso contrario la partita viene settata per essere giocata tra 2 settimane */
DROP TRIGGER IF EXISTS checkData;
DELIMITER $
CREATE TRIGGER checkData
BEFORE INSERT ON PARTITADAGIOCARE FOR EACH ROW
BEGIN
	DECLARE oldData DATE;
	SET oldData = NEW.data;
	IF (oldData < CURDATE()) THEN
		SET oldData = CURDATE();
		/* se la data della partita non e' valida la metto tra 2 settimane */
		SET oldData = DATE_ADD(oldData, INTERVAL 2 WEEK);
		SET NEW.data = oldData;
	END IF;
END $
DELIMITER ;

/* come il trigger precedente ma before update invece che before insert */
DROP TRIGGER IF EXISTS checkUpdatedData;
DELIMITER $
CREATE TRIGGER checkUpdatedData
BEFORE UPDATE ON PARTITADAGIOCARE FOR EACH ROW
BEGIN
	DECLARE oldData DATE;
	SET oldData = NEW.data;
	IF (oldData < CURDATE()) THEN
		SET oldData = CURDATE();
		/* se la data della partita non e' valida la metto tra 2 settimane */
		SET oldData = DATE_ADD(oldData, INTERVAL 2 WEEK);
		INSERT INTO ERROR VALUES(CONCAT("Data non valida, la partita e' stata spostata in data ",oldData));
		SET NEW.data = oldData;
	END IF;
END $
DELIMITER ;


/* trigger per controllare la validita' dei punteggi immessi in una partita giocata */
DROP TRIGGER IF EXISTS checkRisultato;
DELIMITER $
CREATE TRIGGER checkRisultato
BEFORE INSERT ON PARTITAGIOCATA
FOR EACH ROW
BEGIN
	DECLARE msg VARCHAR(80);
	SET msg="Punteggio non valido, possibili combinazioni sono 3-0 3-1 3-2 2-3 1-3 0-3";

	IF ((NEW.setLocali + NEW.setOspiti)<3 OR (NEW.setLocali + NEW.setOspiti)>5) THEN
		INSERT INTO ERROR VALUES(msg);
        CALL punteggio_inserito_non_valido ; /* impedisco l'inserimento */
	ELSE
		IF ((NEW.setLocali=2 AND NEW.setOspiti=2) OR (NEW.setLocali=2 AND NEW.setOspiti=1) OR (NEW.setLocali=1 AND NEW.setOspiti=2)) THEN
			SET msg= "2=2";
			INSERT INTO ERROR VALUES(msg);
			CALL punteggio_inserito_non_valido ; /* impedisco l'inserimento */
		END IF;
	END IF;

END $
DELIMITER ;


/* trigger per impedire l'inserimento di una squadra se e' oltre la data di termine iscrizioni (1 settembre) */
DROP TRIGGER IF EXISTS checkScadenza;
DELIMITER $
CREATE TRIGGER checkScadenza
BEFORE INSERT ON SQUADRA
FOR EACH ROW
BEGIN
	DECLARE dataOggi DATE;
	DECLARE annoOggi SMALLINT;
	DECLARE scadenza DATE;
	DECLARE riapertura DATE;
	DECLARE msg VARCHAR(50);
	SET dataOggi = CURDATE();
	SET annoOggi = YEAR(dataOggi);
	SET scadenza = CONCAT(annoOggi,"-09-15");
	SET annoOggi = annoOggi+1;	/* annoOggi diventa annoProssimo */
	SET riapertura = CONCAT(annoOggi,"-06-01");
	SET msg = "Errore: scadenza iscrizioni squadre 1 settembre";
	IF (dataOggi>scadenza AND dataOggi<riapertura) THEN
		INSERT INTO ERROR VALUES(msg);
		CALL non_puoi_iscrivere_squadre_iscrizioni_gia_chiuse ; /* impedisco l'inserimento */
	END IF;
END $ 
DELIMITER ;

/* trigger per automatizzare l'aggiornamento della classifica, ogni volta che viene 
   'chiusa' una partita la classifica si aggiornera' in base al punteggio messo e la
   partita relativa in partitadagiocare viene eliminata */
DROP TRIGGER IF EXISTS aggClassifica;
DELIMITER $
CREATE TRIGGER aggClassifica
AFTER INSERT ON PARTITAGIOCATA
FOR EACH ROW
BEGIN
	DECLARE puntiA SMALLINT;
	DECLARE puntiB SMALLINT;
	DECLARE casi TINYINT UNSIGNED;
	IF NEW.setLocali=3 THEN
		IF NEW.setOspiti<2 THEN
			SET puntiA = 3;
			SET puntiB = 0;
			SET casi=1;
		ELSE
			SET puntiA = 2;
			SET puntiB = 1;
			SET casi=2;
		END IF;
	ELSE
		IF NEW.setLocali<2 THEN
			SET puntiB = 3;
			SET puntiA = 0;
			SET casi=3;
		ELSE
			SET puntiB = 2;
			SET puntiA = 1;
			SET casi=4;
		END IF;
	END IF;
	/* aggiorno effettivamente la classifica */
	CASE casi
		WHEN 1 THEN
			UPDATE CLASSIFICA 
			SET punteggio=punteggio+3,pGiocate=pGiocate+1,pVinte=pVinte+1,setVinti=setVinti+NEW.setLocali,setPersi=setPersi+NEW.setOspiti
			WHERE squadra=NEW.locali;
			UPDATE CLASSIFICA 
			SET pGiocate=pGiocate+1,pPerse=pPerse+1,setVinti=setVinti+NEW.setOspiti,setPersi=setPersi+NEW.setLocali
			WHERE squadra=NEW.ospiti;
		WHEN 2 THEN
			UPDATE CLASSIFICA 
			SET punteggio=punteggio+2,pGiocate=pGiocate+1,pVinte=pVinte+1,setVinti=setVinti+NEW.setLocali,setPersi=setPersi+NEW.setOspiti
			WHERE squadra=NEW.locali;
			UPDATE CLASSIFICA 
			SET punteggio=punteggio+1,pGiocate=pGiocate+1,pPerse=pPerse+1,setVinti=setVinti+NEW.setOspiti,setPersi=setPersi+NEW.setLocali
			WHERE squadra=NEW.ospiti;
		WHEN 3 THEN
			UPDATE CLASSIFICA 
			SET pGiocate=pGiocate+1,pPerse=pPerse+1,setVinti=setVinti+NEW.setLocali,setPersi=setPersi+NEW.setOspiti
			WHERE squadra=NEW.locali;
			UPDATE CLASSIFICA 
			SET punteggio=punteggio+3,pGiocate=pGiocate+1,pVinte=pVinte+1,setVinti=setVinti+NEW.setOspiti,setPersi=setPersi+NEW.setLocali
			WHERE squadra=NEW.ospiti;
		WHEN 4 THEN
			UPDATE CLASSIFICA 
			SET punteggio=punteggio+1,pGiocate=pGiocate+1,pPerse=pPerse+1,setVinti=setVinti+NEW.setLocali,setPersi=setPersi+NEW.setOspiti
			WHERE squadra=NEW.locali;
			UPDATE CLASSIFICA 
			SET punteggio=punteggio+2,pGiocate=pGiocate+1,pVinte=pVinte+1,setVinti=setVinti+NEW.setOspiti,setPersi=setPersi+NEW.setLocali
			WHERE squadra=NEW.ospiti;
	END CASE;
	/* elimino la partita appena giocata da quelle da giocare */
	DELETE FROM PARTITADAGIOCARE WHERE locali=NEW.locali AND ospiti=NEW.ospiti AND data=NEW.data;
END $
DELIMITER ;




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

INSERT INTO SPONSOR
VALUES
	("bugabar",			"12000"),
	("rumore di mare",	"5000"),
	("fioreria 5 petali","17000")
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

INSERT INTO SPONSORSQUADRA
VALUES
	("bugabar", 			"phoenix"),
	("rumore di mare", 		"phoenix"),
	("fioreria 5 petali", 	"aurora76")
	;


INSERT INTO PERSONALESQUADRA
VALUES
	("pierantoniofacco", "Pierantonio", "Facco",  "allenatore", "aurora76"),
	("giovannipezzolig", "Giovanni", 	"Pezzoli","allenatore", "albatross_B"),
	("wolfofwallstreet", "Jordan",		"Belfort","manager",	"pieve_B"),
	("barackobamabarac", "Barack",		"Obama",  "presidente",	"pieve_B")
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
	("alberto", "deagostini", "albertodeagostin"),
	("syl", 	"stallone",   "sylvesterstallon"),
	("mauro",	"conti",	  NULL)
	;

/*call creaPartita('aurora76','phoenix','2015-08-20');
call creaPartita('aurora76','phoenix','2015-08-21');
call creaPartita('aurora76','phoenix','2015-08-22');
call creaPartita('aurora76','phoenix','2015-08-23');
call creaPartita('phoenix','aurora76','2015-08-20');
call creaPartita('phoenix','aurora76','2015-08-21');
call creaPartita('phoenix','aurora76','2015-08-22');
call creaPartita('phoenix','aurora76','2015-08-23');
call creaPartita('phoenix','albatross_A','2015-08-28');
call creaPartita('phoenix','albatross_A','2015-08-29');
call creaPartita('phoenix','albatross_A','2015-08-30');*/
