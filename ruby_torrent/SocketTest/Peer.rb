require 'timeout'

class Peer

  attr_accessor :string_ip, :byte_ip, :port, :info_hash, :connected
  
  def initialize(meta_info_file, string_ip, port, byte_ip, peer_id)
    @pstr = "BitTorrent protocol"
    @pstrlen = "\x13"
    @reserved = "\x00\x00\x00\x00\x00\x00\x00\x00"
    @string_ip = string_ip
    @port = port
    @byte_ip = byte_ip
    @peer_id = peer_id
    @info_hash = meta_info_file.info_hash
    @handshake_info = "\x13BitTorrent protocol\x00\x00\x00\x00\x00\x00\x00\x00#{info_hash}#{peer_id}"
    @connected = false
    @peer_choked = true
    @peer_interested = false
    @client_choked = true
    @client_interested = true

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

      Timeout::timeout(1){
        @socket = TCPSocket.new(@string_ip, @port)
        @socket.write @handshake_info
        handshake = @socket.read 68
        @connected = true
      }

    rescue
      puts "could not connect to : " + @string_ip
    end

  end

  # Class ends here

end

