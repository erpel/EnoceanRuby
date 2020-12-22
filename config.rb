
if `uname -a`.include?("Linux")
  # Raspberry Pi serial port for Enocean module
  @serial_port = "/dev/ttyAMA0"
else
  # Mac Serial port for USB stick
  @serial_port = "/dev/tty.usbserial-FT41KJ2Y"
end

