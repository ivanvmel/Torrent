require 'timeout'
require './Message.rb'

class Peer

  attr_accessor :string_ip, :byte_ip, :port, :info_hash, :connected, :bitfield
  def initialize(meta_info_file, string_ip, port, byte_ip, peer_id)

    # keep_alive has an id of -1, it is treated specially for our implementation - it's length is zero
    @keep_alive_id = -1

    # these do not have a payload
    @choke_id = 0
    @unchoke_id = 1
    @interested_id = 2
    @not_interested_id = 3

    # these have a payload
    @have_id = 4
    @bitfield_id = 5
    @request_id = 6
    @piece_id = 7
    @cancel_id = 8
    @port_id = 9

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
          #puts "wrong info hash #{@meta_info_file.top_level_directory}"
          $stdout.flush
          Thread.terminate
        else
          #puts "correct info hash #{@meta_info_file.top_level_directory}"
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

      debug = 1

      begin

        Timeout::timeout(@timeout_val){

          length = 0
          id = 0
          data = @socket.recv(4)

          # make sure we actually got something
          if data == nil then return nil end

          # how many more bytes we are to recv
          length += data.each_byte.to_a[0] * (2 ** 24)
          length += data.each_byte.to_a[1] * (2 ** 16)
          length += data.each_byte.to_a[2] * (2 ** 8)
          length += data.each_byte.to_a[3]

          additional_data = @socket.recv(length)

          # if you are not sending as much data as you advertise, we drop you
          if(additional_data.each_byte.to_a.length != length) then Thread.terminate end

          if(debug) then
            puts "length of data to be recvd : #{length}"
            puts "length of data recv'd      : #{additional_data.each_byte.to_a.length}"
          end

          if(length != 0) then
            message_id = additional_data.each_byte.to_a[0]
          else
            message_id = -1
          end

          puts "message starts"

          new_message = Message.new(message_id, length, additional_data[1...additional_data.length])

          puts "message end"

          case message_id
          when @keep_alive_id
            puts "I got a keep_alive id"
          when @choke_id
            puts "I got choke id"
          when @unchoke_id
            puts "I got unchoke_id"
          when @interested_id
            puts "I got interested_id"
          when @not_interested_id
            puts "I got not_interested_id"
          when @have_id
            puts "I got have_id"
          when @bitfield_id
            puts new_message.payload().each_byte.to_a.length
            @bitfield.set_bitfield_with_bitmap(new_message.payload())
            puts "I got bitfield_id"
          when @request_id
            puts "I got request_id"
          when @piece_id
            puts "I got piece_id"
          when @cancel_id
            puts "I got cancel_id"
          when @port_id
            puts "I got port_id"
          else
            puts "You gave me #{message_id} -- I have no idea what to do with that."
          end

          $stdout.flush

        }

      rescue
        #puts $!, $@
        return
      end

    end

  end

  # Class ends here

end

