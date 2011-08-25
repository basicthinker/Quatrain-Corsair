<?php

/*
 * Super Manager's Remote Services for Corsair
 * Author: Jinglei Ren <jinglei.ren.china@gmail.com>
 * Organization: Department of Computer Science & Technology, Tsinghua University
 * Create Date: 2010-4-29
 * Last Modified: 2010-5-21
 */

include(dirname(__FILE__) . "/phprpc/phprpc_server.php");
include(dirname(__FILE__) . "/smr_rs_db.php");
$server = new PHPRPC_SERVER();

/**
 * 判断用户邮箱是否在指定的校际社区的邮箱列表中
 * @param string $user_email target email to check
 * @param string $commu_email email of the community who owns the target mailing list
 * @return int|string
 *   0 - the user email is not on the target mailing list
 *   1 - the user email is on the target mailing list
 *   or error message
 */
function check_email_in_commu_list($user_email, $commu_email) {
	$db_conn = get_smr_db_conn();
	if (is_string($db_conn))
		"Database connection failed in check_email_in_commu_list: " . $db_conn;
	
	$str_args = '"' . $user_email . '", "' . $commu_email . '"';
	$ret_tbl = call_stored_procedure("sp_check_email_in_commu_list", $str_args, $db_conn);
	if (is_string($ret_tbl))
		return "Query failed in check_email_in_commu_list: " . $ret_tbl;
	else return (int)$ret_tbl[0][0];
}
$server->add("check_email_in_commu_list");

/**
 * 通过指定校际社区邮箱获得该社区所有外校用户邮箱地址
 * @param string $commu_email email of target community
 * @return array|string all required emails or error message
 */
function fetch_commu_xtnl_mailing_list($commu_email) {
	$db_conn = get_smr_db_conn();
	if (is_string($db_conn))
		"Database connection failed in fetch_commu_xtnl_mailing_list: " . $db_conn;
	
	$str_args = '"' . $commu_email . '"';
	$list = call_stored_procedure("sp_fetch_commu_xtnl_mailing_list", $str_args, $db_conn);
	if (is_string($list))
		return "Query failed in fetch_commu_xtnl_mailing_list: " . $list;
	
	return $list ? $list : array();
}
$server->add("fetch_commu_xtnl_mailing_list");

/**
 * 通过校际通讯组的邮箱获得其包含的校外社区的邮箱
 * @param string $grp_email email of target group
 * @return array|string
 *   required communities' emails on success,
 *   or error message on failure
 */
function fetch_grp_xtnl_commu_email($grp_email) {
	$db_conn = get_smr_db_conn();
	if (is_string($db_conn))
		"Database connection failed in fetch_grp_xtnl_commu_email: " . $db_conn;
	
	$str_args = '"' . $grp_email . '"';
	$list = call_stored_procedure("sp_fetch_grp_xtnl_commu_email", $str_args, $db_conn);
	if (is_string($list))
		return "Query failed in fetch_grp_xtnl_commu_email: " . $list;
	
	return $list ? $list : array();
}
$server->add("fetch_grp_xtnl_commu_email");

/**
 * 通过全局通讯组的邮箱获得其包含的校际通讯组的邮箱
 * @param string $grp_email email of target global group
 * @return array|string 
 *   required groups' emails on success,
 *   or error message on failure
 */
function fetch_global_grp_mailing_list($grp_email) {
	$db_conn = get_smr_db_conn();
	if (is_string($db_conn))
		"Database connection failed in fetch_global_grp_mailing_list: " . $db_conn;
	
	$str_args = '"' . $grp_email . '"';
	$list = call_stored_procedure("sp_fetch_global_grp_mailing_list", $str_args, $db_conn);
	if (is_string($list))
		return "Query failed in fetch_global_grp_mailing_list: " . $list;
	
	return $list ? $list : array();
}
$server->add("fetch_global_grp_mailing_list");

/**
 * 通过用户手机号获得其加入的所有外校社区名称和URI
 * @param string $user_phone phone number of target user
 * @return array|string 
 *   required communities' names and URIs on success,
 *   or error message on failure
 */
function fetch_inter_commu_by_phone($user_phone) {
	$db_conn = get_smr_db_conn();
	if (is_string($db_conn))
		"Database connection failed in fetch_inter_commu_by_phone: " . $db_conn;
	
	$str_args = '"' . $user_phone . '"';
	$list = call_stored_procedure("sp_fetch_inter_commu_by_phone", $str_args, $db_conn);
	if (is_string($list))
		return "Query failed in fetch_inter_commu_by_phone: " . $list;
	
	return $list ? $list : array();
}
$server->add("fetch_inter_commu_by_phone");

