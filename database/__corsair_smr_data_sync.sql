-- ------------------------------------------------------------ 
-- 生成随机字符串的函数
-- Parameters:
--   n: length of generated string with the max value 255
-- -------------------------------------------------------------
DROP FUNCTION IF EXISTS rand_string;
CREATE FUNCTION rand_string(n TINYINT UNSIGNED)
RETURNS VARCHAR(255)
BEGIN
    DECLARE chars_str VARCHAR(100) DEFAULT 'abcdefghijklmnopqrstuvwxyz0123456789';
    DECLARE chars_len TINYINT DEFAULT LENGTH(chars_str);
    DECLARE return_str VARCHAR(255) DEFAULT '';
    DECLARE i TINYINT UNSIGNED DEFAULT 0; 
    WHILE i < n DO
        SET return_str = 
          concat(return_str, substring(chars_str, FLOOR(1 + RAND() * chars_len), 1));
        SET i = i + 1;
    END WHILE;
    RETURN return_str;
END;

-- -------------------------------------------------------------------------
-- 填充smr_commu_user的存储过程
-- Parameters:
--   relation_cnt: the number of user-community relations
--     where the user and the community come from different local managers
-- -------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS insert_smr_commu_user;
CREATE PROCEDURE insert_smr_commu_user (IN relation_cnt INT UNSIGNED)
BEGIN
  DECLARE user_cnt INT UNSIGNED;
  DECLARE commu_cnt INT UNSIGNED;
  DECLARE i INT UNSIGNED DEFAULT 0;
  DECLARE CONTINUE HANDLER FOR SQLEXCEPTION BEGIN END;
  
  SELECT COUNT(*) INTO user_cnt FROM smr_overall_user;
  SELECT COUNT(*) INTO commu_cnt FROM smr_overall_commu;
  
  -- 准备随机选取用户的语句
  PREPARE select_user FROM
    'SELECT local_mgr_id, local_id 
    INTO @user_mgr_id, @user_local_id
    FROM smr_overall_user LIMIT ?, 1';

  WHILE i < relation_cnt DO
    # 设置随机用户的行数
    SET @rand_row = FLOOR(RAND() * user_cnt);
    EXECUTE select_user USING @rand_row;
    
    SELECT local_mgr_id, local_id INTO @commu_mgr_id, @commu_local_id
    FROM smr_overall_commu WHERE local_mgr_id <> @user_mgr_id
    ORDER BY RAND() LIMIT 1;
    
    UPDATE smr_overall_commu SET is_inter = TRUE 
    WHERE local_mgr_id = @commu_mgr_id AND local_id = @commu_local_id;
    
    INSERT INTO smr_commu_user VALUES (
      NULL,
      @user_mgr_id,
      @user_local_id,
      @commu_mgr_id,
      @commu_local_id,
      NULL,
      TRUE
    );
    
    SET i = i + 1;
  END WHILE;
  
  DEALLOCATE PREPARE select_user;
END;

-- ---------------------------------------------------
-- 填充smr_global_grp表的存储过程
-- Parameters:
--   grp_cnt: the number of global groups to generate
-- ---------------------------------------------------
DROP PROCEDURE IF EXISTS insert_smr_global_grp;
CREATE PROCEDURE insert_smr_global_grp (IN grp_cnt INT UNSIGNED)
BEGIN
	DECLARE i INT UNSIGNED DEFAULT 0;
  DECLARE rand_str CHAR(5);
  DECLARE CONTINUE HANDLER FOR SQLEXCEPTION BEGIN END;
  
  WHILE i < grp_cnt DO
    SET rand_str =  rand_string(5);
    SELECT local_mgr_id, local_id INTO @owner_mgr_id, @owner_local_id
    FROM smr_overall_user ORDER BY RAND() LIMIT 1;
    
    INSERT INTO smr_global_grp VALUES(
      NULL,
      rand_str,
      rand_str,
      @owner_mgr_id,
      @owner_local_id,
      concat(rand_str, '@university.edu'),
      'global group for test',
      NOW(),
      TRUE
    );
    SET i = i + 1;
  END WHILE;
END;

-- ---------------------------------------------------
-- 填充smr_overall_grp表的存储过程
-- ---------------------------------------------------
DROP PROCEDURE IF EXISTS insert_smr_overall_grp;
CREATE PROCEDURE insert_smr_overall_grp ()
BEGIN
  DECLARE CONTINUE HANDLER FOR SQLEXCEPTION BEGIN END;
  
  INSERT INTO smr_overall_grp 
  SELECT 10003, id, name, alias, owner_id, email, description, TRUE, sync_time
  FROM corsair_lmr_thu.lmr_group;
  
  INSERT INTO smr_overall_grp 
  SELECT 10590, id, name, alias, owner_id, email, description, TRUE, sync_time
  FROM corsair_lmr_szu.lmr_group;
