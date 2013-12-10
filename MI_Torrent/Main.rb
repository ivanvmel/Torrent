require './bencode.rb'
require 'Metainfo.rb'
require 'Peer.rb'
require 'net/http'
require 'uri'
require 'digest/sha1'
require 'fileutils'


meta_info_files = Array.new

# we take a comma separated list of trackers
torrents = ["md.torrent"]
  
# for each tracker, get an associated meta-info file
torrents.each{|torrent|
  meta_info_files.push(Metainfo.new(torrent))
}
