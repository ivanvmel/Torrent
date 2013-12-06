package torrent;

import java.io.BufferedReader;
import java.io.File;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.logging.Logger;

// /home/mike/bittorrent-project/Torrent/src/torrent/this.torrent

public class Main {
	
	private final static Logger LOGGER = Logger.getLogger(Main.class .getName()); 

	/**
	 * In this main driver method, we alternate between reading input from the command line
	 * and uploading files to peers who are asking us for stuff.  We commence the download
	 * routine when prompted.
	 * @param args
	 */
	public static void main(String[] args) {
		System.out.println("Type 'help' for list of commands.\n");
		System.out.print("> ");

		// Infinite loop, alternates between parsing command line input and seeding.
		while(true) {
			
			/**** 1. Parse input. ****/
			BufferedReader input = new BufferedReader(new InputStreamReader(System.in));

			try {
				if (input.ready()) {
					String[] cmds = input.readLine().trim().split(" ");
					if (cmds[0].equalsIgnoreCase("help")) {
						printHelp();
					} else if (cmds[0].equalsIgnoreCase("download")) {
						System.out.print("download filler...\n> ");
						download(cmds[1]);
					} else if (cmds[0].equalsIgnoreCase("exit") || cmds[0].equalsIgnoreCase("quit")) {
						return;
					} else {
						// Didn't type a valid command, help out the user.
						System.out.println("Improper usage!");
						printHelp();
					}
				}
			} catch (IOException e) {
				System.err.println("Exception: " + e);
				e.printStackTrace();
			}


		}


	}




	
	
	private static void printHelp() {
	System.out.println("List of commands:\nhelp\nquit\ndownload <torrent file>\n");	
	System.out.print("> ");
	}
	
	
	
	
	/** 
	 * This method attempts to download the given torrent.
	 * @param fileNameString the name of the torrent file (metainfo file) whose stuff we are trying
	 * to download.
	 */
	private static void download(String fileNameString) {
		if (fileNameString == null) {
			System.err.println("in main.download(); arg null");
			return;
		}
		
		System.out.println(System.getProperty("user.dir"));
		Metainfo metainfo = new Metainfo(fileNameString);
		
		System.out.println(metainfo.trackersToSring());
		System.out.println(metainfo.getInfoHash(fileNameString));
		
	}


}
