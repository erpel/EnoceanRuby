Prepare your Raspberry PI
=========================

Install 
--------
 * ruby
 * git
 * sqlite3
 * ruby-dev
 * libsqlite3-dev

Install Gems:
-------------
 * gem install bundler
 * bundle install


~~ 
Run it with:
 * bundle exec ./main.rb
~~

Note: haven't tested above methods, they might not work any more for the current code base

Reading the base ID from your TM300
-----------------------------------
Run bundle exec sniff.rb

It will start the framework in sniffing mode and will output all packets it can decode. Also as a first packet it will send the base_id reading command to the USB TM300.


Simulating an PTM200 Rocker Switch 
----------------------------------

 * bundle exec ./send_rocker_switch.rb
 * you will drop to the debug console and can continue with switch.on, switch.off... the source gives a good idea

 
 
