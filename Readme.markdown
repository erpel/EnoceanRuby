
Install 
--------
 * ruby
 * git

Install Gems:
-------------
 * gem install bundler
 * bundle install
 
The file main.rb is kept here for reference if you would like to run the packet reading/writing in event machine. I just used it for testing the enocean packets with my actors before then trying to do the same thing in openHAB.


Reading the base ID from your TM300
-----------------------------------
Run bundle exec sniff.rb

It will start the framework in sniffing mode and will output all packets it can decode. Also as a first packet it will send the base_id reading command to the USB TM300 and display the baseId.


Simulating an PTM200 Rocker Switch 
----------------------------------
 * modify the source and choose a sender address that is part of your baseId 
 * bundle exec ./rocker_switch.rb
 * you will drop to the debug console and can continue with switch.on, switch.off... the source gives a good idea
 

Setting dimming values for a Eltak FUD61NPN with A5-38-08 CMD2 
--------------------------------------------------------------
 * modify the source and choose a sender address that is part of your baseId
 * bundle exec ./dimmer.rb
 * read the source, you will be dropped to a debug prompt
 * first time, you need to set your dimmer to RLC and LEARN mode
 * send the teach in packet
 * set the dimmer back to normal
 * now you can go with dimmer.set(xxx)


Links
-----

Further readings are:
 * Enocean EEP 2.6.3  (Enocean Equipment Profiles) https://www.enocean.com/fileadmin/redaktion/enocean_alliance/pdf/EnOcean_Equipment_Profiles_EEP_V2.6.3_public.pdf
 * Enocean Serial Protocol 3 https://www.enocean.com/fileadmin/redaktion/pdf/tec_docs/EnOceanSerialProtocol3.pdf
 * Eltako Actor commands ( http://www.eltako.com/fileadmin/downloads/en/_catalogue/wireless_system_chapterT_high_res.pdf )


 
 
