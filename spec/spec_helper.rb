require_relative '../lib/enocean'


def serialized_packet(header, data)
  [ 0x55 ] + header + [ crc8(header) ] + data + [ crc8(data) ]
end