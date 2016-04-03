<?php 
	require_once('sessions.php'); 
?>
<!DOCTYPE HTML>
<html>
<head>
	<link rel="stylesheet" type="text/css" href="css/style.css">
</head>
<body>
	<div class="header">
	</div>

	<div class="nav">
		<ul>
			<li><a href="index.php">Classifica</a></li>
			<li><a href="inscribeteam.php">Iscrivi una squadra</a></li>
			<li><a href="calendar.php">Calendario partite</a></li>
			<li><a href="oldmatches.php">Scorse partite</a></li>
			<li><a href="addresult.php">Inserisci un risultato</a></li>
		</ul>
	</div>
	<div class="content">
		<?php
			if(isset($_POST['codiceFiscale'])){
				//controllo sia giusto il cf con una query
				$res = $con->query("SELECT count(*) AS numero FROM UTENTE WHERE CodFisc='".$_POST['codiceFiscale']."'");
				$tmp = $res->fetch_assoc();
				if($tmp['numero'] != 0){
					$error = "Errore: il giocatore risulta essere gia' connesso ad un utente";
				}
				else{
					$res = $con->query("SELECT * FROM GIOCATORE WHERE cf='".$_POST['codiceFiscale']."'");
					$tmp = $res->fetch_assoc();
					if($tmp == NULL){
						$error = "Errore: Non esiste nessun giocatore con quel codice fiscale";
					}
					else{
						$con->query("UPDATE UTENTE SET CodFisc='".$_POST['codiceFiscale']."' WHERE UTENTE.username='".$_SESSION['username']."'");
						$_SESSION['cf'] = $_POST['codiceFiscale'];
						$_SESSION['isGiocatore'] = 1;
						$_SESSION['squadra'] = $tmp['squadra'];
						$_SESSION['nome'] = $tmp['nome'];
						$_SESSION['cognome'] = $tmp['cognome'];
						$_SESSION['indirizzo'] = $tmp['indirizzo'];
						$_SESSION['ingaggio'] = $tmp['ingaggio'];
						$_SESSION['ruolo'] = $tmp['ruoloPreferito'];
					}
				}
			}
			if(!$_SESSION['isGiocatore']){
				echo $error."<br>";
				echo "<p>Sei membro di una squadra?</p>";
				echo "<p>Metti qui il tuo codice fiscale e sarai collegato al giocatore corrispondente!</p>";
				echo "<p>N.B. non e' piu' possibile cambiarlo dopo averlo settato!";
				$_formcf =  "<form class='form-cf' method='POST' action='".$_SERVER['PHP_SELF']."'>";
				$_formcf .= "<input type='text' size='16' maxlength='16' name='codiceFiscale'></input>";
				$_formcf .= "<input type='submit'></input></form>";
				echo $_formcf;
			}
			else{
				if(isset($_POST['nome']) && isset($_POST['cognome']) && (strlen($_POST['nome'])>0) && (strlen($_POST['cognome'])>0)){	//try to update profile
					if(!$con->query("UPDATE GIOCATORE SET nome='".$_POST['nome']."' , cognome='".$_POST['cognome']."' , indirizzo='".$_POST['indirizzo']."' , ingaggio='".$_POST['ingaggio']."' , ruoloPreferito='".$_POST['ruoloPreferito']."' , squadra='".$_POST['squadra']."' WHERE CF='".$_SESSION['cf']."'"))
						echo "<h4>Errore: qualcosa e' andato storto durante l'aggiornamento dei dati. </h4>";
					else{
						echo "<h4>Aggiornamento dei dati avvenuto con successo! </h4>";
						$_SESSION['nome']=$_POST['nome'];
						$_SESSION['cognome']=$_POST['cognome'];
						$_SESSION['indirizzo']=$_POST['indirizzo'];
						$_SESSION['ingaggio']=$_POST['ingaggio'];
						$_SESSION['ruolo']=$_POST['ruoloPreferito'];
						$_SESSION['squadra']=$_POST['squadra'];
					}
				}
				if(isset($_POST['nome']) && isset($_POST['cognome']) && (strlen($_POST['nome'])==0 || strlen($_POST['cognome'])==0))
					echo "Errore: Nome e Cognome non possono essere vuoti";
				echo "<h4>Modifica i tuoi dati qui</h4>";
				$_formcf =  "<form class='form-pr' method='POST' action='".$_SERVER['PHP_SELF']."'>";
				$_formcf .= "<span class='reg-label'>Nome* </span><input type='text' name='nome' value='".$_SESSION['nome']."'></input><br>";
				$_formcf .= "<span class='reg-label'>Cognome* </span><input type='text' name='cognome' value='".$_SESSION['cognome']."'></input><br>";
				$_formcf .= "<span class='reg-label'>Indirizzo </span><input type='text' name='indirizzo' value='".$_SESSION['indirizzo']."'></input><br>";
				$_formcf .= "<span class='reg-label'>Ingaggio </span><input type='text' name='ingaggio' value='".$_SESSION['ingaggio']."'></input><br>";
				$_formcf .= "<span class='reg-label'>Ruolo pref </span><input type='text' name='ruoloPreferito' value='".$_SESSION['ruolo']."'></input><br>";
				$_formcf .= "<span class='reg-label'>Squadra </span><input type='text' name='squadra' value='".$_SESSION['squadra']."'></input><br>";
				$_formcf .= "<input type='submit'></input></form>";
				echo $_formcf;
			}
		?>
	</div>
	<div class="right-column">
		<div class="logger">
			<?php
				if(!isset($_SESSION['username'])) { //mostrare form login
					$logForm = '<form method="POST" action='.$_SERVER['PHP_SELF'].'>
								<h3 style="text-align:center">Login Form</h3>
								<input type="text" name="username" placeholder="nome utente"></input>
								<input type="text" name="password" placeholder="password"></input>
								<input type="submit" name="login"></input><br>
								Non sei iscritto? <a href="registration.php">registrati</a>
								</form>';
				}
				else{	// mostrare form logout
					$logForm = '<form method="POST" action='.$_SERVER['PHP_SELF'].'>
								<h3 style="text-align:center">Benvenuto '.$_SESSION['username'].'</h3>
								<a href="profile.php">Il tuo profilo</a>
								<input type="hidden" name="logout"></input><br>
								Logout<input type="submit" name="logout"></input><br>
								</form>';
				}
				echo $logForm;
			?>
		</div>
		<div class="next-matches">
			<?php
				nextMatches($con);
			?>
		</div>
	</div>
</body>
</html>
