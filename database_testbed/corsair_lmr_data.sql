-- ----------------------------------------------
-- 本文件用于向local manager填充随机测试数据
-- Prerequisite: corsair_lmr_db_core.sql has been run.
-- Author: Jinglei Ren
-- Email: jinglei.ren.china@gmail.com
-- Date: 2010/03/22
-- ---------------------------------------------

-- 更改分隔符为"//"，即遇"//"才执行
DELIMITER //

-- ------------------------------------------------------------ 
-- 生成随机字符串的函数
-- Parameters:
--          n: length of generated string with the max value 255
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

-- --------------------------------------------- 
-- 填充jos_users表的存储过程
-- Parameters:
--   user_cnt: the number of users to generate
-- ---------------------------------------------
DROP PROCEDURE IF EXISTS insert_jos_users;
CREATE PROCEDURE insert_jos_users (IN user_cnt INT UNSIGNED)
BEGIN
  DECLARE rand_str CHAR(6);
  DECLARE i INT UNSIGNED DEFAULT 0;
  DECLARE CONTINUE HANDLER FOR SQLEXCEPTION BEGIN END;
  
  WHILE i < user_cnt DO
    SET rand_str = rand_string(6);
    INSERT INTO jos_users VALUES (
      NULL,
      rand_str,
      rand_str, 
      concat(rand_str, '@university.edu'),
      rand_str,
      'Registered',
      0,
      0,
      18,
      NOW(),
      NOW(),
      '',
      '',
      0
    );
    SET i = i + 1;
  END WHILE;
END;

-- ------------------------------------------------------------- 
-- 填充lmr_user_patch表的存储过程
-- Prerequisite: the talbe jos_users has been filled with data
-- -------------------------------------------------------------
DROP PROCEDURE IF EXISTS insert_lmr_user_patch;
CREATE PROCEDURE insert_lmr_user_patch ()
BEGIN
  INSERT INTO lmr_user_patch 
  SELECT id, FLOOR(10000000000 + RAND() * 9000000000), NOW()
  FROM jos_users;
END;

-- --------------------------------------------------
-- 填充josersity_community_admin表的存储过程
-- Parameters:
--   commu_cnt: the number of communities to generate
-- --------------------------------------------------
DROP PROCEDURE IF EXISTS insert_jos_community_admin;
CREATE PROCEDURE insert_jos_community_admin (IN commu_cnt INT UNSIGNED)
BEGIN
  DECLARE rand_user_id INT(11);
  DECLARE rand_username VARCHAR(255);
  DECLARE i INT UNSIGNED DEFAULT 0;
  DECLARE CONTINUE HANDLER FOR SQLEXCEPTION BEGIN END;
  
  WHILE i < commu_cnt DO
   
    SELECT id, username INTO rand_user_id, rand_username 
    FROM jos_users ORDER BY RAND() LIMIT 1;
    
    SELECT phone INTO @phone
    FROM lmr_user_patch WHERE user_id = rand_user_id
    ORDER BY RAND() LIMIT 1;
    
    INSERT INTO jos_community_admin VALUES (
      NULL,
      rand_string(4),
      rand_user_id,
      rand_username,
      'community for test',
      NOW(),
      @phone
    );
    SET i = i + 1;
  END WHILE;
END;

-- --------------------------------------------------------------------- 
-- 填充lmr_commu_patch表的存储过程
-- Prerequisite: the talbe jos_community_admin has been filled with data
-- ---------------------------------------------------------------------
DROP PROCEDURE IF EXISTS insert_lmr_commu_patch;
CREATE PROCEDURE insert_lmr_commu_patch ()
BEGIN
  INSERT INTO lmr_commu_patch 
  SELECT comm_id, comm_name, concat(comm_name, '@university.edu'), NOW()
  FROM jos_community_admin;
END;

-- --------------------------------------------------------------------
-- 填充jos_community_user表的存储过程
-- Parameters:
--   relation_cnt: the number of user-community relatins, 
--                 each of which indicates that one user joins one community
-- --------------------------------------------------------------------
DROP PROCEDURE IF EXISTS insert_jos_community_user;
CREATE PROCEDURE insert_jos_community_user (IN relation_cnt INT UNSIGNED)
BEGIN
  DECLARE i INT UNSIGNED DEFAULT 0;
  DECLARE CONTINUE HANDLER FOR SQLEXCEPTION BEGIN END;
  WHILE i < relation_cnt DO
    
    SELECT id, name INTO @id, @name FROM jos_users 
    ORDER BY RAND() LIMIT 1;
    
    SELECT comm_id, comm_name INTO @comm_id, @comm_name
    FROM jos_community_admin WHERE userid <> @id ORDER BY RAND() LIMIT 1;
    
    INSERT INTO jos_community_user VALUES (
      @id,
      @name,
      @comm_id,
      @comm_name
    );
    
    SET i = i + 1;
  END WHILE;
