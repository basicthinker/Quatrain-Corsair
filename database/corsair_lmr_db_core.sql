
--
-- Table structure for table `jos_users`
--

DROP TABLE IF EXISTS `jos_users`;
CREATE TABLE `jos_users` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) NOT NULL default '',
  `username` varchar(150) NOT NULL default '',
  `email` varchar(100) NOT NULL default '',
  `password` varchar(100) NOT NULL default '',
  `usertype` varchar(25) NOT NULL default '',
  `block` tinyint(4) NOT NULL default '0',
  `sendEmail` tinyint(4) default '0',
  `gid` tinyint(3) unsigned NOT NULL default '1',
  `registerDate` datetime NOT NULL default '0000-00-00 00:00:00',
  `lastvisitDate` datetime NOT NULL default '0000-00-00 00:00:00',
  `activation` varchar(100) NOT NULL default '',
  `params` text NOT NULL,
  `group` tinyint(11) NOT NULL default '0',
  PRIMARY KEY  (`id`),
  KEY `usertype` (`usertype`),
  KEY `idx_name` (`name`),
  KEY `gid_block` (`gid`,`block`),
  KEY `username` (`username`),
  KEY `email` (`email`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=13138 ;

-- --------------------------------------------------------

--
-- Table structure for table `jos_community_admin`
--

DROP TABLE IF EXISTS `jos_community_admin`;
CREATE TABLE `jos_community_admin` (
  `comm_id` int(11) NOT NULL auto_increment,
  `comm_name` varchar(255) NOT NULL,
  `userid` int(11) NOT NULL,
  `username` varchar(255) NOT NULL,
  `introduction` text NOT NULL,
  `date` datetime NOT NULL,
  `phone` bigint(15) NOT NULL default '0',
  PRIMARY KEY  (`comm_id`),
  UNIQUE KEY `name` (`comm_name`,`userid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=123480 ;

-- --------------------------------------------------------

--
-- Table structure for table `jos_community_apply`
--

DROP TABLE IF EXISTS `jos_community_apply`;
CREATE TABLE `jos_community_apply` (
  `id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `msg` text NOT NULL,
  `comm_id` int(11) NOT NULL,
  `date` datetime NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `jos_community_user`
--
DROP TABLE IF EXISTS `jos_community_user`;
CREATE TABLE `jos_community_user` (
  `id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `comm_id` int(11) NOT NULL,
  `comm_name` varchar(255) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `vfs_space`
--

DROP TABLE IF EXISTS `vfs_space`;
CREATE TABLE `vfs_space` (
  `sid` bigint(64) NOT NULL auto_increment,
  `sname` varchar(256) NOT NULL,
  `spass` varchar(256) NOT NULL,
  `sip` varchar(64) NOT NULL COMMENT 'ip of server',
  `shome` varchar(256) NOT NULL default 'homedir' COMMENT 'home dir of each user',
  `surl` varchar(512) NOT NULL,
  `squota` bigint(64) NOT NULL default '10737418240',
  `stype` smallint(4) NOT NULL default '0',
  `sflag` smallint(4) NOT NULL default '0',
  `group` tinyint(11) NOT NULL default '0',
  PRIMARY KEY  (`sid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=7887 ;

-- --------------------------------------------------------

--
-- Table structure for table `vfs_user_spacemap`
--

DROP TABLE IF EXISTS `vfs_user_spacemap`;
CREATE TABLE `vfs_user_spacemap` (
  `id` int(11) NOT NULL,
  `sid` bigint(64) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `vfs_community_spacemap`
--

DROP TABLE IF EXISTS `jvfs_community_spacema`;
CREATE TABLE `vfs_community_spacemap` (
  `comm_id` int(11) NOT NULL,
  `sid` bigint(64) NOT NULL,
  `stype` smallint(4) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

-- 
-- 为原有数据库增加主外键约束
-- 

-- 更改为支持外键的数据库引擎
ALTER TABLE jos_users ENGINE = InnoDB;
ALTER TABLE jos_community_apply ENGINE = InnoDB;
ALTER TABLE jos_community_user ENGINE = InnoDB;
ALTER TABLE jos_community_admin ENGINE = InnoDB;
ALTER TABLE vfs_space ENGINE = InnoDB;
ALTER TABLE vfs_user_spacemap ENGINE = InnoDB;
ALTER TABLE vfs_community_spacemap ENGINE = InnoDB;

ALTER TABLE jos_community_admin
ADD CONSTRAINT fk_jos_commu_admin_userid
FOREIGN KEY (userid) REFERENCES jos_users(id) 
ON UPDATE CASCADE;

-- For the table jos_community_apply

ALTER TABLE jos_community_apply 
ADD CONSTRAINT fk_jos_commu_apply_user_id
FOREIGN KEY (id) REFERENCES jos_users(id)
ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE jos_community_apply
ADD CONSTRAINT fk_jos_commu_apply_commu_id
FOREIGN KEY (comm_id) REFERENCES jos_community_admin(comm_id)
ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE jos_community_apply
ADD CONSTRAINT pk_commu_apply
PRIMARY KEY (id, comm_id);

-- For the table jos_community_user

ALTER TABLE jos_community_user
ADD CONSTRAINT fk_jos_commu_user_id
FOREIGN KEY (id) REFERENCES jos_users(id)
ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE jos_community_user
ADD CONSTRAINT fk_jos_commu_user_commu_id
FOREIGN KEY (comm_id) REFERENCES jos_community_admin(comm_id)
ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE jos_community_user
ADD CONSTRAINT pk_jos_commu_user
PRIMARY KEY (comm_id, id);

-- For vfs_community_spacemap

ALTER TABLE vfs_community_spacemap
ADD CONSTRAINT fk_vfs_commu_space_commu_id
FOREIGN KEY (comm_id) REFERENCES jos_community_admin(comm_id)
ON UPDATE CASCADE ON DELETE CASCADE;
  
ALTER TABLE vfs_community_spacemap
ADD CONSTRAINT fk_vfs_commu_space_sid
FOREIGN KEY (sid) REFERENCES vfs_space(sid)
ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE vfs_community_spacemap
ADD CONSTRAINT pk_vfs_community_spacemap
PRIMARY KEY (comm_id, sid);

-- For vfs_user_spacemap

ALTER TABLE vfs_user_spacemap
ADD CONSTRAINT fk_vfs_user_space_id
FOREIGN KEY (id) REFERENCES jos_users(id)
ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE vfs_user_spacemap
ADD CONSTRAINT fk_vfs_user_space_sid
FOREIGN KEY (sid) REFERENCES vfs_space(sid)
ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE vfs_user_spacemap
ADD CONSTRAINT pk_vfs_user_spacemap
PRIMARY KEY (sid, id);

-- 
-- 创建本地用户增补表lmr_user_patch
-- 
# DROP TABLE lmr_user_patch;
CREATE TABLE IF NOT EXISTS lmr_user_patch (
  user_id int(11) NOT NULL PRIMARY KEY,
  phone varchar(20),
  sync_time timestamp NOT NULL,
  FOREIGN KEY (user_id) REFERENCES jos_users(id)
    ON UPDATE CASCADE
    ON DELETE CASCADE 
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- 
-- 创建本地社区增补表lmr_commu_patch
-- 
# DROP TABLE lmr_commu_patch;
CREATE TABLE IF NOT EXISTS lmr_commu_patch (
  community_id int(11) NOT NULL PRIMARY KEY,
  alias varchar(20) NOT NULL,
  email varchar(100) NOT NULL,
  sync_time timestamp NOT NULL,
  FOREIGN KEY (community_id) REFERENCES jos_community_admin(comm_id)
    ON UPDATE CASCADE
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- 
-- 创建本地通讯组表lmr_group
-- 
# DROP TABLE lmr_group;
CREATE TABLE IF NOT EXISTS lmr_group (
  id int unsigned NOT NULL PRIMARY KEY auto_increment,
  name varchar(50) NOT NULL,
  alias varchar(20) NOT NULL,
  owner_id int(11) NOT NULL,
  email varchar(100) NOT NULL,
  description varchar(255),
  create_time datetime NOT NULL,
  is_approved boolean NOT NULL DEFAULT TRUE,
  sync_time timestamp NOT NULL,
  FOREIGN KEY (owner_id) REFERENCES jos_users(id)
    ON UPDATE CASCADE
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- 
-- 创建本地通讯组包含本地社区表lmr_grp_commu
-- 
# DROP TABLE lmr_grp_commu;
CREATE TABLE IF NOT EXISTS lmr_grp_commu (
  group_id int unsigned NOT NULL,
  community_id int(11) NOT NULL,
  description varchar(255),
  create_time datetime NOT NULL,
  is_approved boolean NOT NULL DEFAULT TRUE,
  PRIMARY KEY (group_id, community_id),
  FOREIGN KEY (community_id) REFERENCES jos_community_admin(comm_id)
    ON UPDATE CASCADE
    ON DELETE CASCADE,
  FOREIGN KEY (group_id) REFERENCES lmr_group(id)
    ON UPDATE CASCADE
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- 
-- 创建用户转换后文件的信息表
--
# DROP TABLE lmr_file;
CREATE TABLE IF NOT EXISTS lmr_file (
  id int unsigned NOT NULL PRIMARY KEY auto_increment,
  commu_id int(11) NOT NULL,
  type tinyint NOT NULL,
  host_ip varchar(40) NOT NULL,
  url varchar(255) NOT NULL,
  home_dir varchar(255) NOT NULL,
  FOREIGN KEY (commu_id) REFERENCES jos_community_admin(comm_id)
    ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- -------------------------------------------------------
