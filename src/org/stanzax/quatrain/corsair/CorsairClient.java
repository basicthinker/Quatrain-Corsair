/**
 * 
 */
package org.stanzax.quatrain.corsair;

import java.io.File;
import java.io.IOException;
import java.io.PrintStream;
import java.net.InetAddress;
import java.util.ArrayList;
import java.util.Collections;

import org.stanzax.quatrain.client.MrClient;
import org.stanzax.quatrain.client.ReplySet;
import org.stanzax.quatrain.hprose.HproseWrapper;

/**
 * @author basicthinker
 *
 */
public class CorsairClient {

	public CorsairClient(InetAddress host, int port,
			long timeout, PrintStream log) throws IOException {
		this.remote = new MrClient(host, port, new HproseWrapper(), timeout);
		this.log = log;
	}
	
	public double evaQuery() {
		ReplySet groups = remote.invoke(Integer.class, "GetLocalGroupList");
		Integer groupID;
		ArrayList<Integer> groupList = new ArrayList<Integer>();
		while ((groupID = (Integer) groups.nextElement()) != null) {
			groupList.add(groupID);
		}
		groups.close();
		
		double totalTime = 0;
		int grpCnt = 0;
		for (Integer group : groupList) {
			totalTime += evaInvoke("GetGroupAllUserPhone", group);
			++grpCnt;
		} 
		return totalTime / grpCnt;
	}

	private double evaInvoke(String method, int grpID) {
		double avg = 0;
		double beginTime = System.currentTimeMillis();
		ReplySet phones = remote.invoke(
				String.class, method, grpID);
		String phone;
		ArrayList<String> phoneList = new ArrayList<String>();
		while ((phone = (String) phones.nextElement()) != null) {
			if (phone.length() == 11) {
				avg += System.currentTimeMillis() - beginTime;
				phoneList.add(phone);
			} else {
				System.err.println("@CorsairClient.evaQuery: wrong phone " + phone);
			}
		}
		phones.close();
		
		if (phoneList.isEmpty()) {
			avg = System.currentTimeMillis() - beginTime;
		} else {
			avg /= phoneList.size();
		}
		
		log.print(grpID + "\t");
		log.print(phoneList.size() + "\t" + avg + "\t");
		Collections.sort(phoneList); // for convenience of correctness verification
		for (String element : phoneList) {
			log.print("\t" + element);
		}
		log.println();
		
		return avg;
	}
	
	private MrClient remote;
	private PrintStream log;
	
	/**
	 * @param args
	 * 	args[0] Remote server address
	 * 	args[1]	Remote port number
	 * 	args[2]	Timeout
	 */
	public static void main(String[] args) {
		int port = Integer.valueOf(args[1]);
		long timeout = Long.valueOf(args[2]);
		try {
			PrintStream log = new PrintStream(
					new File("corsair-client-" + args[0] + "@" + (int)System.currentTimeMillis()));
			log.println("# GroupID\tPhoneCount\tAvgResponseTime\t\tPhoneList");
			
			CorsairClient client = new CorsairClient(
					InetAddress.getByName(args[0]), port, timeout, log);
			
			Double latency = client.evaQuery();
			log.close();
			
			System.out.println(latency.toString());
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

}
