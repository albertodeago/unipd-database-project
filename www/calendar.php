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
		<table class="partite-table">
			<tr>
				<th>Data</th>
				<th>Locali</th>
				<th>Ospiti</th>
				<th>Palestra</th>
				<th>Arbitro</th>
			</tr>
		<?php
			$_partitedaGiocare = $con->query("SELECT * FROM PARTITADAGIOCARE ORDER BY data ASC");
			while($row = $_partitedaGiocare->fetch_assoc()){
				$_tmp = $con->query("SELECT nome,cognome FROM ARBITRO WHERE CF='".$row["arbitro"]."'");
				$_tmp2 = $_tmp->fetch_assoc();
				$nom_cog = $_tmp2["nome"]." ".$_tmp2["cognome"];
				echo '  <tr>
						<td>'.$row["data"].'</td>
						<td>'.$row["locali"].'</td>
						<td>'.$row["ospiti"].'</td>
						<td>'.$row["palestra"].'</td>
						<td>'.$nom_cog.'</td>
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
