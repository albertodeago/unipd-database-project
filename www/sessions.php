<?php

	//connect to database
	$servername = "localhost";
	$username = "adeagost";
	$password = "p4MDIFFO";

	$con=mysqli_connect($servername,$username,$password,"adeagost-PR");
	// Check connection
	if (mysqli_connect_errno()){
	 	echo "Failed to connect to MySQL: " . mysqli_connect_error();
	}
	session_start();
	//create and check if session is active
	if(!isset($_POST["logout"])){
		//session_start();
		if(/*session_id() == '' || !isset($_SESSION)*/ !isset($_SESSION['username']) ){
		    $_isLogged=false;
			$_isAdmin=false;
			$_isGiocatore=false;
			$_username;
			$_squadra;
			$_cf;
			if(isset($_POST['username']) && isset($_POST['password'])){
				if(!$con->query("call login('".$_POST['username']."','".$_POST['password']."',@logged,@admin,@giocatore,@un,@sq,@cf)")){
					echo "CALL failed: (" . $con->errno . ") " . $con->error;
				}
				else{	// provo il login
					$results = $con->query("SELECT @logged,@admin,@giocatore,@un,@sq,@cf");
					$login_results = $results->fetch_assoc();
					$_isAdmin = $login_results["@admin"];
					$_isLogged = $login_results["@logged"];
					$_isGiocatore = $login_results["@giocatore"];
					$_username = $login_results["@un"];
					$_squadra = $login_results["@sq"];
					$_cf = $login_results["@cf"];
					if($_isAdmin){
						//redirect to admin.php
						//oppure creare una sezione del sito apposta?
						$_SESSION["username"] = $_POST['username'];
						//echo "admin <br>";
						Redirect('administration.php', false);
					}
					if($_isLogged==true){
						// inizio una sessione
						session_start();
						//echo "<br> session started";
						$_SESSION["username"] = $_username;
						$_SESSION["isGiocatore"] = $_isGiocatore;
						if($_isGiocatore){
							$tmp = $con->query("SELECT * FROM GIOCATORE WHERE CF='".$_cf."'");
							$tmp = $tmp->fetch_assoc();
							$_SESSION['cf'] = $_cf;
							$_SESSION['squadra'] = $tmp['squadra'];
							$_SESSION['nome'] = $tmp['nome'];
							$_SESSION['cognome'] = $tmp['cognome'];
							$_SESSION['indirizzo'] = $tmp['indirizzo'];
							$_SESSION['ingaggio'] = $tmp['ingaggio'];
							$_SESSION['ruolo'] = $tmp['ruoloPreferito'];
						}
					}
					//print_r($_SESSION);					
				}
			}
		}
		else{
			//echo "session is setup";
			//print_r($_SESSION);
		}
	}
	else{
		$_SESSION = array();
		session_destroy();
		Redirect("index.php");
	}

function Redirect($url, $permanent = false){
    if (headers_sent() === false){
    	header('Location: ' . $url, true, ($permanent === true) ? 301 : 302);
    }
    exit();
}

function nextMatches($con){
	echo "<h3>Prossime partite</h3>";
	$_teams = array();
	$_teamsRes = $con->query("SELECT nome FROM SQUADRA");
	while($row = $_teamsRes->fetch_assoc()){
		$_teams[$row['nome']]=1; 	//metto il nome di tutte le squadre qui
	}
	foreach($_teams as $teamname => $doIt){
		if($_teams[$teamname]){
			$_res = $con->query("SELECT data,locali,ospiti FROM PARTITADAGIOCARE WHERE (locali='".$teamname."' OR ospiti='".$teamname."') AND data=(SELECT MIN(data) FROM PARTITADAGIOCARE WHERE locali='".$teamname."' OR ospiti='".$teamname."')");
			$_tmp=$_res->fetch_assoc();
			if($_tmp['locali']==$teamname)
				$_teams[$_tmp['ospiti']] = 0;
			else
				$_teams[$_tmp['locali']] = 0;
			echo $_tmp['data']." ".$_tmp['locali']." ".$_tmp['ospiti']."<br>";
		}
	}
}
?>