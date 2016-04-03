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
			<li><a href="profile.php">Il tuo profilo</a></li>
			<li><a href="inscribeteam.php">Iscrivi una squadra</a></li>
			<li><a href="calendar.php">Calendario partite</a></li>
			<li><a href="oldmatches.php">Scorse partite</a></li>
			<li><a href="addresult.php">Inserisci un risultato</a></li>
		</ul>
	</div>
	<div class="content">
		<?php 
			$reg_error = "";
			$registrationOk = false;
			if(isset($_POST['reg_username']) && isset($_POST['reg_password']) && isset($_POST['regpassword2']) ){
				if($_POST['reg_password'] != $_POST['regpassword2'])
					$reg_error = "Errore nella registrazione, le password non coincidono.";
				else{
					$_n = $con->query("SELECT count(*) AS numero FROM UTENTE WHERE username='".$_POST['reg_username']."'");
					$_n = $_n->fetch_assoc();
					if($_n['numero'] != 0)	//username non disponibile
						$reg_error = "Errore nella registrazione, username gia' usato.";
					else{
						if(!$con->query("INSERT INTO UTENTE VALUES('".$_POST['reg_username']."','".$_POST['reg_password']."',NULL)"))
							$reg_error = "Errore nella registrazione, qualcosa e' andato storto.";
						else{	//registrazione a buon fine
							$registrationOk = true;
							$reg_ok= "Registrazione avvenuta con successo, ora puoi effettuare il login!";
						}
					}
				} 
			}
			if(!$registrationOk){
				echo "<h4>".$reg_error."</h4>";
				$reg_form  = '<form class="registration-form" method="POST" action='.$_SERVER['PHP_SELF'].'><span class="reg-label">Username: </span><input type="text" name="reg_username" palceholder="username"></input><br>';
				$reg_form .= '<span class="reg-label">Password: </span><input type="text" name="reg_password" palceholder="username"></input><br><span class="reg-label">Repeat password: </span><input type="text" name="regpassword2" palceholder="username"></input><br>';
				$reg_form .= '<input type="submit"></input></form>';
				echo $reg_form;
			}
			else{
				echo $reg_ok;
			}
		?>
	</div>
	<div class="right-column">
		<div class="next-matches">
			<?php
				nextMatches($con);
			?>
		</div>
	</div>
</body>
</html>
