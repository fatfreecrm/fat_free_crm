every 10.seconds, :say_hello do
  %x[rake ffcrm:dropbox:run]
end