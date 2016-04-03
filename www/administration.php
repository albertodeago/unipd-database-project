<?php 
	require_once('sessions.php');

	if($_SESSION['username'] != 'admin'){	//solo admin puo' entrare in questa pagina
		Redirect("index.php");
	}

	$msg = "";
	if(isset($_POST['usernameDel'])){
		if($_POST['usernameDel'] == 'admin'){
			$msg = "Non puoi eliminare l'utente admin!";
		}
		else{				
			if(!$con->query("DELETE FROM UTENTE WHERE username='".$_POST['usernameDel']."'")){
				$msg = "Errore durante l'esecuzione della query.";
			}	
			else{
				$msg = "Query eseguita con successo!";
			}
		}
	}
	$msg1 = "";
	$result = false;
	if( isset($_POST['query']) ){
		//echo $_POST['query']."<br>";				
		$result = $con->query($_POST['query']);
		if(!$result){
			$msg1 = "Errore durante l'esecuzione della query.";
		}	
		else{
			$msg1 = "Query eseguita con successo! Output qui sotto:";
		}
	}
	if( isset ($_POST['iniziaCampionato']) ){
		creaCampionato($con);
	}
	// creaCampionato crea tutte le partite dell'andata e del ritorno automaticamente (e random)
	// sarebbe quindi una funzione da chiamare al termine delle iscrizioni per creare tutti gli abbinamenti
	// e resettare la classifica!
	function creaCampionato($con){
		$squadre=array();
		$_teamsRes = $con->query("SELECT nome FROM SQUADRA ORDER BY RAND()");
		while($row = $_teamsRes->fetch_assoc()){
			array_push($squadre, $row["nome"]);
		}
		//var_dump($squadre);
		$lastDate = partite($squadre, $con, true, date('Y-m-d', time() ));
		//echo "last date is: ".$lastDate;
		partite($squadre, $con, false, $lastDate);
	}

	function partite($squadre, $con, $andata, $s_date) {
		for ($i = 0; $i < count($squadre)/2; $i++) {
			if($andata){
				$casa[$i] = $squadre[$i]; 
				$trasferta[$i] = $squadre[count($squadre) - 1 - $i]; 
			}
			else{
				$trasferta[$i] = $squadre[$i]; 
				$casa[$i] = $squadre[count($squadre) - 1 - $i]; 
			}
		}
		//echo "<br>starting date is: ".$s_date; 
		$e_date = date('Y-m-d', strtotime($s_date.'+7 days'));
		//echo randomDate($s_date, $e_date);
		for ($i = 0; $i < count($squadre) - 1; $i++) {
			//echo "<h3>Giornata ".($i + 1)." </h3>";
			//echo $s_date." ".$e_date."<br>";
			if (($i % 2) == 0) {
					for ($j = 0; $j < count($squadre)/2; $j++) {
					//echo $trasferta[$j]." - ".$casa[$j]." il ".randomDate($s_date, $e_date)."<br>";
					$con->query("CALL creaPartita('".$trasferta[$j]."','".$casa[$j]."','".randomDate($s_date, $e_date)."')");
				}
			}
			else {
				for ($j = 0; $j < count($squadre)/2; $j++) {
					//echo $casa[$j]." - ".$trasferta[$j]." il ".randomDate($s_date, $e_date)."<br>";
					$con->query("CALL creaPartita('".$casa[$j]."','".$trasferta[$j]."','".randomDate($s_date, $e_date)."')");
				}
			}
			$tmp = $casa[0];
			array_unshift($trasferta, $casa[1]);
			$riporto = array_pop($trasferta);
			array_shift($casa);
			array_push($casa, $riporto);
			$casa[0] = $tmp ;
			$s_date = date('Y-m-d', strtotime($s_date."+ 7 days"));
			$e_date = date('Y-m-d', strtotime($e_date."+ 7 days"));
		}
		return $e_date;
	}

	// Find a randomDate between $start_date and $end_date
	function randomDate($start_date, $end_date)
	{
	    // Convert to timetamps
	    $min = strtotime($start_date);
	    $max = strtotime($end_date);

	    // Generate random number using above bounds
	    $val = rand($min, $max);

	    // Convert back to desired date format
	    return date('Y-m-d', $val);
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
	<div class="content-admin">
		<p><?php echo $msg; ?></p>
		<h3 style='text-align:center'>Pagina di amministrazione</h3>
		<br>
		<form method="POST" action=<?php $_SERVER['PHP_SELF'] ?>>
			<h3>Elimina utente da username</h3>
			<input type="text" name="usernameDel" placeholder="nome utente"></input>
			<input type="submit" name="delete"></input><br>
		</form>
		<br><br>
		<p><?php echo $msg1 ?></p>
		<?php 
			if($result){
				while($row = $result->fetch_assoc()){
					foreach($row as $cname => $cvalue){
				    	echo "<span style='font-weight:bold'>$cname</span>: $cvalue";
				    }
				    echo "<br>";
				}
			}
		?>
		<form method="POST" action=<?php $_SERVER['PHP_SELF'] ?>>
			<h3>Qui puoi eseguire query qualsiasi sul database</h3>
			<textarea name="query" row='10' column='40' placeholder="testo qui"></textarea><br>
			<input type="submit" ></input><br>
		</form>
		<br><br>
		<form method="POST" action=<?php $_SERVER['PHP_SELF'] ?>>
			<input type='hidden' name='iniziaCampionato'></input>
			<input type="submit" name="iniziaCampionato" value='Crea tutte le partite'></input><br>
		</form>

	</div>
	<div class="right-column">
		<div class="logger">
			<?php
				if(!isset($_SESSION['username'])) { 	//mostrare form login
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
								<input type="hidden" name="logout"></input><br>
								<input type="submit" name="logout">Logout</input><br>
								</form>';
				}
				echo $logForm;
			?>
		</div>
	</div>
</body>
</html>
