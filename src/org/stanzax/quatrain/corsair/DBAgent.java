/**
 * 
 */
package org.stanzax.quatrain.corsair;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

/**
 * @author basicthinker
 *
 */
public class DBAgent {
	
	public DBAgent(String url, String dbName, String user, String password) {
		this.url = url.endsWith("/") ? url : url + "/";
		this.user = user;
		this.password = password;
		this.lmrDBName = dbName;
		this.smrConn = null;
		this.lmrConn = null;
	}
	
	public void connect() throws SQLException, ClassNotFoundException {
		if (smrConn == null) {
			smrConn = DriverManager.getConnection(url + smrDBName, user, password);
		}
		if (lmrConn == null) {
			lmrConn = DriverManager.getConnection(url + lmrDBName, user, password);
		}
	}
	
	public void close() {
		if (lmrConn == null) return;
		try {
			lmrConn.close();
		} catch (SQLException e) {
			e.printStackTrace();
		}
	}
	
	public String getDBName() {
		return lmrDBName;
	}
	
	/**
	 * for SMR
	 * */
	public String[] getGroupExternalCommu(String lmrName, int grpID) {
		try {
			CallableStatement cs = smrConn.prepareCall(
					"{call sp_fetch_grp_xtnl_commu(?, ?)}",
					ResultSet.TYPE_SCROLL_INSENSITIVE,
					ResultSet.CONCUR_READ_ONLY);
			cs.setString(1, lmrName);
			cs.setInt(2, grpID);
			ResultSet rs = cs.executeQuery();
			rs.last();
			String[] results = new String[rs.getRow()];
			rs.beforeFirst();
			int i = 0;
			while (rs.next()) {
				results[i] = rs.getString("local_id") + "@" + rs.getString("ip_address");
				++i;
			}
			rs.close();
			cs.close();
			return results;
		} catch (SQLException e) {
			e.printStackTrace();
			return null;
		}
	}
	
	/**
	 * for LMR
	 *  */
	public Integer[] getLocalGroupList() {
		try {
			Statement stmt = lmrConn.createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE,
					ResultSet.CONCUR_READ_ONLY);
			ResultSet rs = stmt.executeQuery("SELECT id FROM lmr_group");
			rs.last();
			Integer[] results = new Integer[rs.getRow()];
			rs.beforeFirst();
			int i = 0;
			while (rs.next()) {
				results[i] = rs.getInt(1);
				++i;
			}
			rs.close();
			stmt.close();
			return results;
		} catch (SQLException e) {
			e.printStackTrace();
			return null;
		}
	}
	
	/**
	 * for LMR
	 * */
	public String[] getCommuLocalUserPhone(int commuID) {
		try {
			CallableStatement cs = lmrConn.prepareCall(
					"{call sp_fetch_user_phone_by_commu(?)}",
					ResultSet.TYPE_SCROLL_INSENSITIVE,
					ResultSet.CONCUR_READ_ONLY);
			cs.setInt(1, commuID);
			ResultSet rs = cs.executeQuery();
			rs.last();
			String[] results = new String[rs.getRow()];
			rs.beforeFirst();
			int i = 0;
			while (rs.next()) {
				results[i] = rs.getString(1);
				++i;
			}
			rs.close();
			cs.close();
			return results;
		} catch (SQLException e) {
			e.printStackTrace();
			return null;
		}
	}
	
	/**
	 * for LMR
	 * */
	public String[] getGroupLocalUserPhone(int grpID) {
		try {
			CallableStatement cs = lmrConn.prepareCall(
					"{call sp_fetch_user_phone_by_grp(?)}",
					ResultSet.TYPE_SCROLL_INSENSITIVE,
					ResultSet.CONCUR_READ_ONLY);
			cs.setInt(1, grpID);
			ResultSet rs = cs.executeQuery();
			rs.last();
			String[] results = new String[rs.getRow()];
			rs.beforeFirst();
			int i = 0;
			while (rs.next()) {
				results[i] = rs.getString(1);
				++i;
			}
			rs.close();
			cs.close();
			return results;
		} catch (SQLException e) {
			e.printStackTrace();
			return null;
		}
	}
	
	private String url;
	private String lmrDBName;
	private final String smrDBName = "corsair_smr";
	private String user;
	private String password;
	private Connection smrConn;
	private Connection lmrConn;
	
	public static void main(String[] args) {
		String dbName = "corsair_lmr_1";
		DBAgent db = new DBAgent("jdbc:MySql://localhost", dbName, "root", "tsinghua");
		try {
			db.connect();
			db.getGroupExternalCommu("10.0.1.218", 3);
			db.getLocalGroupList();
			db.getCommuLocalUserPhone(123494);
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			db.close();
		}
	}
}
