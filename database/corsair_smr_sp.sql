-- ------------------------------------------------------------
-- 本文件用于在super manager数据库创建存储过程，作为数据层接口
-- Prerequisite: super manager完整数据库
-- Author: Jinglei Ren <jinglei.ren.china@gmail.com>
-- Organization: Department of Computer Science & Technology, Tsinghua University
-- Create Date: 2010-4-9
-- Last Modified: 2010-5-22
-- -------------------------------------------------------------

-- 更改下面一行为super manager中数据库的名称并运行
USE corsair_smr;

-- 更改分隔符为"//"，即遇"//"才执行
DELIMITER //

-- ---------------------------------------------------------------------------------
-- 判断本地用户邮箱是否在校际社区邮箱列表中的存储过程
-- Parameters:
--   user_email: the local user email to check
--   commu_email: email of the inter-school community who owns the target mailing list
-- Returns:
--   1 row, 1 column:
--     0 - the user email is not on the target mailing list
--     1 - the user email is on the target mailing list
-- ---------------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS sp_check_email_in_commu_list;
CREATE PROCEDURE sp_check_email_in_commu_list (
  IN user_email VARCHAR(100),
  IN commu_email VARCHAR(100)
)
BEGIN
  DECLARE lmr_id INT UNSIGNED;
  DECLARE commu_id INT UNSIGNED;

  SELECT local_mgr_id, local_id INTO lmr_id, commu_id 
  FROM smr_overall_commu 
  WHERE email = commu_email AND is_inter = TRUE;
  
  IF commu_id IS NULL THEN SELECT 0;
  ELSE 
    SELECT COUNT(*) 
    FROM smr_overall_user AS U 
      JOIN smr_commu_user AS CU
      ON U.local_id = CU.user_local_id AND U.local_mgr_id = CU.user_mgr_id
    WHERE CU.commu_local_id = commu_id AND CU.commu_mgr_id = lmr_id AND U.email = user_email;
  END IF;
END;

-- -----------------------------------------------------------------------------------
-- 通过校际社区邮箱获得其外校用户邮箱列表的存储过程
-- Parameters:
--   commu_email: email of the target community
-- Returns:
--   0 row indicates the community email is not correct or its mailing list is empty.
--   one or more rows: requried email(s) of user(s)
-- -----------------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS sp_fetch_commu_xtnl_mailing_list;
CREATE PROCEDURE sp_fetch_commu_xtnl_mailing_list (IN commu_email VARCHAR(100))
BEGIN
  SELECT U.email 
  FROM smr_overall_user AS U 
    JOIN smr_commu_user AS CU 
    ON U.local_id = CU.user_local_id AND U.local_mgr_id = CU.user_mgr_id
      JOIN smr_overall_commu AS C
      ON CU.commu_local_id = C.local_id AND CU.commu_mgr_id = C.local_mgr_id 
  WHERE C.email = commu_email;
END;

-- --------------------------------------------------
-- 通过校际通讯组的邮箱获得其包含的外校社区的邮箱
-- Parameters:
--   grp_email: email of target group
-- Returns:
--   required comunities' emails on success,
--   or empty table on failure
-- --------------------------------------------------
DROP PROCEDURE IF EXISTS sp_fetch_grp_xtnl_commu_email;
CREATE PROCEDURE sp_fetch_grp_xtnl_commu_email(IN grp_email VARCHAR(100))
BEGIN
  SELECT C.email
  FROM smr_overall_commu AS C
    JOIN smr_grp_commu AS GC
    ON GC.commu_mgr_id = C.local_mgr_id AND GC.commu_local_id = C.local_id
      JOIN smr_overall_grp AS G
      ON GC.grp_mgr_id = G.local_mgr_id AND GC.grp_local_id = G.local_id
  WHERE G.email = grp_email;
END;

