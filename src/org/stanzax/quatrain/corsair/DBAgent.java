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

import org.stanzax.quatrain.server.MrServer;

/**
 * @author basicthinker
 *
 */
public class DBAgent {
	/* User API for evaluation */
	public void GetGroupAllUserPhone(int grpID) {
		System.out.println(getGroupLocalUserPhone(grpID).length);
		
	}
	
	/* for SMR */
	public void GetGroupExternalCommu(String lmrIP, int grpID) {
		try {
			CallableStatement cs = conn.prepareCall(
					"{call sp_fetch_grp_xtnl_commu(?, ?)}",
					ResultSet.TYPE_SCROLL_INSENSITIVE,
					ResultSet.CONCUR_READ_ONLY);
			cs.setString(1, lmrIP);
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
			System.out.println(results.length);
			rs.close();
			cs.close();
		} catch (SQLException e) {
			e.printStackTrace();
		}
	}
	
	/* for LMR */
	public void GetLocalGroupList() {
		try {
			Statement stmt = conn.createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE,
					ResultSet.CONCUR_READ_ONLY);
			ResultSet rs = stmt.executeQuery("SELECT id FROM lmr_group");
			rs.last();
			int[] results = new int[rs.getRow()];
			rs.beforeFirst();
			int i = 0;
			while (rs.next()) {
				results[i] = rs.getInt(1);
				++i;
			}
			rs.close();
			stmt.close();
			System.out.println(results.length);
		} catch (SQLException e) {
			e.printStackTrace();
		}
	}
	
	public void GetCommuLocalUserPhone(int commuID) {
		try {
			CallableStatement cs = conn.prepareCall(
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
			System.out.println(results.length);
		} catch (SQLException e) {
			e.printStackTrace();
			System.out.println("NULL");
		}
	}
	
	private String[] getGroupLocalUserPhone(int grpID) {
		try {
			CallableStatement cs = conn.prepareCall(
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
	
	private DBAgent(String url, String dbName, String user, String password) {
		this.url = url.endsWith("/") ? url + dbName : url + "/" + dbName;
		this.user = user;
		this.password = password;
		this.conn = null;
	}
	
	private void connect() throws SQLException, ClassNotFoundException {
		if (conn == null) {
			conn = DriverManager.getConnection(url, user, password);
		}
	}
	
	private void close() {
		if (conn == null) return;
		try {
			conn.close();
		} catch (SQLException e) {
			e.printStackTrace();
		}
	}
	
	private String url;
	private String user;
	private String password;
	private Connection conn;
	
	public static void main(String[] args) {
		String dbName = "corsair_lmr_2";
		DBAgent lmr = new DBAgent("jdbc:MySql://localhost", dbName, "root", "tsinghua");
		DBAgent smr = new DBAgent("jdbc:MySql://localhost", "corsair_smr", "root", "tsinghua");
		try {
			smr.connect();
			smr.GetGroupExternalCommu("10.0.1.218", 3);
			
			lmr.connect();
			lmr.GetLocalGroupList();
			lmr.GetGroupAllUserPhone(3);
			lmr.GetCommuLocalUserPhone(123494);
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			smr.close();
			lmr.close();
		}
	}
}
