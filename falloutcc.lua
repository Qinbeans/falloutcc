os.pullEvent = os.pullEventRaw

local users = {}

local user_state = {
    ["name"] = "",
    ["admin"] = false
}

local function startup()
    term.setTextColor(colors.orange)
    write("> Loading user data...")
    if fs.exists("/etc/passwd") then
        local file = fs.open("/etc/passwd","r")
        users = textutils.unserializeJSON(file.readAll())
        file.close()
    else
        write("No user data found\nCreate a new passwd file")
        return
    end
    sleep(1)
    write("Done\n")
    term.setCursorPos(1,2)
    write(" ")
    term.setCursorPos(1,3)
    write("> Checking for home directory...")
    if not fs.exists("home") then
        fs.makeDir("home")
        shell.setDir("home")
    end
    sleep(1)
    write("Done\n")
    term.setCursorPos(1,3)
    write(" ")
    term.setCursorPos(1,4)
    write("> Checking for user directories...")
    for k, v in pairs(users) do
        if not fs.exists("/home/"..k) then
            fs.makeDir("/home/"..k)
        end
    end
    sleep(1)
    write("Done\n")
    term.setCursorPos(1,4)
    write(" ")
    term.setCursorPos(1,5)
    term.setTextColor(colors.lime)
    write("> Booting Bean OS\n")
end


local function run_with_perms(program)
    local dir = shell.dir()
    if not user_state.admin and string.find(dir,"home/"..user_state.name) == nil and string.find(program,"cd") == nil then
        if string.find(dir,"home/"..user_state.name) == nil then
            write("You do not have permission to run this program\n")
        elseif not user_state.admin then
            write("Not admin\n")
        end
    end
    shell.run(program)
end

local function clear()
    term.clear()
    term.setCursorPos(1,1)
    term.setTextColor(colors.lime)
end

-- Login function
local function login()
    clear()
    print "Booting Fallout OS"
    startup()
    sleep(1)
    clear()
    print "Good Evening User Please Enter Password"

    write("> Username:")
    user = read()

    if not users[user] then
        print("User not found")
        return false
    end

    term.setCursorPos(1,2)
    write(" ")
    term.setCursorPos(1,3)
    -- Ask for the password
    write("> Password:")
    pass = read("*")
    term.setCursorPos(1,3)
    write(" ")
    term.setCursorPos(1,4)
    sleep(1)

    if users[user].password == pass then
        print("Good Evening " .. user)
        shell.setDir("/home/"..user)
        user_state.name = user
        for k, v in pairs(users[user].group) do
            if v == "admin" then
                user_state.admin = true
            end
        end
        return true
    end
    print("Access Denied")
    return false
end

local function run()
    clear()
    print("Welcome to Fallout OS")
    print("Type 'exit' to exit")
    while true do
        term.setTextColor(colors.lime)
        write("> ")
        local input = read()
        if input == "exit" then
            return
        else
            run_with_perms(input)
        end
    end
end

local function main()
    shell.setDir("/")
    if login() then
        print("Welcome to Fallout OS")
        sleep(2)
        run()
    end
    print("Goodbye")
end

main()