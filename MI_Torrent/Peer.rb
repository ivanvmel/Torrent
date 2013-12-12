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

    @peer_choking = true
    @peer_interested = false
    @am_choking = true
    @am_interested = true

    @timeout_val = 10

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
      # $stdout.flush
    end

    # documentation :
    # this method receives a message from the peer and parses the message
    # said message returns a message data structure, return nil if timeout

    def recv_msg()

      begin

        Timeout::timeout(@timeout_val){

          length = 0
          id = 0
          data = @socket.recv(202)

          # make sure we actually got something
          if data == nil then return nil end

          length += data.each_byte.to_a[0] * (2 ** 24)
          length += data.each_byte.to_a[1] * (2 ** 16)
          length += data.each_byte.to_a[2] * (2 ** 8)
          length += data.each_byte.to_a[3]

          id = data.each_byte.to_a[4]

          temp = Bitfield.new(data.length - 5)
          bitmap_string = data.byteslice(5, data.length)
          temp.set_bitfield_with_bitmap(bitmap_string)
          #puts temp.bitfield().inspect
          puts temp.struct_to_ones_and_zeroes()
          puts "Byte 5 is : #{id}"
          puts "Length is : #{temp.bitfield().length}"
          $stdout.flush
          
          case length

          when 0
            puts "0"
          when 1
            puts "1"
          when 3
            puts "3"
          when 5
            puts "5"
          when 13
            puts "13"
          else
            puts length
          end

          $stdout.flush

        }

      rescue # Timeout::Error
        puts "Yo - timed out on recv message"
        return nil
      end

    end

  end

  # Class ends here

end

