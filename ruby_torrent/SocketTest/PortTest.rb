require './bencode.rb'
require 'net/http'
require 'uri'
require 'digest/sha1'

dict = BEncode::load(File.new("ubuntu_recent.torrent"))

info_hash =  Digest::SHA1.digest(dict["info"].bencode)

params = {:info_hash => info_hash,
  :numwant => 5, :peer_id => "ivanivanivanivanivan", :compact => 1, :left => 1, :uploaded => 0, 
  :downloaded => 0, :port => 344, :event => "started"}
  
  
uri = URI.parse("http://torrent.ubuntu.com:6969/announce")
uri.query = URI.encode_www_form(params)

res = Net::HTTP.get_response(uri)

res_dict = BEncode::load(res.body)

addresses = res_dict["peers"]

addresses.each_byte.each_slice(6){|slice| p slice}

