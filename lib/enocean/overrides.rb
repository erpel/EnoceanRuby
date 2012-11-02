class Array
  def to_hexs
    self.pack("C*").unpack("H*").first
  end      
end