/**
 * 通过校际社区代号获得其所有外校成员手机号
 * @param string $namespace namespace of target local manager
 * @param string $commu_alias alias of target community
 * @return array|string phone number list or error message
 */
function fetch_commu_xtnl_phone_list($namespace, $commu_alias) {
	$db_conn = get_smr_db_conn();
	if (is_string($db_conn))
		"Database connection failed in fetch_commu_xtnl_phone_list: " . $db_conn;
	
	$str_args = '"' . $namespace . '", "' . $commu_alias . '"';
	$list = call_stored_procedure("sp_fetch_commu_xtnl_phone_list", $str_args, $db_conn);
	if (is_string($list))
		return "Query failed in fetch_commu_xtnl_phone_list: " . $list;
	
	return $list ? $list : array();
}
$server->add("fetch_commu_xtnl_phone_list");

/**
 * 通过用户手机号获得其拥有的所有全局通讯组名称和代号
 * @param string $user_phone phone number of target user
 * @return array|string 
 *   required groups' names and aliases on success,
 *   or error message on failure
 */
function fetch_global_grp_by_phone($user_phone) {
	$db_conn = get_smr_db_conn();
	if (is_string($db_conn))
		"Database connection failed in fetch_global_grp_by_phone: " . $db_conn;
	
	$str_args = '"' . $user_phone . '"';
	$list = call_stored_procedure("sp_fetch_global_grp_by_phone", $str_args, $db_conn);
	if (is_string($list))
		return "Query failed in fetch_global_grp_by_phone: " . $list;
	
	return $list ? $list : array();
}
$server->add("fetch_global_grp_by_phone");

/**
 * 通过校际通讯组命名空间和代号获得其包含的校外社区对应的短信中心号码和代号
 * @param string $namespace namespace of target group
 * @param string $grp_alias alias of target group
 * @return array|string
 *   required groups' sms numbers and aliases on success,
 *   or error message on failure
 */
function fetch_grp_xtnl_sms_list($namespace, $grp_alias) {
	$db_conn = get_smr_db_conn();
	if (is_string($db_conn))
		"Database connection failed in fetch_grp_xtnl_sms_list: " . $db_conn;
	
	$str_args = '"' . $namespace . '", "' . $grp_alias . '"';
	$list = call_stored_procedure("sp_fetch_grp_xtnl_sms_list", $str_args, $db_conn);
	if (is_string($list))
		return "Query failed in fetch_grp_xtnl_sms_list: " . $list;
	
	return $list ? $list : array();
}
$server->add("fetch_grp_xtnl_sms_list");

/**
 * 通过全局通讯组获得其拥有的校际通讯组对应的短信中心号码和代号
 * @param string $user_phone phone number of target user
 * @return array|string 
 *   required sms number(s) and alias(es) on success,
 *   or error message on failure
 */
function fetch_global_grp_sms_list($grp_alias) {
	$db_conn = get_smr_db_conn();
	if (is_string($db_conn))
		"Database connection failed in fetch_global_grp_sms_list: " . $db_conn;
	
	$str_args = '"' . $grp_alias . '"';
	$list = call_stored_procedure("sp_fetch_global_grp_sms_list", $str_args, $db_conn);
	if (is_string($list))
		return "Query failed in fetch_global_grp_sms_list: " . $list;
	
	return $list ? $list : array();
}
$server->add("fetch_global_grp_sms_list");

/**
 * 通过命名空间获得其短信中心号码
 * @param string $namespace namespace of target local manager
 * @return array|string
 *   required sms number on success,
 *   or error message on failure
 */
function fetch_sms_number($namespace) {
	$db_conn = get_smr_db_conn();
	if (is_string($db_conn))
		"Database connection failed in fetch_sms_number: " . $db_conn;
	
	$str_args = '"' . $namespace . '"';
	$ret_tbl = call_stored_procedure("sp_fetch_sms_number", $str_args, $db_conn);
	if (is_string($ret_tbl))
		return "Query failed in fetch_sms_number: " . $ret_tbl;
	
	return $ret_tbl ? $ret_tbl : array();
}
$server->add("fetch_sms_number");

$server->start();

?>