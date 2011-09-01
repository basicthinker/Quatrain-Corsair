-- ------------------------------------------------------------
-- 本文件用于在local manager数据库创建存储过程，作为数据层接口
-- Prerequisite: local manager完整数据库
-- Author: Jinglei Ren <jinglei.ren.china@gmail.com>
-- Organization: Department of Computer Science & Technology, Tsinghua University 
-- Create Date: 2010-4-9
-- Last Modified: 2010-5-21
-- ------------------------------------------------------------

-- 更改分隔符为"//"，即遇"//"才执行
DELIMITER //

-- -------------------------------
-- 获得本地所有社区邮箱的存储过程
-- -------------------------------
DROP PROCEDURE IF EXISTS sp_fetch_commu_emails;
CREATE PROCEDURE sp_fetch_commu_emails()
BEGIN
  SELECT email FROM lmr_commu_patch;
END;

-- ---------------------------------------------------------------------------------
-- 判断本地用户邮箱是否在指定的本地社区的邮箱列表中的存储过程
-- Parameters:
--   user_email: the local user email to check
--   commu_email: email of the local community who owns the target mailing list
-- Returns:
--   1 row, 1 column:
--     0 - the user email is not on the target mailing list
--     1 - the user email is on the target mailing list
--     2 - the community email is not locally found
-- ---------------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS sp_check_email_in_commu_list;
CREATE PROCEDURE sp_check_email_in_commu_list (
  IN user_email VARCHAR(100),
  IN commu_email VARCHAR(100)
)
BEGIN
  DECLARE commu_id INT UNSIGNED;

  SELECT community_id 
  INTO commu_id 
  FROM lmr_commu_patch 
    WHERE email = commu_email;
  
  IF commu_id IS NULL THEN SELECT 2 AS ret_val;
  ELSE 
    SELECT COUNT(*) AS ret_val 
    FROM jos_users 
      JOIN jos_community_user 
      ON jos_users.id = jos_community_user.id
      WHERE comm_id = commu_id AND email = user_email;
  END IF;
END;

-- -----------------------------------------------------------------------------------
-- 通过本地社区邮箱获得其本地用户邮箱列表的存储过程
-- Parameters:
--   commu_email: email of the target local community
-- Returns:
--   0 row indicates the community email is not correct or its mailing list is empty.
--   one or more rows: email(s) of local user(s)
-- -----------------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS sp_fetch_commu_mailing_list;
CREATE PROCEDURE sp_fetch_commu_mailing_list (IN commu_email VARCHAR(100))
BEGIN
  SELECT jos_users.email 
  FROM jos_users 
    JOIN jos_community_user 
    ON jos_users.id = jos_community_user.id
      JOIN lmr_commu_patch 
      ON jos_community_user.comm_id = lmr_commu_patch.community_id
      WHERE lmr_commu_patch.email = commu_email;
END;

/* 冗余接口
-- --------------------------------------------------------------------------
-- 通过本地社区邮箱获得本地用户的个人空间地址的存储过程
-- Parameters:
--   commu_email: email of the target local community
-- Returns:
--   0 row indicates the community email is not correct or the community has no users.
--   one or more rows: ftp address(es) of local user(s)
-- --------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS sp_fetch_commu_user_ftp;
CREATE PROCEDURE sp_fetch_commu_user_ftp (IN commu_email VARCHAR(100))
BEGIN
  DECLARE commu_id INT UNSIGNED;
  
  SELECT community_id INTO commu_id FROM lmr_commu_patch WHERE email = commu_email LIMIT 1;
  IF NOT commu_id IS NULL THEN
    SELECT sip AS host_ip, sname AS user_name, spass AS `password` FROM vfs_space JOIN vfs_user_spacemap ON vfs_space.sid = vfs_user_spacemap.sid
    JOIN jos_community_user ON vfs_user_spacemap.id = jos_community_user.id
    WHERE jos_community_user.comm_id = commu_id;
  END IF;
END;
*/

-- ---------------------------------------------------------------------------
-- 通过本地用户邮箱获得其个人空间地址的存储过程
-- Parameters:
--   user_email: email of the target local user
-- Returns:
--   0 row indicates the user email is not correct or the user owns no space.
--   1 row: the required ftp address
-- ---------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS sp_fetch_user_ftp_by_email;
CREATE PROCEDURE sp_fetch_user_ftp_by_email (IN user_email VARCHAR(100))
BEGIN
  SELECT sip AS host_ip, sname AS user_name, spass AS `password` 
  FROM vfs_space 
    JOIN vfs_user_spacemap 
    ON vfs_user_spacemap.sid = vfs_space.sid
      JOIN jos_users 
      ON vfs_user_spacemap.id = jos_users.id
      WHERE jos_users.email = user_email;
