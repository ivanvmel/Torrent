package torrent;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.Formatter;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

import org.ardverk.coding.BencodingInputStream;

public class TorrentFileProcessor {

	public static String[] getTrackers(String torrentLocation) {

		FileInputStream torrentFileStream = null;
		BencodingInputStream tBencodeStream = null;
		LinkedList<String> trackers = new LinkedList<String>();

		try {

			torrentFileStream = new FileInputStream(torrentLocation);
			tBencodeStream = new BencodingInputStream(torrentFileStream, true);

			Map<String, ?> tMap = tBencodeStream.readMap();
			List<?> tList = (List<?>) tMap.get("announce-list");

			/* Do we have an announce list to dig through ? */

			if (tList != null) {
				for (int i = 0; i < tList.size(); i++) {

					List<?> innerTList = (List<?>) tList.get(i);

					for (int j = 0; j < innerTList.size(); j++)
						trackers.add((String) innerTList.get(j));
				}
			}

			String announceTracker = (String) tMap.get("announce");

			if (announceTracker != null && !tList.contains(announceTracker))
				trackers.add(announceTracker);

		} catch (FileNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} finally {
			try {
				torrentFileStream.close();
				tBencodeStream.close();
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}

		return trackers.toArray(new String[trackers.size()]);
	}

	public static String getInfoHash(String torrentLocation) {

		File tFile = new File(torrentLocation);
		MessageDigest sha1 = null;
		InputStream tInputStream = null;
		StringBuffer tSBuff = null;
		ByteArrayOutputStream tOutput = null;
		Formatter formatter = null;
		String stringHash = null;

		try {

			sha1 = MessageDigest.getInstance("SHA-1");
			tOutput = new ByteArrayOutputStream();
			tInputStream = new FileInputStream(tFile);
			tSBuff = new StringBuffer();

			/* Read until info */
			while (!tSBuff.toString().endsWith("4:info"))
				tSBuff.append((char) tInputStream.read());

			int currByte;
			while ((currByte = tInputStream.read()) != -1)
				tOutput.write(currByte);

			/* Calculate SHA-1 */
			sha1.update(tOutput.toByteArray(), 0, tOutput.size() - 1);
			byte[] byteHash = sha1.digest();

			formatter = new Formatter();

			/* Format into hex */
			for (byte b : byteHash) {
				formatter.format("%02x", b);
			}

			stringHash = formatter.toString();

		} catch (NoSuchAlgorithmException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (FileNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} finally {

			try {
				tInputStream.close();
				formatter.close();
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}

		return stringHash;
	}

}
