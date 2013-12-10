require './bencode.rb'
require 'Metainfo.rb'
require 'Peer.rb'
require 'net/http'
require 'uri'
require 'digest/sha1'

@peer_id = "MI000167890123456789"

def get_peers(meta_info_file)

  tracker_list = meta_info_file.trackers
  peers = Array.new

  # for each tracker, get the peer list

  tracker_list.each{|tracker|

    # parameter hash table
    params = Hash.new

    #encoded = URI.escape(meta_info_file.info_hash, Regexp.new("[^#{URI::PATTERN::UNRESERVED.gsub('.','')}]"))

    # fill out the parameter hash
    params["info_hash"] = meta_info_file.info_hash
    params["numwant"] = 50
    params["peer_id"] = @peer_id
    params["compact"] = 1
    params["left"] = 1
    params["uploaded"] = 0
    params["downloaded"] = 0
    params["port"] = 6881
    params["event"] = "started"

    begin

      # create the tracker address
      uri = URI.parse(tracker)
      uri.query = URI.encode_www_form(params)
      #uri.query = "info_hash=4"  + "&"+ uri.query

      #puts uri.query

      # get request
      res = Net::HTTP.get_response(uri)

      # read response
      res_dict = BEncode::load(res.body)

      # get the addresses
      addresses = res_dict["peers"]

      #  puts tracker

      addresses.each_byte.each_slice(6){|slice|

        port = slice[4] * 256
        port += slice[5]

        if port != 0 then

          byte_ip = Array.new
          byte_ip.push(slice[0])
          byte_ip.push(slice[1])
          byte_ip.push(slice[2])
          byte_ip.push(slice[3])

          string_ip = slice[0].to_s() + "." + slice[1].to_s() + "." + slice[2].to_s() + "." + slice[3].to_s()

          # Initialize our peer
          curr_peer = Peer.new(meta_info_file, string_ip, port, byte_ip, @peer_id)

          peers.push(curr_peer)
        end

      }

    rescue
      # nothing to be done here
      puts "Encountered an error with tracker : " + tracker
    end

  }

  if(peers.size() == 0) then
    puts "We have no peers to talk to. Cannot proceed. Exiting."
    exit
  end

  return peers

end

# execution starts here
meta_info_file = Metainfo.new("ubuntu_recent.torrent")
peers = get_peers(meta_info_file)

#peers.each{|peer| puts peer.string_ip + "\t" + peer.port.to_s()}

puts "Number of peers : #{peers.length}"

peers.each{|peer| peer.handshake()}

good_peers = Array.new
peers.each{|peer| if(peer.connected) then good_peers.push(peer) end }

puts "Good peers : #{good_peers.length}"
