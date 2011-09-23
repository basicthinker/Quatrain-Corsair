/**
 * 
 */
package org.stanzax.quatrain.corsair;

import java.io.IOException;
import java.net.InetAddress;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Vector;
import java.util.concurrent.atomic.AtomicInteger;

import org.stanzax.quatrain.client.MrClient;
import org.stanzax.quatrain.client.ReplySet;
import org.stanzax.quatrain.hprose.HproseWrapper;
import org.stanzax.quatrain.io.WritableWrapper;
import org.stanzax.quatrain.server.MrServer;

/**
 * @author basicthinker
 *
 */
public class CorsairServer extends MrServer {

	/**
	 * @param address
	 * @param port
	 * @param wrapper
	 * @param handlerCount
	 * @throws IOException
	 */
	public CorsairServer(String address, int port, WritableWrapper wrapper,
			int handlerCount, DBAgent db, long timeout) throws IOException {
		super(address, port, wrapper, handlerCount);
		this.nodeName = db.getDBName().replace("corsair_lmr_", "UniversityName");
		this.port = port;
		this.db = db;
		this.timeout = timeout;
	}

	public void start() {
		super.start();
		try {
			db.connect();
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
	
	/**
	 * For peers to get local user phone list of target local community
	 * */
	public void GetCommuLocalUserPhone(int commuID) {
		preturn(db.getCommuLocalUserPhone(commuID));
	}
	
	public void GetLocalGroupList() {
		preturn(db.getLocalGroupList());
	}
	
	/**
	 * For clients to get entire user phone list of target group
	 * */	
	public void MrGetGroupAllUserPhone(final int grpID) {
		preturn(db.getGroupLocalUserPhone(grpID));
		String[] commuList = db.getGroupExternalCommu(nodeName, grpID);
		String[] commuPlusAddr;
		for (String commu : commuList) {
			commuPlusAddr = commu.split("@");
			final int commuID = Integer.parseInt(commuPlusAddr[0]);
			final String host = commuPlusAddr[1];
			new Thread(new Runnable() {

				@Override
				public void run() {
					try {
						MrClient remote = new MrClient(
								InetAddress.getByName(host), 
								port, new HproseWrapper(), timeout);
						ReplySet rs = remote.invoke(String.class, "GetCommuLocalUserPhone", commuID);
						ArrayList<String> phones = new ArrayList<String>();
						String phone;
						while ((phone = (String) rs.nextElement()) != null) {
							phones.add(phone);
						}
						preturn(phones.toArray());
						rs.close();
					} catch (IOException e) {
						System.err.println("Calling " + host
								+ ": " + e.getMessage());
					}
				}
				
			}).start();
		}
	}
	
	// The standard version logs local and external phone count.
	public void GetGroupAllUserPhone(final int grpID) {
		final AtomicInteger endCount = new AtomicInteger();
		final Vector<String> phones = new Vector<String>(
				Arrays.asList(db.getGroupLocalUserPhone(grpID)));
		
		StringBuilder log = new StringBuilder("Group ").append(grpID).append(':');
		log.append(phones.size()).append('@').append(System.currentTimeMillis()).append('/');
		
		final String[] commuList = db.getGroupExternalCommu(nodeName, grpID);
		String[] commuPlusAddr;
		for (String commu : commuList) {
			commuPlusAddr = commu.split("@");
			final int commuID = Integer.parseInt(commuPlusAddr[0]);
			final String host = commuPlusAddr[1];
			new java.lang.Thread(new Runnable() {

				@Override
				public void run() {
					try {
						MrClient remote = new MrClient(
								InetAddress.getByName(host), 
								port, new HproseWrapper(), timeout);
						ReplySet rs = remote.invoke(String.class, "GetCommuLocalUserPhone", commuID);
						String phone;
						while ((phone = (String) rs.nextElement()) != null) {
							phones.add(phone);
						}
						rs.close();
					} catch (IOException e) {
						System.err.println("Calling " + host
								+ ": " + e.getMessage());
					} finally {
						int current = endCount.incrementAndGet();
						if (current == commuList.length) {
							synchronized(CorsairServer.this) {
								CorsairServer.this.notifyAll();
							}
						}
					}
				}
				
			}).start();
		}
		
		synchronized(this) {
			while (endCount.get() < commuList.length) {
				try {
					wait();
				} catch (InterruptedException e) {
					e.printStackTrace();
				}
			}
		}
		
		preturn(phones.toArray());
		log.append(phones.size()).append('@').append(System.currentTimeMillis());
		System.out.println(log.toString());
	}
	
	private DBAgent db;
	private long timeout;
	String nodeName;
	int port;
	
	/**
	 * @param args
	 * 	args[0] Server IP
	 * 	args[1]	Port number
	 * 	args[2]	Count of worker threads
	 * 	args[3]	DB name
	 * 	args[4]	DB user name
	 * 	args[5]	DB password
	 * 	args[6] Timeout
	 */
	public static void main(String[] args) {
		int port = Integer.valueOf(args[1]);
		int handlerCnt = Integer.valueOf(args[2]);
		long timeout = Long.valueOf(args[6]);
		DBAgent db = new DBAgent("jdbc:MySql://localhost", args[3], args[4], args[5]);
		try {
			CorsairServer server = new CorsairServer(
					args[0], port, new HproseWrapper(), handlerCnt, 
					db, timeout);
			server.start();
		} catch (IOException e) {
			e.printStackTrace();
		}
	}

}
