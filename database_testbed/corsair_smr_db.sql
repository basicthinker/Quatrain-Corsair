-- ------------------------------------------------
-- 本文件用于在super manager创建数据库表
-- Author: Jinglei Ren
-- Email: jinglei.ren.china@gmail.com
-- Create Date: 2010/03/20
-- Modified Date: 2010-6-1
-- ------------------------------------------------

CREATE DATABASE corsair_smr;
USE corsair_smr;

# DROP TABLE smr_local_mgr;
CREATE TABLE IF NOT EXISTS smr_local_mgr (
  id char(5) NOT NULL,
  name varchar(50) NOT NULL,
  description varchar(255),
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

# DROP TABLE smr_overall_user;
CREATE TABLE IF NOT EXISTS smr_overall_user (
  local_mgr_id char(5) NOT NULL,
  local_id int unsigned NOT NULL,
  name varchar(20) NOT NULL,
  user_name varchar(100) NOT NULL,
  password varchar(100) NOT NULL,
  email varchar(100),
  phone varchar(20),
  sync_time TIMESTAMP NOT NULL,
  PRIMARY KEY (local_mgr_id, local_id),
  
  # 此外键不设置级联删除，消除某local manager时其社区不自动随之销毁
  FOREIGN KEY (local_mgr_id) REFERENCES smr_local_mgr(id)
    ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

# DROP TABLE smr_overall_commu;
CREATE TABLE IF NOT EXISTS smr_overall_commu (
  local_mgr_id char(5) NOT NULL,
  local_id int unsigned NOT NULL,
  name varchar(50) NOT NULL,
  alias varchar(20) NOT NULL,
  admin_local_id int unsigned NOT NULL,
  email varchar(100) NOT NULL,
  phone varchar(20),
  description varchar(255),
  is_inter boolean NOT NULL DEFAULT FALSE,
  is_approved boolean NOT NULL DEFAULT TRUE,
  sync_time TIMESTAMP NOT NULL,
  PRIMARY KEY (local_mgr_id, local_id),
  
  # 此外键不设置级联删除，删除管理员时对应社区不自动随之销毁
  FOREIGN KEY (local_mgr_id, admin_local_id) 
    REFERENCES smr_overall_user(local_mgr_id, local_id)
    ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

# DROP TABLE smr_commu_user;
CREATE TABLE IF NOT EXISTS smr_commu_user (
  id int unsigned NOT NULL AUTO_INCREMENT,
  user_mgr_id char(5) NOT NULL,
  user_local_id int unsigned NOT NULL,
  commu_mgr_id char(5) NOT NULL,
  commu_local_id int unsigned NOT NULL,
  description varchar(255),
  is_approved boolean NOT NULL DEFAULT FALSE,
  PRIMARY KEY (id),
  
  # 此外键设置为级联删除，删除用户时自动退出其所有加入的社区
  FOREIGN KEY (user_mgr_id, user_local_id) 
    REFERENCES smr_overall_user(local_mgr_id, local_id)
    ON UPDATE CASCADE
    ON DELETE CASCADE,
    
  # 此外键设置为级联删除，删除社区时自动解散其所有包含的用户
  FOREIGN KEY (commu_mgr_id, commu_local_id) 
    REFERENCES smr_overall_commu(local_mgr_id, local_id)
    ON UPDATE CASCADE
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

# DROP TABLE smr_global_grp;
CREATE TABLE IF NOT EXISTS smr_global_grp (
  id int unsigned NOT NULL AUTO_INCREMENT,
  name varchar(50) NOT NULL,
  alias varchar(20) NOT NULL,
  owner_mgr_id char(5) NOT NULL,
  owner_local_id int unsigned NOT NULL,
  email varchar(100) NOT NULL,
  description varchar(255),
  create_time DATETIME NOT NULL,
  is_approved boolean NOT NULL DEFAULT TRUE,
  PRIMARY KEY (id),
  
  #此外键设置为级联删除，删除用户时自动删除其所有的全局通讯组
  FOREIGN KEY (owner_mgr_id, owner_local_id)
    REFERENCES smr_overall_user(local_mgr_id, local_id)
    ON UPDATE CASCADE
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

# DROP TABLE smr_overall_grp;
CREATE TABLE IF NOT EXISTS smr_overall_grp (
  local_mgr_id char(5) NOT NULL,
  local_id int unsigned NOT NULL,
  name varchar(50) NOT NULL,
  alias varchar(20) NOT NULL,
  owner_local_id int unsigned NOT NULL,
  email varchar(100) NOT NULL,
  description varchar(255),
  is_approved boolean NOT NULL DEFAULT FALSE,
  sync_time TIMESTAMP NOT NULL,
  PRIMARY KEY (local_mgr_id, local_id),
  
  # 此外键设置为级联删除，删除用户时自动删除其所有的校际通讯组
  FOREIGN KEY (local_mgr_id, owner_local_id) 
    REFERENCES smr_overall_user(local_mgr_id, local_id)
    ON UPDATE CASCADE
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

# DROP TABLE smr_grp_commu;
CREATE TABLE smr_grp_commu (
  id int unsigned NOT NULL AUTO_INCREMENT,
  commu_mgr_id char(5) NOT NULL,
  commu_local_id int unsigned NOT NULL,
  grp_mgr_id char(5) NOT NULL,
  grp_local_id int unsigned NOT NULL,
  description varchar(255),
  is_approved boolean NOT NULL DEFAULT FALSE,
  PRIMARY KEY (id),
  
  # 此外键设置为级联删除，删除社区时自动删除所有包含它的通讯组
  FOREIGN KEY (commu_mgr_id, commu_local_id) 
    REFERENCES smr_overall_commu(local_mgr_id, local_id)
    ON UPDATE CASCADE
    ON DELETE CASCADE,
    
  # 此外键设置为级联删除，删除通讯组时自动解散其所有包含的社区
  FOREIGN KEY (grp_mgr_id, grp_local_id) 
    REFERENCES smr_overall_grp(local_mgr_id, local_id)
    ON UPDATE CASCADE
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

# DROP TABLE smr_grp_relation 
CREATE TABLE smr_grp_relation (
  id int unsigned NOT NULL AUTO_INCREMENT,
  local_mgr_id char(5) NOT NULL,
  inter_grp_id int unsigned NOT NULL,
  global_grp_id int unsigned NOT NULL,
  description varchar(255),
  is_approved boolean NOT NULL DEFAULT TRUE,
  PRIMARY KEY (id),
  
  # 此外键设置为级联删除，删除校际通讯组时自动退出所有包含它的全局通讯组
  FOREIGN KEY (local_mgr_id, inter_grp_id)
    REFERENCES smr_overall_grp(local_mgr_id, local_id)
    ON UPDATE CASCADE
    ON DELETE CASCADE,
  
  # 此外键设置为级联删除，删除全局通讯组时自动解散其包含的所有校际通讯录
  FOREIGN KEY (global_grp_id) REFERENCES smr_global_grp(id)
    ON UPDATE CASCADE
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
