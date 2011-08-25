<?php

/*
 * Local Manager's Remote Services for Corsair
 * Author: Jinglei Ren <jinglei.ren.china@gmail.com>
 * Create Date: 2010-4-20
 * Last Modified: 2010-5-2
 */

include_once dirname(__FILE__) . "/phprpc/phprpc_server.php";
include_once dirname(__FILE__) . "/phprpc/phprpc_client.php";
include_once dirname(__FILE__) . "/lmr_rs_db.php";

$server = new PHPRPC_SERVER();
$smr_rs = new PHPRPC_Client($smr_rs);

/*
 * 验证短信中心身份
 * Parameters:
 *   $name - name of message center
 *   $pwd - password of message center
 */
function check_message_center($name, $pwd) {
	global $sms_centers;
	foreach($sms_centers as $center) {
		if ($center[0] == $name and $center[1] == $pwd)
			return true;
	};
	return false;
}
$server->add("check_message_center");

/*
 * 通过用户手机号获得其加入的所有社区名称和代号
 * Returns:
 *   array of all required communities' names and aliases
 *   string of error message if failed
 */
function fetch_commu_by_phone($user_phone) {
	global $smr_rs;
	$err_code = 0;
	
	// query to local manager
	$lmr_db = get_lmr_db_conn();
	if (is_string($lmr_db)) $err_code += 1;
	else {
		$sp_args = '"' . $user_phone . '"';
		$lmr_list = call_stored_procedure("sp_fetch_commu_by_phone", $sp_args, $lmr_db);
		if (is_string($lmr_list)) $err_code += 1;
		else if (!$lmr_list) $lmr_list = array(); 
	}

	// query to super manager
	$smr_list = $smr_rs->fetch_inter_commu_by_phone($user_phone);
	if (is_string($smr_list) || $smr_list instanceof PHPRPC_Error) $err_code += 2;
	else if (!$smr_list) $smr_list = array();
	
	if ($err_code == 0) return array_merge($lmr_list, $smr_list);
	else if ($err_code == 1) return $smr_list;
	else if ($err_code == 2) return $lmr_list;
	else return "Query failed in fetch_commu_by_phone";
}
// register the above function
$server->add("fetch_commu_by_phone");

/**
 * 通过社区代号获得其本地成员手机号，通常为中间件所调用
 * @param string $commu_alias alias of target local community
 * @return array|string phone number list or error message
 */
function fetch_commu_local_phone_list($commu_alias) {
	$lmr_db = get_lmr_db_conn();
	if (is_string($lmr_db)) 
		return "Database connection failed in fetch_commu_local_phone_list: " . $lmr_db;
	
	$sp_args = '"' . $commu_alias . '"';
	$lmr_list = call_stored_procedure("sp_fetch_commu_phone_list", $sp_args, $lmr_db);
	
	if (is_string($lmr_list)) 
		return "Query failed in fetch_commu_local_phone_list: " . $lmr_list;
	
	return $lmr_list ? $lmr_list : array();
}
// register the above function
$server->add("fetch_commu_local_phone_list");

/**
 * 通过社区URI获得其所有成员手机号，通常为用户所调用
 * @param string $commu_uri URI of target community
 * @return array|string phone number list or error message
 */
function fetch_commu_phone_list($commu_uri) {
	global $smr_rs;
	
	// parse the uri
	$uri_info = parse_uri($commu_uri);
	if ($uri_info['is_local']) $commu_alias = $uri_info['alias'];
	else return $smr_rs->fetch_sms_number($uri_info['namespace']);
	
	$err_code = 0;
	
	// query to local manager
	$lmr_list = fetch_commu_local_phone_list($commu_alias);
	if (is_string($lmr_list)) $err_code += 1;

	// query to super manager
	$smr_list = $smr_rs->fetch_commu_xtnl_phone_list($uri_info['namespace'], $commu_alias);
	if (is_string($smr_list) || $smr_list instanceof PHPRPC_Error) $err_code += 2;
	else if (!$smr_list) $smr_list = array();
	
	if ($err_code == 0) return array_merge($lmr_list, $smr_list);
	else if ($err_code == 1) return $smr_list;
	else if ($err_code == 2) return $lmr_list;
	else return "Query failed in fetch_commu_phone_list";
}
// register the above function
$server->add("fetch_commu_phone_list");

