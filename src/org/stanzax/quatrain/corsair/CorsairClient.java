/**
 * 
 */
package org.stanzax.quatrain.corsair;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.net.InetAddress;
import java.util.ArrayList;

import org.stanzax.quatrain.client.MrClient;
import org.stanzax.quatrain.client.ReplySet;
import org.stanzax.quatrain.hprose.HproseWrapper;

/**
 * @author basicthinker
 *
 */
public class CorsairClient {

	public CorsairClient(InetAddress host, int port,
			long timeout) throws IOException {
		remote = new MrClient(host, port, new HproseWrapper(), timeout);
	}
	
	public double evaQuery() {
		ReplySet groups = remote.invoke(Integer.class, "GetLocalGroupList");
		Integer groupID;
		ArrayList<Integer> groupList = new ArrayList<Integer>();
		while ((groupID = (Integer) groups.nextElement()) != null) {
			groupList.add(groupID);
		}
		groups.close();
		
		double totalTime = 0, caseTime, beginTime;
		int grpCnt = 0;
		for (Integer group : groupList) {
			System.out.print("Group " + group + ": ");
			caseTime = 0;
			beginTime = System.currentTimeMillis();
			ReplySet phones = remote.invoke(
					String.class, "GetGroupAllUserPhone", group);
			String phone;
			int cnt = 0;
			while ((phone = (String) phones.nextElement()) != null) {
				caseTime += System.currentTimeMillis() - beginTime;
				++cnt;
				System.out.print(phone + " ");
			}
			if (cnt != 0) {
				totalTime += caseTime / cnt;
				++grpCnt;
			}
			System.out.println(": avg " + caseTime + " : total " + 
					(System.currentTimeMillis() - beginTime));
		}
		return totalTime / grpCnt;
	}

	private MrClient remote;
	
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
			CorsairClient client = new CorsairClient(
					InetAddress.getByName(args[0]), port, timeout);
			BufferedWriter log = new BufferedWriter(
					new FileWriter(new File("corsair-client-" + args[0])));
			Double latency = client.evaQuery();
			log.write(latency.toString());
			log.close();
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

}
