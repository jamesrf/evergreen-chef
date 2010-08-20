require 'rubygems'
require 'erubis'
input = File.read('ejabberd.cfg.erb')
eruby = Erubis::FastEruby.new(input)    # create Eruby object

puts "---------- script source ---"

puts "---------- result ----------"
context = { :jabber_hosts=>['localhost','private.localhost','public.localhost'],
            :max_rate => 299,
            :max_user_sessions => 999,
            :max_stanza_size => 666 }
output = eruby.evaluate(context)
print output

