<html>
    <head>
        <title>Submitted Items Statistics</title>
    </head>
    <body>
        <h3>Submitted Items Statistics</h3>
        <br />
        <table border="1">
			<tr><td>Item</td><td>Count</td></tr>
			
<?php
	// CONNECTION INFORMATION START 

	// CONNECTION INFORMATION END

	if( $conn === false ) {
	     die( print_r( sqlsrv_errors(), true));
	}

	$stmt = sqlsrv_query( $conn, "SELECT SubmittedName, COUNT(*) SubmittedCnt FROM SubmittedItems GROUP BY SubmittedName ORDER BY 2 DESC");

	if( $stmt === false ) {
	     die( print_r( sqlsrv_errors(), true));
	}
	
	while( $row = sqlsrv_fetch_array( $stmt, SQLSRV_FETCH_ASSOC) ) {
		 print "<tr><td>".$row['SubmittedName']."</td><td>".$row['SubmittedCnt']."</td></tr>\n";
	}
?>

	    </table>
        <br /><br /><br />
        Running on <b><?php echo gethostname(); ?></b>
		<hr>
		Powered by <b>Azure App Service (Web App)</b>
    </body>
</html>