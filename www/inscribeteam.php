<?php 
	require_once('sessions.php'); 
	if( isset($_POST["nomesq"]) ){
		if(!$con->query("INSERT INTO SQUADRA VALUES('".$_POST['nomesq']."','".$_POST['societasq']."','".$_POST['indirizzoPal']."')")){
			$RESULTINSERT = "Errore, qualcosa e' andato storto durante l'inserimento.";
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
			if(!isset($_SESSION['username'])) { // errore, must login 
				$selectform = '<h3>Errore</h3><p>Devi effettuare il login per accedere a questa sezione</p>';
			}
			else{
				if (isset($RESULTINSERT)){
					echo "<h4>".$RESULTINSERT."</h4>";
				}
				$selectform  = "<h5>Inscrivi la tua squadra nel campionato!</h5>";
				$selectform .= "<p> N.B. E' possibile iscrivere la squadra soltanto prima del 15 settembre, oppure a fine campionato (dopo il 1 giugno)</p>";
				$selectform .= "<form class='addTeamForm' method='POST' action=".$_SERVER['PHP_SELF'].">";
				$selectform .= "<input type='text' name='nomesq' placeholder='Nome squadra'></input><br>";
				$selectform .= "<input type='text' name='societasq' placeholder='Societa' squadra></input><br>";
				$selectform .= "<input type='text' name='indirizzoPal' placeholder='Indirizzo palestra'></input><br>";
				$selectform .= "<br><button type='submit' value='execute' name='invia'>Invia</button></form>";
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
