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
        /*SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = msg; /* impedisco l'inserimento */
	ELSE
		IF ((NEW.setLocali=2 AND NEW.setOspiti=2)) THEN
			SET msg= "2=2";
			INSERT INTO ERROR VALUES(msg);
		/*	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = msg; /* impedisco l'inserimento */
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
	INSERT INTO ERROR VALUES(CONCAT(dataOggi," ",annoOggi," ",scadenza));
	IF (dataOggi>scadenza AND dataOggi<riapertura) THEN
		INSERT INTO ERROR VALUES(msg);
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = msg; /* impedisco l'inserimento */
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