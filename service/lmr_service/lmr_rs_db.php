<?php
/*
 * Preparing Connections to Local Manager's Databases
 * Author: Jinglei Ren <jinglei.ren.china@gmail.com>
 * Organization: Department of Computer Science & Technology, Tsinghua University
 * Create Date: 2010-4-12
 * Last Modified: 2010-5-22
 */

define('CLIENT_MULTI_RESULTS', 131072);
include_once dirname(__FILE__) . "/lmr_config.php";

/**
 * 建立与local manager数据库的连接
 * @return Connection to local manager's database
 */
function get_lmr_db_conn() {
	global $lmr_db_host, $lmr_db_user, $lmr_db_pwd, $lmr_db_name;
	//set proper server name, user name and password for local manager's database
	$lmr_db_conn = mysql_connect($lmr_db_host, $lmr_db_user, $lmr_db_pwd, false, CLIENT_MULTI_RESULTS);
	if (!$lmr_db_conn) return "Connection failed to local manager's database: " . mysql_error();
		
	//set proper database name for local manager
	mysql_select_db($lmr_db_name, $lmr_db_conn);
	
	return $lmr_db_conn;
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