<?php
/*
 * Preparing Connections to Super Manager's Databases
 * Author: Jinglei Ren <jinglei.ren.china@gmail.com>
 * Organization: Department of Computer Science & Technology, Tsinghua University
 * Create Date: 2010-4-12
 * Last Modified: 2010-5-22
 */

define('CLIENT_MULTI_RESULTS', 131072);
include(dirname(__FILE__) . "/smr_config.php");

/**
 * 建立与super manager数据库的连接
 * @return Connection to super manager's database
 */
function get_smr_db_conn() {
	global $smr_db_host, $smr_db_user, $smr_db_pwd, $smr_db_name;
	//set proper server name, user name and password for super manager's database
	$smr_db_conn = mysql_connect($smr_db_host, $smr_db_user, $smr_db_pwd, false, CLIENT_MULTI_RESULTS);
	if (!$smr_db_conn) return 'Connection failed to super manager\'s database: ' . mysql_error();
		
	//set proper database name for super manager
	mysql_select_db($smr_db_name, $smr_db_conn);
	
	return $smr_db_conn;
}

/**
 * 用于在数据库执行存储过程的函数
 * @param string $sp_name name of stored procedure to execute
 * @param $sp_args string arguments of stored procedure
 * @param $db_conn connection to the database owing target stored procedure
 * @return array|string result of execution or error message
 */
function call_stored_procedure($sp_name, $sp_args, $db_conn) {
	
	$query_str =  "call ". $sp_name . "(" . $sp_args . ");";
	$records = mysql_query($query_str, $db_conn);
	if (!$records) 
		return "Error in call_stored_procedure of " . $sp_name . ": " . mysql_error();
	
	$ret_array = array();
	while ($row = mysql_fetch_array($records, MYSQL_NUM)) {
		array_push($ret_array, $row);
	}
	return $ret_array;
}

?>