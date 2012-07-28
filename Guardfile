guard 'shell' do
  watch(/test\/(.*).coffee/) {|m| `mocha --compilers coffee:coffee-script` }
end
