<?php 
/*
 * Example Code to Enjoy Corsair Remote Services for Email Component
 * Author: Jinglei Ren <jinglei.ren.china@gmail.com>
 * Create Date: 2010-4-12
 * Last Modified: 2010-4-20
 */

include (dirname(__FILE__) . "/config.php");
include (dirname(__FILE__) . "/phprpc/phprpc_client.php");
$rs_email = new PHPRPC_Client($rs_email_loc);

/* invoke all remote interfaces */

// 打印所有本地社区的邮箱
echo "call fetch_local_commu_emails:" . "<br />";
$records = $rs_email->fetch_local_commu_emails();
if (is_string($records)) echo "Error:" . $records . "<br />";
else foreach($records as $row) {
	echo "-- " . $row[0] . "<br />";
}
echo "<br />";

// 判断用户邮箱是否在指定的本地社区的邮箱列表中
echo "call check_email_in_commu_list" . "<br />";
$is_on_list = $rs_email->check_email_in_commu_list("ykswxk@example.com", "0iao@example.com");
//$is_on_list = $rs_email->check_email_in_commu_list("4eb6l8@example.com", "7qvs@example.com");
if (is_string($is_on_list)) echo "Error:" . $is_on_list . "<br />";
else if ($is_on_list) echo "True<br />";
else echo "False<br />"; 
echo "<br />";

// 打印指定社区邮箱对应的本地社区的所有用户邮箱列表
echo "call fetch_commu_mailing_list:" . "<br />";
$records = $rs_email->fetch_commu_mailing_list("8pjc@example.com");
if (is_string($records)) echo "Error:" . $records . "<br />";
else foreach($records as $row) {
	echo "-- " . $row[0] . "<br />";
}
echo "<br />";

// 打印指定本地用户邮箱对应用户的个人空间地址
echo "call fetch_user_ftp_by_email:" . "<br />";
$ftps = $rs_email->fetch_user_ftp_by_email("mo7rwv@example.com");
if (is_string($ftps)) echo "Error:" . $ftps . "<br />";
else foreach($ftps as $ftp) {
	echo "-- " . $ftp[0] . ":" . $ftp[1] . ":" . $ftp[2] . "<br />";
}
echo "<br />";

// 打印指定社区邮箱对应的本地社区的空间地址
echo "call fetch_commu_ftp_by_email:" . "<br />";
$ftps = $rs_email->fetch_commu_ftp_by_email("8pjc@example.com");
if (is_string($ftps)) echo "Error:" . $ftps . "<br />";
else foreach($ftps as $ftp) {
	echo "-- " . $ftp[0] . ":" . $ftp[1] . ":" . $ftp[2] . "<br />";
}
echo "<br />";

// 打印所有本地通讯组邮箱
echo "call fetch_local_grp_emails:" . "<br />";
$records = $rs_email->fetch_local_commu_emails();
if (is_string($records)) echo "Error:" . $records . "<br />";
else foreach($records as $row) {
	echo "-- " . $row[0] . "<br />";
}
echo "<br />";

// 通过邮箱验证用户是否为本地通讯组所有者
echo "call check_user_own_grp_by_email" . "<br />";
$is_owner = $rs_email->check_user_own_grp_by_email("ykswxk@example.com", "0iao@example.com");
if (is_string($is_owner)) echo "Error:" . $is_owner . "<br />";
else if ($is_owner == 1) echo "True<br />";
else echo "False<br />";
echo "<br />";

// 打印指定通讯组邮箱对应的所有用户/社区/通讯组邮箱列表
echo "call fetch_grp_mailing_list:" . "<br />";
//$records = $rs_email->fetch_grp_mailing_list("ugk3@example.com");
$records = $rs_email->fetch_grp_mailing_list("stgiw@example.com");
if (is_string($records)) echo "Error:" . $records . "<br />";
else foreach($records as $row) {
	echo "-- " . $row[0] . "<br />";
}
echo "<br />";

?>