<?php
/*
 * Example Code to Enjoy Corsair Remote Services for SMS Component
 * Author: Jinglei Ren <jinglei.ren.china@gmail.com>
 * Create Date: 2010-4-20
 * Last Modified: 2010-4-20
 */

include (dirname(__FILE__) . "/config.php");
include (dirname(__FILE__) . "/phprpc/phprpc_client.php");
$rs_phone = new PHPRPC_Client($rs_phone_loc);

// 验证短信中心的身份
echo "call check_message_center:" . "<br />";
$is_pass = $rs_phone->check_message_center("basicthinker", "basicthinking");
if (is_string($is_pass)) echo "Error: " . $is_pass . "<br />";
else if ($is_pass == 1) echo "True<br />";
else echo "False<br />";
echo "<br />";

// 通过用户手机号查询其所在社区的名称和代号
echo "call fetch_commu_by_phone:" . "<br />";
$list = $rs_phone->fetch_commu_by_phone("5556");
if (is_string($list)) echo "Error: " . $list . "<br />";
else foreach ($list as $commu) {
	echo $commu[0] . ": " . $commu[1] . "<br />";
}
echo "<br />";

// 通过社区代号获得其所有用户的手机号
echo "fetch_commu_phone_list:" . "<br />";
$list = $rs_phone->fetch_commu_phone_list("lf0k.thu");
if (is_string($list)) echo "Error: " . $list . "<br />";
else foreach ($list as $row) {
	echo $row[0] . "<br />";
}
echo "<br />";

// 通过用户手机号查询其拥有的通讯组名称和代号
echo "call fetch_grp_by_phone:" . "<br />";
$list = $rs_phone->fetch_grp_by_phone("5556");
if (is_string($list)) echo "Error: " . $list . "<br />";
else foreach ($list as $commu) {
	echo $commu[0] . ": " . $commu[1] . "<br />";
}
echo "<br />";

// 通过通讯组代号获得其所有本地成员手机号
echo "fetch_grp_local_phone_list:" . "<br />";
$list = $rs_phone->fetch_grp_local_phone_list("15d4");
if (is_string($list)) echo "Error: " . $list . "<br />";
else foreach ($list as $row) {
	echo $row[0] . "<br />";
}
echo "<br />";

// 通过通讯组的代号获得其包含的所有外校社区/通讯组对应的短信中心号码和代码（不带命名空间）
echo "fetch_grp_forward_sms_list:" . "<br />";
//$list = $rs_phone->fetch_grp_forward_sms_list("15d4");
$list = $rs_phone->fetch_grp_forward_sms_list("stgiw");
if (is_string($list)) echo "Error: " . $list . "<br />";
else foreach ($list as $row) {
	echo $row[0] . ": " . $row[1] . "<br />";
}
echo "<br />";

?>