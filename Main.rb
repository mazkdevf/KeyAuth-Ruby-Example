require './KeyAuth.rb'

KeyAuth.new.Api(
    "", # Application Name
    "", # Application OwnerID
    "", # Application Secret
    "1.0" # Applicaiton Version
)

KeyAuth.new.ClearConsole
puts "\n\n Connecting.."
KeyAuth.new.Init

puts "\n App data:"
puts " Number of users: " + KeyAuth::AppInfo["numUsers"]
puts " Number of online users: " + KeyAuth::AppInfo["numOnlineUsers"]
puts " Number of keys: " + KeyAuth::AppInfo["numKeys"]
puts " Application Version: " + KeyAuth::Version
puts " Customer panel link: " + KeyAuth::AppInfo["customerPanelLink"]

puts "\n [1] Login\n [2] Register\n [3] Upgrade\n [4] License key only\n\n Choose option: "

Option = gets.chomp
case Option

when '1'
  puts "\n\n Enter username: "
  username = gets.chomp
  puts "\n\n Enter password: "
  password = gets.chomp
  KeyAuth.new.Login(username, password)

when '2'
  puts "\n\n Enter username: "
  username = gets.chomp
  puts "\n\n Enter password: "
  password = gets.chomp
  puts "\n\n Enter license: "
  key = gets.chomp
  KeyAuth.new.Register(username, password, key)

when '3'
  puts "\n\n Enter username: "
  username = gets.chomp
  puts "\n\n Enter license: "
  key = gets.chomp

  KeyAuth.new.Upgrade(username, key)

when '4'
    puts "\n\n Enter license: "
    key = gets.chomp
    KeyAuth.new.License(key)
else 
    puts "Invalid option"
    exit(0)
end

puts "\n Logged In!"
    
#user data
puts "\n User data:"
puts " Username: " + KeyAuth::User_data["username"]
puts " IP address: " + KeyAuth::User_data["ip"]
puts " Hardware-Id: " + KeyAuth::User_data["hwid"]
puts " Created at: " + KeyAuth.new.UnixToDate(KeyAuth::User_data["createdate"])
#puts " Last login: " + KeyAuth.new.UnixToDate(KeyAuth::User_data["lastlogin"])

puts " Your subscription(s):"
for i in KeyAuth::User_data["subscriptions"]
    puts " Subscription name: #{i["subscription"]} - Expires at: #{KeyAuth.new.UnixToDate(i["expiry"])}  - Time left in seconds: #{i["timeleft"]}"
end

puts "\n\n Exiting in 10 secs...."
sleep(10)
exit(0)
