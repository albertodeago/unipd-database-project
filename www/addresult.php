<?php 
	require_once('sessions.php'); 
	if(isset($_POST["partita"]) && isset($_POST["locali"]) && isset($_POST["ospiti"])){
		$_dati = explode('+',$_POST["partita"]);
		//echo "<br>'".$_dati[0]."','".$_dati[1]."','".$_dati[2]."',".$_POST["locali"].",".$_POST["ospiti"];
		if(!$con->query("CALL chiudiPartita('".$_dati[0]."','".$_dati[1]."','".$_dati[2]."',".$_POST["locali"].",".$_POST["ospiti"].")")){
			$RESULTINSERT = "Errore, qualcosa e' andato storto durante l'inserimento, forse non era valido il punteggio inserito!";
		}
		else{
			$RESULTINSERT = "Inserimento riuscito!";
		}

	}
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
			if((!isset($_SESSION['username']) || !isset($_SESSION['cf']) || is_null($_SESSION['username']))) { // errore, must login 
				$selectform = '<h3>Errore</h3><p>Devi effettuare il login ed essere un giocatore del campionato per accedere a questa sezione</p>';
			}
			else{
				if (isset($RESULTINSERT)){
					echo "<h4>".$RESULTINSERT."</h4>";
				}
				//echo $_SESSION["squadra"]."<br>";
				$_partiteSquadra = $con->query("SELECT * FROM PARTITADAGIOCARE WHERE (locali='".$_SESSION["squadra"]."' OR ospiti='".$_SESSION["squadra"]."') ORDER BY data");
				if($_partiteSquadra->num_rows == 0){
					$selectform = "Non ci sono partite da chiudere per la tua squadra!";
				}
				else{
					$selectform = "<form class='addResultForm' method='POST' action=".$_SERVER['PHP_SELF']."><select class='matches-select' name='partita'>";
					while($row = $_partiteSquadra->fetch_assoc()){
						/*echo $row['locali'].$row['ospiti'].$row['data'];*/
						$value = $row["locali"]."+".$row["ospiti"]."+".$row["data"];
						$_locali = $row["locali"];
						$_ospiti = $row["ospiti"];
						$selectform .= "<option value='".$value."'>".$row['locali']." - ".$row['ospiti']." del ".$row['data']."</option>";
					}
					$selectform .= "</select><br>";
					$selectform .= "Locali <select class='locali-select' name='locali'>";
					$selectform .= "<option>0</option><option>1</option><option>2</option><option>3</option></select>";
					$selectform .= "Ospiti <select class='ospiti-select' name='ospiti'>";
					$selectform .= "<option>0</option><option>1</option><option>2</option><option>3</option></select>";
					$selectform .= "<br><button type='submit' value='execute' name='invia'>Invia</button></form>";
				}
			}
			echo $selectform;

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