-- ---------------------------------------------------
-- 通过全局通讯组的邮箱获得其包含的校际通讯组的邮箱
-- Parameters: 
--   grp_email: email of target global group
-- Returns:
--   required groups' emails on success,
--   or empty table on failure
-- ---------------------------------------------------
DROP PROCEDURE IF EXISTS sp_fetch_global_grp_mailing_list;
CREATE PROCEDURE sp_fetch_global_grp_mailing_list(IN grp_email VARCHAR(100))
BEGIN
  SELECT LG.email
  FROM smr_overall_grp AS LG
    JOIN smr_grp_relation AS GR
    ON GR.local_mgr_id = LG.local_mgr_id AND GR.inter_grp_id = LG.local_id
      JOIN smr_global_grp AS GG
      ON GR.global_grp_id = GG.id
  WHERE GG.email = grp_email;
END;

-- ----------------------------------------------------------------
-- 通过用户手机号获得其加入的所有外校社区名称和地址
-- Parameters:
--   user_phone: phone number of target user
-- Returns:
--   required name(s) and URI(s) on success,
--   or empty table on failure
-- ----------------------------------------------------------------
DROP PROCEDURE IF EXISTS sp_fetch_inter_commu_by_phone;
CREATE PROCEDURE sp_fetch_inter_commu_by_phone(IN user_phone VARCHAR(100))
BEGIN
  SELECT C.name, CONCAT(C.alias, '.', M.namespace) AS alias
  FROM smr_overall_user AS U 
    JOIN smr_commu_user AS CU
    ON CU.user_mgr_id = U.local_mgr_id AND CU.user_local_id = U.local_id
      JOIN smr_overall_commu AS C 
      ON CU.commu_mgr_id = C.local_mgr_id AND CU.commu_local_id = C.local_id
        JOIN smr_local_mgr AS M
        ON C.local_mgr_id = M.id
  WHERE U.phone = user_phone;
END;

-- ---------------------------------------------------
-- 通过校际社区代号获得其所有外校成员手机号
-- Parameters:
--   namespace: namespace of target local manager
--   commu_alias: alias of target community
-- Returns:
--   required phone number(s) on success,
--   or empty table on failure
-- ---------------------------------------------------
DROP PROCEDURE IF EXISTS sp_fetch_commu_xtnl_phone_list;
CREATE PROCEDURE sp_fetch_commu_xtnl_phone_list (
  IN namespace VARCHAR(10),
  IN commu_alias VARCHAR(20)
)
BEGIN
  DECLARE lmr_id INT UNSIGNED;
  
  SELECT id INTO lmr_id
  FROM smr_local_mgr
  WHERE smr_local_mgr.namespace = namespace;
  
  SELECT U.phone 
  FROM smr_overall_user AS U
    JOIN smr_commu_user AS CU
    ON CU.user_mgr_id = U.local_mgr_id AND CU.user_local_id = U.local_id
      JOIN smr_overall_commu AS C
      ON CU.commu_mgr_id = C.local_mgr_id AND CU.commu_local_id = C.local_id
  WHERE C.local_mgr_id = lmr_id AND C.alias = commu_alias;
  
END;

-- ----------------------------------------------------
-- 通过用户手机号获得其拥有的所有全局通讯组名称和代号
-- Parameters:
--   user_phone: phone number of target user
-- Returns:
--   required names and alias of groups on success,
--   or empty table on failure
-- ----------------------------------------------------
DROP PROCEDURE IF EXISTS sp_fetch_global_grp_by_phone;
CREATE PROCEDURE sp_fetch_global_grp_by_phone (
  IN user_phone VARCHAR(20)
)
BEGIN
  SELECT G.name, G.alias 
  FROM smr_global_grp AS G
    JOIN smr_overall_user AS U
    ON G.owner_mgr_id = U.local_mgr_id AND G.owner_local_id = U.local_id
  WHERE U.phone = user_phone;
END;

