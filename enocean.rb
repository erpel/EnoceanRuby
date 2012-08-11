require 'rubygems'
require "serialport"
require_relative "checksum"
require 'thread'

module ESP3

	class BasePacket
		def initialize(pktType, data, optData = [])
			@pktType = pktType
			@data = data
			@optData = optData
			initFromData
		end

		def initFromData()
		end

		def self.fromData(data = [], optData = [])
			return self.new(typeId, data, optData)
		end

		def header
			header = ([@data.count, @optData.count, @pktType].pack("nCC")).unpack("C*")
			header << crc8(header)
			header.insert(0 , 0x55)
			return header
		end

		def serialize
			pkt = self.header

			if @data.count > 0
				pkt = pkt + @data
			end
			if @optData.count > 0
				pkt = pkt + @optData
			end

			pkt << crc8(@data + @optData)

			return pkt
		end

		def printBaseInfo
			s = "\nESP3 packet type: 0x%02x (%s)\n" % [@pktType, self.class]
			s += "Data length     : %d\n" % @data.length
			s += "Opt. data length: %d\n" % @optData.length
			return s
		end

		def printContent
			return ""
		end

		def to_s
			return self.printBaseInfo + self.printContent
		end

		def self.factory(pktType, data, optData)

			if pktType == Radio.typeId
				return Radio.fromData(data, optData)
			elsif pktType == Response.typeId
				return Response.fromData(data,  optData)
			else
        		# add all other packet type
            	# fall back for unknown packets
            	return BasePacket.new(pktType,  data,  optData)
            end
        end
    end

    class Radio < BasePacket
		
		attr_accessor :senderId, :data, :datadata, :rorg

		def initFromData()
			@rorg = @data[0]
			@datadata = @data[1..-6]
			@senderId = @data[-5..-2].pack("C*").unpack("N").first
			@status = @data[-1]
        	@subTelNum,  @destId,  @dBm,  @securityLevel = @optData.pack("C*").unpack("BNBB") #struct.unpack('>BIBB',  str(self.optData))
        	@repeatCount = @status & 0x0F
        	# T21 and NU flags as tuple
        	@flags = {:t21 => (@status >> 5) & 0x01, :nu => (@status >> 4) & 0x01 }
		end

    	def self.typeId
    		return 0x01
    	end

    	def self.fromData(data = [], optData = [])
    		return self.new(typeId, data, optData)
    	end

    	def printContent
    		s = "**** Data ****\n"  
        	s += "Choice          : 0x#{@rorg.to_s(16)}\n"
        	s += "Data            : 0x#{@datadata.join("-")}\n"     	    
        	s += "Sender ID       : 0x#{@senderId.to_s(16)}\n"
        	s += "Status          : 0x#{@status.to_s(16)}\n"
       	 	s += "**** Optional Data ****\n"
        	if @optData.count > 0
        	    #s +=  'SubTelNum       : {0:d}\n'.format(self.subTelNum)
        	    #s +=  'Destination ID: 0x{0:08x}\n'.format(self.destId)
        	    #s +=  'dBm             : {0:d}\n'.format(self.dBm)
        	    #s +=  'Security Level  : {0:d}\n'.format(self.SecurityLevel)
        	else
        	    #s +=  'None\n'
        	end
        	return s
		end

    end

    class Response < BasePacket

    	def self.typeId
    		return 0x02
    	end


    	def self.fromData(data = [], optData = [])
    		return self.new(typeId, data, optData)
    	end

    end

    class CommonCommand < BasePacket

    	def self.typeId
    		return 0x05
    	end

    	def self.withCommand(cmd, data = [], optData = [])
    		data.insert(0, cmd)
    		return self.new(typeId, data, optData)
    	end

    end

    class Rps < Radio
		
		def self.rorg
    		return 0xf6
    	end

    	def self.fromData(data, sender_id, status, optData = [])
			array = [rorg, data] + sender_id + [status]
			return Radio.fromData(array, optData)
    	end

    end

    class Ptm200

    	def initialize(sender_id)
			@sender_id = sender_id
    	end

    	def up
    		return Rps.fromData(0x70, @sender_id, 0x30)
    	end
    	
    end

    class Gateway

    	def initialize(aPort, aBaudrate = 57600, &block)
    		@sp = SerialPort.new(aPort, aBaudrate)
    		if block_given?
    			yield self
    			disconnect
    		else
    			self
    		end
    	end

    	class << self
    		alias_method :connect, :new
    	end

    	def sendPacket(pkt)
    		spkt = pkt.serialize
			#Send with serialport!!
			@sp.puts spkt.pack("C*")
		end

		def disconnect
			@sp.close
		end

		def recievePacket
			byte = @sp.getbyte


			if byte == 0x55

				header = Array.new(4) { |b| b = @sp.getbyte }

				header_crc = @sp.getbyte

				if header_crc == crc8(header)

					data_length = (header[0] << 8) | header[1]
					data = Array.new(data_length) { |b| b = @sp.getbyte }

					optional_data_length = header[2]
					optional_data = Array.new(optional_data_length) { |b| b = @sp.getbyte }

					packet_type = header[3]

					data_crc = @sp.getbyte

					if data_crc == crc8(data + optional_data)
						return BasePacket.factory(packet_type, data, optional_data)
					end
				end
			end
			
		end

		def startRadioReciever(queues)
			rt = Thread.new do
				loop { 
					pkt = self.recievePacket

					if pkt
						begin
							# try to get queue for packet
							queues[pkt.class.typeId] << pkt
							puts 'Packet on specific queue'
						rescue
							queues['default'] << pkt
							puts 'Packet on default queue'
						end
					end
				}
			end

			return rt
		end

	end
end