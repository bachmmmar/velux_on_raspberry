<?php


// get the current file name
$this_file =  basename($_SERVER["SCRIPT_FILENAME"], '.php') . ".php";

// create device array
// "Device Name", "Device identifier", "Number of Steps"
$device_array = array
	   (
	   array("All Windows", "window_all", 1),
	   array("Window North", "window_north", 2),
	   array("Window South", "window_south", 0)
	   );

// create the action array
$action_array = array("open", "close");


/*************************************************************
 * Function Definition                                       *
 ************************************************************/
function printInfo() {
	global $device_array, $action_array, $this_file;
        echo "<h2>Welcome on the Raspberry Velux Remote Control homepage</h2>";
        echo "The following devices and actions are available:";
        echo "<ul>";
	
	for ($dev = 0; $dev < sizeof($device_array); $dev++) {
 	   for ($act = 0; $act < sizeof($action_array); $act++) {
		$text = $this_file . "?device=" . $device_array[$dev][1] . "&action=" . $action_array[$act];
	   	echo "  <li><b>" . $device_array[$dev][0]. "->" . $action_array[$act] . ": </b><a href='" . $text . "'>" . $text . "</a></li>";
	   }
	}

	echo "</ul><br>";
}

function write_log($logline) {
	 $myFile = "remote_log.txt";
	 $fh = fopen($myFile, 'a') or die("can't open file");
	 fwrite($fh, $logline);
	 fclose($fh);
}

/*************************************************************
 * Check input parameter                                     *
 ************************************************************/

if (!isset($_GET["action"]) || !isset($_GET["device"])){
   printInfo();

   echo "<p> No Parameter found!</p>";
   exit();
}

// get parameters
$action = htmlspecialchars($_GET["action"]);
$device = htmlspecialchars($_GET["device"]);

// check action
$valid_action = False;
for ($act = 0; $act < sizeof($action_array); $act++) {
    if (strcmp($action, $action_array[$act]) == 0){
       // string match
       $valid_action = True;
    }
}

// check device
$valid_device = False;
$nr_of_changes = 0;
$device_name = "";
for ($dev = 0; $dev < sizeof($device_array); $dev++) {
    if (strcmp($device, $device_array[$dev][1]) == 0){
       // string match
       $valid_device = True;
       $nr_of_changes = $device_array[$dev][2];
       $device_name = $device_array[$dev][0];
    }
}


// decide if everything is valid
if ($valid_device && $valid_action){
   // everything valid
   echo "Everything Valid. Sending:<br>";

   $date_str = date('Y-m-d H:i:s');
   write_log($date_str . " - " . $device_name . " - " . $action . "\n");

   $exec_cmd = getcwd() . "/access_remote.sh " . $action . " " . $nr_of_changes . " > /dev/null &";
   echo $exec_cmd;
   exec($exec_cmd);
}
else{
   // not all parameters are valid
   printInfo();
   
   if($valid_device==False){
	 echo "<p> Invalid device Parameter found!</p>";
   }

   if($valid_action==False){
	 echo "<p> Invalid action Parameter found!</p>";
   }

}

?>