END;

-- ----------------------------------------------------------------------
-- 填充jos_community_apply表的存储过程
-- Prerequisite: the table jos_community_user has been filled with data
-- Parameters:
--   application_cnt: the number of applications
-- ----------------------------------------------------------------------
DROP PROCEDURE IF EXISTS insert_jos_community_apply;
CREATE PROCEDURE insert_jos_community_apply (IN application_cnt INT UNSIGNED)
BEGIN
  DECLARE i INT UNSIGNED DEFAULT 0;
  DECLARE existed_cnt TINYINT;
  DECLARE CONTINUE HANDLER FOR SQLEXCEPTION BEGIN END;
  WHILE i < application_cnt DO
    
    SELECT id, name INTO @id, @name FROM jos_users 
    ORDER BY RAND() LIMIT 1;
    
    SELECT comm_id INTO @comm_id FROM jos_community_admin 
    WHERE userid <> @id ORDER BY RAND() LIMIT 1;
    
    SELECT COUNT(*) INTO existed_cnt FROM jos_community_user
    WHERE id = @id AND comm_id = @comm_id;
    
    IF existed_cnt = 0 
    THEN INSERT INTO jos_community_apply VALUES (
      @id,
      @name,
      'This is application message!',
      @comm_id,
      NOW()
    );
    END IF;
    
    SET i = i + 1;
  END WHILE;
END;

-- --------------------------------------------------
-- 填充vfs_user_spacemap表及vfs_space表的存储过程
-- 每位用户分配一份个人空间
-- --------------------------------------------------
DROP PROCEDURE IF EXISTS insert_vfs_user_space;
CREATE PROCEDURE insert_vfs_user_space ()
BEGIN 
  DECLARE is_finished BOOLEAN DEFAULT FALSE;
  DECLARE user_id INT(11);
  DECLARE user_pwd VARCHAR(100);
  DECLARE cur_user CURSOR FOR SELECT id, `password` FROM jos_users; -- define the cursor
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET is_finished = true; 
 
  OPEN cur_user;
  FETCH cur_user INTO user_id, user_pwd;
  WHILE NOT is_finished DO
    INSERT INTO vfs_space VALUES (
      NULL,
      concat('ftp', user_id),
      user_pwd,
      '166.111.68.165',
      concat('/corsair/person/ftp', user_id),
      concat('ftp://ftp', user_id, ':', user_pwd, '@166.111.68.165/'),
      2097152,
      0,
      1,
      0
    );
    
    INSERT INTO vfs_user_spacemap VALUES (
      user_id,
      @@IDENTITY
    );
    
    FETCH cur_user INTO user_id, user_pwd;
  END WHILE;
  CLOSE cur_user;
END;

-- --------------------------------------------------
-- 填充vfs_community_spacemap表及vfs_space表的存储过程
-- 每个社区分配2个空间
-- --------------------------------------------------
DROP PROCEDURE IF EXISTS insert_vfs_commu_space;
CREATE PROCEDURE insert_vfs_commu_space ()
BEGIN 
  DECLARE is_finished BOOLEAN DEFAULT FALSE;
  DECLARE commu_id INT(11);
  DECLARE commu_name VARCHAR(255);
  DECLARE admin_pwd VARCHAR(100);
  DECLARE sname_admin VARCHAR(255);
  DECLARE sname_user VARCHAR(255);
  DECLARE sip VARCHAR(15) DEFAULT '166.111.68.165';
  DECLARE user_pwd CHAR(10);
    
  DECLARE cur_commu CURSOR FOR SELECT comm_id, comm_name, `password`
  FROM jos_users UT JOIN jos_community_admin CT ON UT.id = CT.userid; 
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET is_finished = TRUE;
  
  OPEN cur_commu;
  FETCH cur_commu INTO commu_id, commu_name, admin_pwd;
  
  WHILE NOT is_finished DO
  
    -- 分配管理员空间
    SET sname_admin = concat('admin-ftpgrp', commu_id);
    INSERT INTO vfs_space VALUES (
      NULL,
      sname_admin,
      admin_pwd,
      sip,
      concat('/corsair/agroa/', sname_admin),
      concat('ftp://', sname_admin, ':', admin_pwd, '@', sip, '/'),
      100000000,
      1,
      1,
      0
    );
    
    INSERT INTO vfs_community_spacemap VALUES (
      commu_id,
      @@IDENTITY,
      1
    );
    
    -- 分配用户空间
    SET user_pwd = rand_string(10);
    SET sname_user = concat('user-ftpgrp', commu_id);
    INSERT INTO vfs_space VALUES (
      NULL,
      sname_user,
      user_pwd,
      sip,
      concat('/corsair/agroa/', sname_admin),
      concat('ftp://', sname_user, ':', user_pwd, '@', sip, '/'),
      100000000,
      2,
      1,
      0
    );
    
    INSERT INTO vfs_community_spacemap VALUES (
      commu_id,
      @@IDENTITY,
      2
    );
    FETCH cur_commu INTO commu_id, commu_name, admin_pwd;
  END WHILE;
  CLOSE cur_commu;
