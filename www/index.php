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
		<a class='a-header' href="index.php"></a>
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
		<table class="classifica-table">
			<tr>
				<th>Squadra</th>
				<th>Punteggio</th>
				<th>Partite</th>
				<th>Vinte</th>
				<th>Perse</th>
				<th>Set vinti</th>
				<th>Set persi</th>
			</tr>
		<?php
			$_classificaResult = $con->query("SELECT * FROM CLASSIFICA ORDER BY PUNTEGGIO DESC");
			while($row = $_classificaResult->fetch_assoc()){
				$squa=$row["squadra"];
				$punt=$row["punteggio"];
				$part=$row["pGiocate"];
				$vint=$row["pVinte"];
				$pers=$row["pPerse"];
				$setv=$row["setVinti"];
				$setp=$row["setPersi"];
				echo '  <tr>
						<td>'.$row["squadra"].'</td>
						<td>'.$row["punteggio"].'</td>
						<td>'.$row["pGiocate"].'</td>
						<td>'.$row["pVinte"].'</td>
						<td>'.$row["pPerse"].'</td>
						<td>'.$row["setVinti"].'</td>
						<td>'.$row["setPersi"].'</td>
					 	</tr>';
			}
		?>
		</table>
	</div>
	<div class="right-column">
		<div class="logger">
			<?php
				if(!isset($_SESSION['username'])) { //mostrare form login
					$logForm = '<form method="POST" action='.$_SERVER['PHP_SELF'].'>
								<h3 style="text-align:center">Login Form</h3>
								<input type="text" name="username" placeholder="nome utente"></input>
								<input type="password" name="password" placeholder="password"></input>
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
