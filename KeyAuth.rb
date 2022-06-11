require 'net/http'
require 'json'
require 'uri'
require 'date'

class KeyAuth
    SessionID = "none"
    Name = "" 
    OwnerID = "" 
    Secret = "" 
    Version = ""

    AppInfo = {
        NumUsers: 0,
        NumOnlineUsers: 0,
        NumKeys: 0,
        CustomerPanelLink: "none",
    }

    User_data = {
        username: "",
        ip: "",
        hwid: "",
        createdate: "",
        lastlogin: "",
        subscriptions: []
    }

    ## for future
    Response = {
        success: false,
        message: "",
    }

    def Api(name, ownerid, secret, version)
        if name == "" || ownerid == "" || secret == "" || version == ""
            puts "Error: Application not setupped correctly"
            exit(0)
        end

        Name.replace name
        OwnerID.replace ownerid
        Secret.replace secret
        Version.replace version
    end
  
    def Init()
        uri = URI("https://keyauth.win/api/1.1/?type=init&name=" + Name + "&ownerid=" + OwnerID + "&ver=" + Version)
        res = Net::HTTP.get(uri)
        
        resp = JSON.parse(res)

        if resp == "KeyAuth_Invalid"
            puts "Error: Application not found"
            exit(0)
        end

        if resp["success"] == true
            SessionID.replace resp["sessionid"]
            AppInfo.replace resp["appinfo"]
            return true
        else
            puts "Error: " + resp["message"]
            exit(0)
        end
    end

    def Login(username, password)
        hwid = "soon"

        uri = URI("https://keyauth.win/api/1.1/?type=login&username=" + username + "&pass=" + password +"&name=" + Name + "&ownerid=" + OwnerID + "&sessionid=" + SessionID + "&hwid=" + hwid)
        res = Net::HTTP.get(uri)
        
        resp = JSON.parse(res)

        if resp["success"] == true
            Load_UserData(resp["info"])
        else
            puts "Error: " + resp["message"]
            exit(0)
        end
    end

    def Register(username, password, key)
        hwid = "soon"

        uri = URI("https://keyauth.win/api/1.1/?type=register&username=" + username + "&pass=" + password + "&key=" + key + "&name=" + Name + "&ownerid=" + OwnerID + "&sessionid=" + SessionID + "&hwid=" + hwid)
        res = Net::HTTP.get(uri)
        
        resp = JSON.parse(res)

        if resp["success"] == true
            Load_UserData(resp["info"])
        else
            puts "Error: " + resp["message"]
            exit(0)
        end
    end

    def Upgrade(username, key)
        hwid = "soon"

        uri = URI("https://keyauth.win/api/1.1/?type=upgrade&username=" + username + "&key=" + key + "&name=" + Name + "&ownerid=" + OwnerID + "&sessionid=" + SessionID + "&hwid=" + hwid)
        res = Net::HTTP.get(uri)
        
        resp = JSON.parse(res)

        if resp["success"] == true
            puts "Successfully upgraded!"
            exit(0)
        else
            puts "Error: " + resp["message"]
            exit(0)
        end
    end

    def License(key)
        hwid = "soon"

        uri = URI("https://keyauth.win/api/1.1/?type=license&key=" + key + "&name=" + Name + "&ownerid=" + OwnerID + "&sessionid=" + SessionID + "&hwid=" + hwid)
        res = Net::HTTP.get(uri)
        
        resp = JSON.parse(res)

        if resp["success"] == true
            Load_UserData(resp["info"])
        else
            puts "Error: " + resp["message"]
            exit(0)
        end
    end

    def Load_UserData(json)
        User_data.replace json
    end

    def UnixToDate(unix)
        return DateTime.strptime(unix,'%s').strftime("%d-%M-%Y %H:%m:%S")
    end

    def ClearConsole()
        system('cls')
    end

    def GetHwid()

        ## doesnt split :/
        raw = system("wmic useraccount where name='%username%' get sid")
        ok = raw.to_s.split('\n')[1]
        
        return ok
    end

end
