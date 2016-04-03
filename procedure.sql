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