END;

-- ------------------------------------------------------
-- 通过本地社区邮箱获得社区空间地址的存储过程
-- Parameters:
--   commu_email: email of the target local community
-- Returns:
--   0 row indicates the community email is not correct.
--   1 row: the required ftp address
-- ------------------------------------------------------
DROP PROCEDURE IF EXISTS sp_fetch_commu_ftp_by_email;
CREATE PROCEDURE sp_fetch_commu_ftp_by_email (IN commu_email VARCHAR(100))
BEGIN
  SELECT sip AS host_ip, sname AS user_name, spass AS `password` 
  FROM vfs_space 
    JOIN vfs_community_spacemap 
    ON vfs_community_spacemap.sid = vfs_space.sid
      JOIN lmr_commu_patch 
      ON vfs_community_spacemap.comm_id = lmr_commu_patch.community_id
      WHERE lmr_commu_patch.email = commu_email;
END;

-- ---------------------------------
-- 获得本地所有通讯组邮箱的存储过程
-- ---------------------------------
DROP PROCEDURE IF EXISTS sp_fetch_grp_emails;
CREATE PROCEDURE sp_fetch_grp_emails()
BEGIN
  SELECT email FROM lmr_group;
END;

-- ---------------------------------------------------
-- 通过邮箱判断本地用户是否拥有本地通讯组的存储过程
-- Parameters:
--   user_email: email of the user to check
--   grp_email: email of the group to check
-- Returns:
--   1 row, 1 column:
--     0 - the user is not the owner
--     1 - the user email is the owner 
-- ---------------------------------------------------
DROP PROCEDURE IF EXISTS sp_check_user_own_grp_by_email;
CREATE PROCEDURE sp_check_user_own_grp_by_email (
  IN user_email VARCHAR(100), 
  IN grp_email VARCHAR(100)
)
BEGIN
  SELECT COUNT(*) AS ret_val 
  FROM jos_users 
    JOIN lmr_group 
    ON lmr_group.owner_id = jos_users.id
    WHERE jos_users.email = user_email AND lmr_group.email = grp_email;
END;

-- ----------------------------------------------------------------------------
-- 通过本地通讯组邮箱获得其本地用户邮件列表的存储过程
-- Parameters:
--   grp_email: email of the target local group
-- Returns:
--   0 row indicates the group email is not correct or the group has no users.
--   one or more rows: the required email(s)
-- ----------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS sp_fetch_grp_mailing_list;
CREATE PROCEDURE sp_fetch_grp_mailing_list(IN grp_email VARCHAR(100))
BEGIN
  SELECT DISTINCT email 
  FROM jos_users AS U 
    JOIN jos_community_user AS CU 
    ON U.id = CU.id 
      AND CU.comm_id IN (
        SELECT GC.community_id 
        FROM lmr_grp_commu AS GC 
          JOIN lmr_group AS G 
          ON GC.group_id = G.id AND G.email = grp_email
      );
END;

-- --------------------------------------------
-- 判定用户是否有向本地社区群发短信权限的存储过程
-- Parameters:
--   user_phone: phone number of target user
--   commu_alias: alias of target community
-- Returns:
--   1 row, 1 column:
--     0 - the user is unauthorized
--     1 - the user is authorized
-- ---------------------------------------------
DROP PROCEDURE IF EXISTS sp_check_phone_in_commu_list;
CREATE PROCEDURE sp_check_phone_in_commu_list(
  IN user_phone VARCHAR(20),
  IN commu_alias VARCHAR(20)
)
BEGIN
  SELECT COUNT(*) AS ret_val 
  FROM lmr_user_patch AS U 
    JOIN jos_community_user AS CU 
    ON U.user_id = CU.id
      JOIN lmr_commu_patch AS C 
      ON CU.comm_id = C.community_id
      WHERE C.alias = commu_alias AND U.phone = user_phone;
END;

-- --------------------------------------------
-- 判定用户是否本地通讯组所有者的存储过程
-- Parameters:
--   user_phone: phone number of target user
--   grp_alias: alias of target group
-- Returns:
--   1 row, 1 column:
--     0 - the user is not the owner
--     1 - the user is the owner
-- ---------------------------------------------
DROP PROCEDURE IF EXISTS sp_check_grp_owner_by_phone;
CREATE PROCEDURE sp_check_grp_owner_by_phone(
  IN user_phone VARCHAR(20),
  IN grp_alias VARCHAR(20)
)
BEGIN
  SELECT COUNT(*) AS ret_val 
  FROM lmr_user_patch 
    JOIN lmr_group 
    ON lmr_user_patch.user_id = lmr_group.owner_id
      AND lmr_user_patch.phone = user_phone 
      AND lmr_group.alias = grp_alias;
