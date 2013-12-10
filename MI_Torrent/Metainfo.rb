require './bencode.rb'
require 'digest/sha1'

class Metainfo
  
  attr_accessor :trackers, :info_hash
  
  @trackers
  @info_hash
  @piece_length
  @pieces
  @name
  
  
  def initialize(file_location)
    
    #################################################
    # IMPORTANT, CURRENTLY NOT ADDING UDP TRACKERS ##
    #################################################
    
    # get the trackers
    
    @trackers = Array.new
    
    dict = BEncode::load(File.new(file_location))
    
    # store the torrent name
    @name = dict["info"]["name"]
    
    #puts @name  
    #puts dict.inspect
    
    #exit
    if dict["announce"] != nil and not dict["announce"].include?("udp") then
      @trackers.push(dict["announce"])
    end
      
    if dict["announce-list"] != nil then 
      dict["announce-list"].each{|t| if not (t[0].include?("udp")) then @trackers.push(t[0]) end}
    end
    
    # make sure that we do not have two copies of announce
    @trackers.uniq!
    
    # compute the info hash here
    
    @info_hash =  Digest::SHA1.digest(dict["info"].bencode)
    #puts "HASH : " + Digest::SHA1.hexdigest(dict["info"].bencode)
      
    if(@trackers.size == 0) then
      puts "Zero trackers. Cannot proceed. Exiting."
      exit
    end
    
  end
  
end