-- --------------------------------------------------------------------
-- 通过校际通讯组的命名空间和代号获得其所有外校社区短信中心号码和代码
-- Parameters:
--   namespace: namespace of target group 
--   grp_alias: alias of target group
-- Returns:
--   required sms number(s) and community alias(es) on success,
--   or empty table on failure
-- ---------------------------------------------------------------------
DROP PROCEDURE IF EXISTS sp_fetch_grp_xtnl_sms_list;
CREATE PROCEDURE sp_fetch_grp_xtnl_sms_list (
  IN grp_namespace VARCHAR(10),
  IN grp_alias VARCHAR(20)
)
BEGIN
  DECLARE grp_mgr_id INT UNSIGNED;
  DECLARE grp_local_id INT UNSIGNED;
  
  SELECT G.local_mgr_id, G.local_id 
  INTO grp_mgr_id, grp_local_id
  FROM smr_overall_grp AS G
    JOIN smr_local_mgr AS M
    ON G.local_mgr_id = M.id
  WHERE M.namespace = grp_namespace AND G.alias = grp_alias;

  SELECT M.sms_number, C.alias
  FROM smr_grp_commu AS GC
    JOIN smr_overall_commu AS C
    ON GC.commu_mgr_id = C.local_mgr_id AND GC.commu_local_id = C.local_id
      JOIN smr_local_mgr AS M
      ON C.local_mgr_id = M.id
  WHERE GC.grp_mgr_id = grp_mgr_id AND GC.grp_local_id = grp_local_id;
END;

-- --------------------------------------------------------------
-- 通过全局通讯组代码获得其包含的校际通讯组的短信中心号码和代码
-- Parameters:
--   grp_alias: alias of target group
-- Returns:
--   required sms number(s) and alias(es) on success,
--   or empty table on failure
-- --------------------------------------------------------------
DROP PROCEDURE IF EXISTS sp_fetch_global_grp_sms_list;
CREATE PROCEDURE sp_fetch_global_grp_sms_list (IN grp_alias VARCHAR(20))
BEGIN
  SELECT M.sms_number, OG.alias
  FROM smr_local_mgr AS M
    JOIN smr_overall_grp AS OG
    ON OG.local_mgr_id = M.id
      JOIN smr_grp_relation GR
      ON GR.local_mgr_id = OG.local_mgr_id AND GR.inter_grp_id = OG.local_id
        JOIN smr_global_grp AS GG
        ON GR.global_grp_id = GG.id
  WHERE GG.alias = grp_alias;
END;

-- ---------------------------------------------------
-- 通过命名空间获得其短信中心号码
-- Parameters:
--   namespace: namespace of target local manager
-- Returns:
--   required sms number on success,
--   or empty table on failure
-- ---------------------------------------------------
DROP PROCEDURE IF EXISTS sp_fetch_sms_number;
CREATE PROCEDURE sp_fetch_sms_number(IN namespace VARCHAR(10))
BEGIN
  SELECT sms_number FROM smr_local_mgr
  WHERE smr_local_mgr.namespace = namespace;
END;

-- --------------------------------------------------------------------
-- 通过校际通讯组的IP地址和ID号获得其所有外校社区IP地址和ID号
-- Parameters:
--   lmr_ip: ip address of local manager 
--   grp_id: local id of target group
-- Returns:
--   required ip address(es) and community id(s) on success,
--   or empty table on failure
-- ---------------------------------------------------------------------
DROP PROCEDURE IF EXISTS sp_fetch_grp_xtnl_commu;
CREATE PROCEDURE sp_fetch_grp_xtnl_commu (
  IN lmr_ip VARCHAR(20),
  IN grp_id INT UNSIGNED
)
BEGIN
  DECLARE grp_mgr_id INT UNSIGNED;
  DECLARE grp_local_id INT UNSIGNED;
  
  SELECT G.local_mgr_id, G.local_id 
  INTO grp_mgr_id, grp_local_id
  FROM smr_overall_grp AS G
    JOIN smr_local_mgr AS M
    ON G.local_mgr_id = M.id
  WHERE M.ip_address = lmr_ip AND G.local_id = grp_id;

  SELECT M.ip_address, C.local_id
  FROM smr_grp_commu AS GC
    JOIN smr_overall_commu AS C
    ON GC.commu_mgr_id = C.local_mgr_id AND GC.commu_local_id = C.local_id
      JOIN smr_local_mgr AS M
      ON C.local_mgr_id = M.id
  WHERE GC.grp_mgr_id = grp_mgr_id AND GC.grp_local_id = grp_local_id;
END;

//
DELIMITER ;