END;

-- -------------------------------------------------------
-- 通过本地用户手机号获得其所在本地社区的名称和代码的存储过程
-- Parameters:
--   user_phone: phone number of target user
-- Returns:
--   community names and alias
-- -------------------------------------------------------
DROP PROCEDURE IF EXISTS sp_fetch_commu_by_phone;
CREATE PROCEDURE sp_fetch_commu_by_phone(IN user_phone VARCHAR(20))
BEGIN
  SELECT comm_name AS name, alias 
  FROM lmr_commu_patch AS C 
    JOIN jos_community_user AS CU
    ON C.community_id = CU.comm_id
      JOIN lmr_user_patch AS U 
      ON CU.id = U.user_id
      WHERE U.phone = user_phone;
END;

-- -------------------------------------------------------
-- 通过本地用户手机号获得其拥有的本地通讯组名称和代码的存储过程
-- Parameters:
--   user_phone: phone number of target user
-- Returns:
--   group names and alias
-- -------------------------------------------------------
DROP PROCEDURE IF EXISTS sp_fetch_grp_by_phone;
CREATE PROCEDURE sp_fetch_grp_by_phone(IN user_phone VARCHAR(20))
BEGIN
  SELECT name, alias 
  FROM lmr_group 
    JOIN lmr_user_patch 
    ON lmr_group.owner_id = lmr_user_patch.user_id
    WHERE phone = user_phone;
END;

-- -------------------------------------------
-- 通过本地社区代码获得其本地用户手机号的存储过程
-- Parameters:
--   commu_alias: alias of target community
-- Returns:
--   phone numbers of all its users
-- -------------------------------------------
DROP PROCEDURE IF EXISTS sp_fetch_commu_phone_list;
CREATE PROCEDURE sp_fetch_commu_phone_list(IN commu_alias VARCHAR(20))
BEGIN
  SELECT DISTINCT phone 
  FROM lmr_user_patch AS U 
    JOIN jos_community_user AS CU
    ON U.user_id = CU.id
      JOIN lmr_commu_patch AS C 
      ON CU.comm_id = C.community_id
      WHERE C.alias = commu_alias;
END;

-- -------------------------------------------
-- 通过本地通讯组代码获得其本地用户手机号的存储过程
-- Parameters:
--   grp_alias: alias of target group
-- Returns:
--   phone numbers of all its users
-- -------------------------------------------
DROP PROCEDURE IF EXISTS sp_fetch_grp_phone_list;
CREATE PROCEDURE sp_fetch_grp_phone_list(IN grp_alias VARCHAR(20))
BEGIN
  SELECT DISTINCT phone 
  FROM lmr_user_patch AS U 
    JOIN jos_community_user AS CU 
    ON U.user_id = CU.id AND CU.comm_id IN (
      SELECT community_id 
      FROM lmr_grp_commu AS GC 
        JOIN lmr_group AS G 
        ON GC.group_id = G.id AND G.alias = grp_alias
    );
END;

-- --------------------------------------
-- 通过用户手机号获得其用户名的存储过程
-- Parameters: 
--   user_phone: phone number of target user
-- Returns:
--   required user name on success,
--   or empty table on failure
DROP PROCEDURE IF EXISTS sp_fetch_user_name_by_phone;
CREATE PROCEDURE sp_fetch_user_name_by_phone(IN user_phone VARCHAR(20))
BEGIN
  SELECT jos_users.username
  FROM jos_users 
    JOIN lmr_user_patch
    ON lmr_user_patch.user_id = jos_users.id
  WHERE lmr_user_patch.phone = user_phone;
END;

-- ------------------------------------------
-- 增补于 2011-9-1
-- -------------------------------------------
-- 通过本地社区ID获得其本地用户手机号的存储过程
-- Parameters:
--   commu_id: target community id
-- Returns:
--   phone numbers of all its users
-- -------------------------------------------
DROP PROCEDURE IF EXISTS sp_fetch_user_phone_by_commu;
CREATE PROCEDURE sp_fetch_user_phone_by_commu(IN commu_id INT(11))
BEGIN
  SELECT DISTINCT phone 
  FROM lmr_user_patch AS U 
    JOIN jos_community_user AS CU
    ON U.user_id = CU.id
  WHERE CU.comm_id = commu_id;
END;

//
DELIMITER ;
