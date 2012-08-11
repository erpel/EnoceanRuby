require "enocean"
require 'sqlite3'
require "json"
require "eventmachine"

db = SQLite3::Database.new( "database" )

module EnoceanClient
  def self.list
    @list ||= []
  end

  def post_init
    EnoceanClient.list << self

    dimmers = []
	db.execute("SELECT Id, Name FROM Devices WHERE TypeId = ?", 2) do |row|
    	dimmers << {row[0] => row[1]}
  	end

    self.send_data Hash["Dimmers" => dimmers ].to_json + "\n"
  end
  def unbind
    EnoceanClient.list.delete self
  end

  def receive_data data
  	print "Recieved: ->#{data}<-\n"
=begin
    (@buf ||= '') << data
    while line = @buf.slice!(/(.+)\r?\n/)
      if line =~ %r|^/nick (.+)|
        new_name = $1.strip
        (EnoceanClient.list - [self]).each{ |c| c.send_data "#{@name} is now known as #{new_name}\n" }
        @name = new_name
      elsif line =~ %r|^/quit|
        close_connection
      else
        (EnoceanClient.list - [self]).each{ |c| c.send_data "#{@name}: #{line}" }
      end
    end
=end
  end
end

EM.run{
  EM.start_server '0.0.0.0', 8081, EnoceanClient
}

ESP3::Gateway.connect("/dev/tty.usbserial-FTVBI8RQ") do |gw|
	
	qRadio = Queue.new
	qResponse = Queue.new
	#qEvent = Queue.new

	# build dict based on packet type

	queues = {ESP3::Radio.typeId => qRadio, 
                    ESP3::Response.typeId => qResponse, 
                    'default'=> qResponse}      # default queue for unknown packet types
	
	gw.startRadioReciever(queues)

	#gw.sendPacket(ESP3::CommonCommand.withCommand(0x08))
	

	#data = [0xF6, 0x70, 0xFF, 0xCA, 0xF7, 0x00, 0x30]

	#gw.sendPacket(ESP3::Radio.fromData(data))

	#bathroomRocker = ESP3::Ptm200.new([0xFF, 0xCA, 0xF7, 0x00])
	#gw.sendPacket(bathroomRocker.up)

	loop {
		packet = qRadio.pop

		print packet

		begin
			deviceType = 0
			db.execute("SELECT TypeId FROM Devices WHERE id = ?", packet.senderId) do |row|
    			deviceType = row[0]
  			end
			if deviceType == 3
    			state = packet.datadata.first == 0x10 ? 1 : 0
    			db.execute("UPDATE PTM330States SET Up = ? WHERE id = ?", state,packet.senderId)
    		elsif deviceType == 2
    			if packet.rorg == 0x05
    				state = packet.datadata.first == 0x70 ? 1 : 0
    				db.execute("UPDATE DimmerStates SET LightsOn = ? WHERE id = ?", state, packet.senderId)
    				puts "#{packet.senderId}: #{state}"
    			elsif packet.rorg == 0xA5
    				value = packet.datadata[1]
    				state = packet.datadata.last == 0x09 ? 1 : 0
    				db.execute("UPDATE DimmerStates SET LightsOn = ?,DimValue = ?  WHERE id = ?", state, value,packet.senderId)
    				puts "#{packet.senderId}: #{state}, #{value}"
    			end
    		end

		rescue Exception => e
			puts e
		end
	}
	
end
