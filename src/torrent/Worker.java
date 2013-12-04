package torrent;

public class Worker {

	public static void main(String [] args){
		
		String torrentLocation = "/Users/ivm/Desktop/X13/imelyako_assignment03/torrents/1.torrent";
		String hash = TorrentFileProcessor.getInfoHash(torrentLocation);
		System.out.println(hash);
		
		for(String tracker: TorrentFileProcessor.getTrackers(torrentLocation)){
			System.out.println(tracker);
		}
	
	}
}