END;

-- -------------------------------------------------------------------------------
-- 填充smr_grp_commu表的存储过程
-- Parameters:
--   relation_cnt: the number of community-group relations
--     where the community and the inter group come from different local managers
-- -------------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS insert_smr_grp_commu;
CREATE PROCEDURE insert_smr_grp_commu (IN relation_cnt INT UNSIGNED)
BEGIN
	DECLARE i INT UNSIGNED DEFAULT 0;
  DECLARE CONTINUE HANDLER FOR SQLEXCEPTION BEGIN END;
  
  WHILE i < relation_cnt DO
    SELECT local_mgr_id, local_id INTO @commu_mgr_id, @commu_local_id
    FROM smr_overall_commu ORDER BY RAND() LIMIT 1;
    
    SELECT local_mgr_id, local_id INTO @grp_mgr_id, @grp_local_id
    FROM smr_overall_grp WHERE local_mgr_id <> @commu_mgr_id 
    ORDER BY RAND() LIMIT 1;
    
    INSERT INTO smr_grp_commu VALUES (
      NULL,
      @commu_mgr_id,
      @commu_local_id,
      @grp_mgr_id,
      @grp_local_id,
      NULL,
      TRUE
    );
    SET i = i + 1;
  END WHILE;
END;

-- ----------------------------------------------------------------------------
-- 填充smr_grp_relation表的存储过程
-- Parameters:
--   relation_cnt: the number of group-group relations 
--     each of which indicates that one global group includes one local group;
-- ----------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS insert_smr_grp_relation;
CREATE PROCEDURE insert_smr_grp_relation (IN relation_cnt INT UNSIGNED)
BEGIN
	DECLARE i INT UNSIGNED DEFAULT 0;
  DECLARE CONTINUE HANDLER FOR SQLEXCEPTION BEGIN END;
  
  WHILE i < relation_cnt DO
    SELECT local_mgr_id, local_id INTO @local_mgr_id, @grp_local_id
    FROM smr_overall_grp ORDER BY RAND() LIMIT 1;
    
    SELECT id INTO @global_grp_id
    FROM smr_global_grp ORDER BY RAND() LIMIT 1;
    
    INSERT INTO smr_grp_relation VALUES (
      NULL,
      @local_mgr_id,
      @grp_local_id,
      @global_grp_id,
      NULL,
      TRUE
    );
    SET i = i + 1;
  END WHILE;
END;

-- -------------------------------------------
-- 清空数据库的存储过程
-- -------------------------------------------
DROP PROCEDURE IF EXISTS sp_empty_data;
CREATE PROCEDURE sp_empty_data ()
BEGIN
	DELETE FROM smr_overall_commu;
  DELETE FROM smr_global_grp;
  DELETE FROM smr_overall_grp;
  DELETE FROM smr_overall_user;

  DELETE FROM smr_local_mgr;
END;

-- ----------------------------------------------------------------------------
-- 填充数据库的存储过程
-- Parameters:
--   user_commu_cnt: the number of user-community relations
--     where the user and the community come from different local managers
--   commu_grp_cnt: the number of community-group relations
--     where the community and the inter group come from different local managers
--   global_grp_cnt: the number of global groups to generate
--   grp_relation_cnt: the number of group-group relations 
--     each of which indicates that one global group includes one local group;
-- ----------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS sp_fill_data;
CREATE PROCEDURE sp_fill_data (
  IN user_commu_cnt INT UNSIGNED,
  IN commu_grp_cnt INT UNSIGNED,
  IN global_grp_cnt INT UNSIGNED,
  IN grp_relation_cnt INT UNSIGNED
)
BEGIN
  CALL insert_smr_local_mgr();
  CALL insert_smr_overall_user();
  CALL insert_smr_overall_commu();
  CALL insert_smr_commu_user(user_commu_cnt);
  CALL insert_smr_overall_grp();
  CALL insert_smr_grp_commu(commu_grp_cnt);
  CALL insert_smr_global_grp(global_grp_cnt);
  CALL insert_smr_grp_relation(grp_relation_cnt);
END;
//

-- 恢复原有分隔符
DELIMITER ;

-- ------------------------------------------------------------

-- 如果不需要首先清空原有数据库，可对下一行进行注释
CALL sp_empty_data();

-- -------------------------------------------------------------