/**
 * 通过用户手机号获得其拥有的所有通讯组名称和代号
 * @param string $user_phone phone number of target user
 * @return array|string all owned groups' names and aliases or error message
 */
function fetch_grp_by_phone($user_phone) {
	global $smr_rs;
	$err_code = 0;
	
	// query to local manager
	$lmr_db = get_lmr_db_conn();
	if (is_string($lmr_db)) $err_code += 1;
	else {
		$sp_args = '"' . $user_phone . '"';
		$lmr_list = call_stored_procedure("sp_fetch_grp_by_phone", $sp_args, $lmr_db);
		if (is_string($lmr_list)) $err_code += 1;
		else if (!$lmr_list) $lmr_list = array(); 
	}

	// query to super manager
	$smr_list = $smr_rs->fetch_global_grp_by_phone($user_phone);
	if (is_string($smr_list) || $smr_list instanceof PHPRPC_Error) $err_code += 2;
	else if (!$smr_list) $smr_list = array();
	
	if ($err_code == 0) return array_merge($lmr_list, $smr_list);
	else if ($err_code == 1) return $smr_list;
	else if ($err_code == 2) return $lmr_list;
	else return "Query failed in fetch_grp_by_phone";
}
// register the above function
$server->add("fetch_grp_by_phone");


/**
 * 通过通讯组代号获得其所有本地成员手机号
 * @param string $grp_alias alias of target group
 * @return array|string phone number list or error message
 */
function fetch_grp_local_phone_list($grp_alias) {
	$lmr_db = get_lmr_db_conn();
	if (is_string($lmr_db)) 
		return "Database connection failed in fetch_grp_local_phone_list: " . $lmr_db;
	
	$sp_args = '"' . $grp_alias . '"';
	$lmr_list = call_stored_procedure("sp_fetch_grp_phone_list", $sp_args, $lmr_db);
	if (is_string($lmr_list)) 
		return "Query failed in fetch_grp_local_phone_list";
		
	return $lmr_list ? $lmr_list : array();
}
// register the above function
$server->add("fetch_grp_local_phone_list");

/**
 * 通过通讯组的代号获得其包含的所有外校社区/通讯组对应的短信中心号码和代码（不带命名空间）
 * @param string $grp_alias alias of target group
 * @return array|string 
 *   required phone number list with community/group names on success,
 *   or error message on failure
 */
function fetch_grp_forward_sms_list($grp_alias) {
	global $smr_rs, $namespace;
	$err_code = 0;
	
	$xtnl_list = $smr_rs->fetch_grp_xtnl_sms_list($namespace, $grp_alias);
	if (is_string($xtnl_list) || $xtnl_list instanceof PHPRPC_Error) $err_code += 1;
	else if (!$xtnl_list) $xtnl_list = array(); 

	$glbl_list = $smr_rs->fetch_global_grp_sms_list($grp_alias);
	if (is_string($glbl_list) || $glbl_list instanceof PHPRPC_Error) $err_code += 2;
	else if (!$glbl_list) $glbl_list = array();
	
	if ($err_code == 0) return array_merge($xtnl_list, $glbl_list);
	else if ($err_code == 1) return $glbl_list;
	else if ($err_code == 2) return $xtnl_list;
	else return "Query failed in fetch_grp_by_phone";
	
}
$server->add("fetch_grp_forward_sms_list");

$server->start();

/**
 * 解析社区/通讯组代号的命名空间
 * @param string $uri uri of community/group
 * @return array
 *   'count' -> number of parts in uri
 *   'is_local' -> whether uri refers to local resource
 *   'alias' -> alias of target resource
 *   'namespace' -> top namespace in uri
 */
function parse_uri($uri) {
	global $namespace;
	$uri_info = explode(".", $uri);
	$uri_info['count'] = count($uri_info);
	$uri_info['alias'] = $uri_info[0];
	if ($uri_info['count'] == 1) {
		$uri_info['is_local'] = true;
		$uri_info['namespace'] = $namespace;
	} else {
		$uri_info['namespace'] = $uri_info[$uri_info['count'] - 1];
		if ($uri_info['namespace'] == $namespace)
			$uri_info['is_local'] = true;
		else $uri_info['is_local'] = false;
	}
	return $uri_info;
}

?>