END;

-- ----------------------------------------------
-- 填充lmr_group表的存储过程
-- Parameters:
--   grp_cnt: the number of contact groups to generate
-- ----------------------------------------------
DROP PROCEDURE IF EXISTS insert_lmr_group;
CREATE PROCEDURE insert_lmr_group(IN grp_cnt INT UNSIGNED)
BEGIN
  DECLARE i INT UNSIGNED DEFAULT 0;
  DECLARE owner_id INT(11);
  DECLARE rand_str CHAR(4);
  
  WHILE i < grp_cnt DO
    SET rand_str = rand_string(4);
    SELECT id INTO owner_id FROM jos_users 
    ORDER BY RAND() LIMIT 1;
    INSERT INTO lmr_group VALUES (
      NULL,
      rand_str,
      rand_str,
      owner_id,
      concat(rand_str, '@university.edu'),
      'group for test',
      NOW(),
      TRUE,
      NOW()
    );
    SET i = i + 1;
  END WHILE;
END;

-- ------------------------------------------------------------------------------
-- 填充lmr_grp_commu的存储过程
-- Parameters:
--   relation_cnt: the number of community-group relations,
--                 each of which indicates that one group includes one community
-- ------------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS insert_lmr_grp_commu;
CREATE PROCEDURE insert_lmr_grp_commu(IN relation_cnt INT UNSIGNED)
BEGIN
  DECLARE i INT UNSIGNED DEFAULT 0;
  DECLARE rand_commu_id INT(11);
  DECLARE rand_grp_id INT UNSIGNED;
  DECLARE CONTINUE HANDLER FOR SQLEXCEPTION BEGIN END;
  
  WHILE i < relation_cnt DO
    
    SELECT comm_id INTO rand_commu_id 
    FROM jos_community_admin ORDER BY RAND() LIMIT 1;
    
    SELECT id INTO rand_grp_id FROM lmr_group 
    ORDER BY RAND() LIMIT 1;
    
    INSERT INTO lmr_grp_commu VALUES (
      rand_grp_id,
      rand_commu_id,
      '',
      NOW(),
      TRUE
    );
    
    SET i = i + 1;
  END WHILE;
END;

-- ---------------------------------------------
-- 清空整个数据库的存储过程
-- ---------------------------------------------
DROP PROCEDURE IF EXISTS sp_empty_lmr_db_core;
CREATE PROCEDURE sp_empty_lmr_db_core()
BEGIN
  DELETE FROM jos_community_admin;
  DELETE FROM jos_users;
  DELETE FROM vfs_space;
  DELETE FROM lmr_group;
END;

-- ------------------------------------------------------------------------------
-- 填充整个数据库的存储过程
-- Parameters:
--   user_cnt: the number of users to generate
--   commu_cnt: the number of communities to generate
--   application_cnt: the number of community applications to generate
--   user_commu_cnt: the number of user-community relations to generate
--   grp_cnt: the number of contact groups to generate
--   commu_grp_cnt: the number of community-group relations to generate
-- -------------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS sp_fill_lmr_db_core;
CREATE PROCEDURE sp_fill_lmr_db_core (
  IN user_cnt INT UNSIGNED,
  IN commu_cnt INT UNSIGNED,
  IN application_cnt INT UNSIGNED,
  IN user_commu_cnt INT UNSIGNED,
  IN grp_cnt INT UNSIGNED,
  IN commu_grp_cnt INT UNSIGNED
)
BEGIN 
  CALL insert_jos_users(user_cnt);
  CALL insert_lmr_user_patch();
  CALL insert_jos_community_admin(commu_cnt);
  CALL insert_lmr_commu_patch();
  CALL insert_jos_community_user(user_commu_cnt);
  CALL insert_jos_community_apply(application_cnt);
  CALL insert_vfs_user_space();
  CALL insert_vfs_commu_space();
  CALL insert_lmr_group(grp_cnt);
  CALL insert_lmr_grp_commu(commu_grp_cnt);
END;
//

DELIMITER ;

-- -----------------------------------------------

CALL sp_empty_lmr_db_core();

-- ------------------------------------------------
