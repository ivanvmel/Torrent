require 'timeout'

class Peer

  attr_accessor :string_ip, :byte_ip, :port, :info_hash, :connected, :bitfield
  def initialize(meta_info_file, string_ip, port, byte_ip, peer_id)
    @meta_info_file = meta_info_file
    @pstr = "BitTorrent protocol"
    @pstrlen = "\x13"
    @reserved = "\x00\x00\x00\x00\x00\x00\x00\x00"
    @string_ip = string_ip
    @port = port
    @byte_ip = byte_ip
    @peer_id = peer_id
    @info_hash = meta_info_file.info_hash
    @handshake_info = "\x13BitTorrent protocol\x00\x00\x00\x00\x00\x00\x00\x00#{info_hash}#{peer_id}"
    @bitfield = Bitfield.new(meta_info_file.num_pieces)

    @connected = false

    @peer_choked = true
    @peer_interested = false
    @client_choked = true
    @client_interested = true

    @timeout_val = 5

    @DEBUG = 0

    if @DEBUG == 1 then
      puts "--- PEER CONSTRUCTED ---"
      puts "pstr      : #{@pstr}"
      puts "pstrlen   : #{@pstrlen}"
      puts "reserved  : #{@reserved}"
      puts "info_hash : #{@info_hash}"
      puts "peer_id   : #{@peer_id}"
      puts "string_ip : #{@string_ip}"
      puts "byte_ip   : #{@byte_ip}"
      puts "port      : #{@port}"
      puts "handshake : #{@handshake_info}"
      puts "--- PEER CONSTRUCTED ---"
    end

  end

  def handshake()

    begin

      Timeout::timeout(@timeout_val){
        @socket = TCPSocket.new(@string_ip, @port)
        @socket.write @handshake_info

        handshake = @socket.read 68

        if(handshake[28..47] != @info_hash) then
          puts "wrong info hash #{@meta_info_file.top_level_directory}"
          $stdout.flush
          return
        else
          puts "correct info hash #{@meta_info_file.top_level_directory}"
          $stdout.flush
        end

        @connected = true

      }

    rescue
     # puts "could not connect to : " + @string_ip
      #$stdout.flush
    end

  end

  def send_interested()

    interested = "\x00\x00\x00\x01\x02"

    begin

      Timeout::timeout(@timeout_val){

        @socket.write(interested)

      }

    rescue
      puts "could not send_interested() to : " + @string_ip
    end

  end

  # Class ends here

end

