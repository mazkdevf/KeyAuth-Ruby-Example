require 'net/http'
require 'json'
require 'uri'
require 'date'

class KeyAuth
    AppInitalized = "no"
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
            AppInitalized.replace "yes"
            SessionID.replace resp["sessionid"]
            AppInfo.replace resp["appinfo"]
            return true
        else
            puts "Error: " + resp["message"]
            exit(0)
        end
    end

    def Login(username, password)
        CheckInit()
        hwid = GetHwid()

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
        CheckInit()
        hwid = GetHwid()

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
        CheckInit()
        hwid = GetHwid()

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
        CheckInit()
        hwid = GetHwid()

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

    def var(varname)
        CheckInit()
        uri = URI("https://keyauth.win/api/1.1/?type=var&name=" + Name + "&ownerid=" + OwnerID + "&sessionid=" + SessionID + "&hwid=" + GetHwid() + "&varid=" + varname) 
        res = Net::HTTP.get(uri)

        resp = JSON.parse(res)

        if resp["success"] == true
            return resp["message"]
        else
            return ""
        end
    end

    def setvar(varname, value) 
        CheckInit()

        uri = URI("https://keyauth.win/api/1.1/?type=setvar&name=" + Name + "&ownerid=" + OwnerID + "&sessionid=" + SessionID + "&hwid=" + GetHwid() + "&var=" + varname + "&data=" + value) 
        res = Net::HTTP.get(uri)

        resp = JSON.parse(res)

        if resp["success"] == true
            return true
        else
            return false
        end
    end

    def getvar(varname)
        CheckInit()

        uri = URI("https://keyauth.win/api/1.1/?type=getvar&name=" + Name + "&ownerid=" + OwnerID + "&sessionid=" + SessionID + "&hwid=" + GetHwid() + "&var=" + varname) 
        res = Net::HTTP.get(uri)

        resp = JSON.parse(res)

        if resp["success"] == true
            return resp["message"]
        else
            return ""
        end
    end

    def check()
        CheckInit()

        uri = URI("https://keyauth.win/api/1.1/?type=check&name=" + Name + "&ownerid=" + OwnerID + "&sessionid=" + SessionID + "&hwid=" + GetHwid()) 
        res = Net::HTTP.get(uri)

        resp = JSON.parse(res)

        if resp["success"] == true
            return true
        else
            return false
        end
    end

    def checkBlacklist()
        CheckInit()

        uri = URI("https://keyauth.win/api/1.1/?type=checkblack&name=" + Name + "&ownerid=" + OwnerID + "&sessionid=" + SessionID + "&hwid=" + GetHwid()) 
        res = Net::HTTP.get(uri)

        resp = JSON.parse(res)

        if resp["success"] == true
            return true
        else
            return false
        end
    end

    def log(message) 
        CheckInit()

        hwid = GetHwid()
        pcName = ENV["COMPUTERNAME"]

        uri = URI("https://keyauth.win/api/1.1/?type=log&name=" + Name + "&ownerid=" + OwnerID + "&sessionid=" + SessionID + "&hwid=" + GetHwid() + "&message=" + message + "&pcuser=" + pcName) 
        res = Net::HTTP.get(uri)

        resp = JSON.parse(res)

        if resp["success"] == true
            return true
        else
            return false
        end
    end

    def webhook(webid, params) 
        CheckInit()

        uri = URI("https://keyauth.win/api/1.1/?type=webhook&name=" + Name + "&ownerid=" + OwnerID + "&sessionid=" + SessionID + "&webid=" + webid + "&params=" + params) 
        res = Net::HTTP.get(uri)

        resp = JSON.parse(res)

        if resp["success"] == true
            return resp["message"]
        else
            return false
        end
    end

    def CheckInit()
        if AppInitalized == "no"
            puts "Please initialize the API first, before using commands: KeyAuth.new.Init"
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
        res = RunCMD("wmic useraccount where name='%username%' get sid /value")
        res = res.gsub("0000-","")
        res = res.gsub(":","")
        res = res.gsub("\n","")
        res = res.gsub(" ","")
        res = res.gsub("SID=","")

        res = res.chomp
        return res
    end

    def RunCMD(cmd)
        res=""
        begin
          res=`#{cmd}`
        rescue Exception => e
          res="SID=UNKNOWN"
        end
        res
    end

end
