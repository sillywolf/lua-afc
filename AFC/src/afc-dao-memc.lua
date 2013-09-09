
MemcDAO = {}
setmetatable(MemcDAO, DAO);
MemcDAO.__index = MemcDAO;

function MemcDAO:new(args)
    local self = {};
    setmetatable(self, MemcDAO);
    print("MemcDAO init start...");
    if not args then
        self,err = nil, "memc args is nil";
        print(err);
        return self,err;
    end
    local host,port = args.host,args.port;
    if not host or host == "" then
        self,err = nil, "memc host is nil or blank";
        print(err);
        return self,err;
    end
    if not port or port == 0 then
        self,err = nil, "memc port is nil or zero";
        print(err);
        return self,err;
    end
    self.host = host;
    self.port = port;
    
    local memcached = require "resty.memcached"
    local memc, err= memcached:new()
    if not memc then
        self,err = nil, "Failed to instantiate memc: "..err;
        print(err);
    end
    self.memc = memc;
    print("MemcDAO init OK");
    return self;
end

function MemcDAO:setTimeout(timeout)
    if self.memc then
            print("MemcDAO setTimeout:"..timeout);
            self.memc:set_timeout(1000);
        return true;
        end
        print("MemcDAO memc is nil");
        return false,"memc is nil";
end

function MemcDAO:connect()
    if self.memc then
            print("MemcDAO connect...");
            local ok, err = self.memc:connect(self.host, self.port);
            if not ok then
                err = "Failed to connect memc: "..err;
                return false,err;
            end
            print("MemcDAO connected..."..self.host..":"..self.port.." OK");
        return true;
        end
        print("MemcDAO memc is nil");
        return false,"memc is nil";
end

function MemcDAO:get(key)
    if self.memc then
            print("MemcDAO get:"..key);
            local res, flags, err = self.memc:get(key);
        if err then
            err = "Failed to get "..key.." : "..err;
            return nil,err;
        end
        if not res then
                print("MemcDAO get key:"..key..",value is nil");
        else 
            print("MemcDAO get key:"..key..",value:"..res);
            end
            return res;
        end
        print("MemcDAO memc is nil");
        return false,"memc is nil";
end

function MemcDAO:store(self,cmd, key, value, exptime, flags)
    if not exptime then
        exptime = 0;    
    end    
    if not flags then
        flags = 0;
    end
    if self.memc then
            print("MemcDAO store: {cmd="..cmd.."&key="..key.."&value="..value.."&exptime="..exptime.."&flags="..flags.."}");
            local ok, err;
            if cmd == "set" then
            ok, err = self.memc:set(key, value, exptime, flags); 
        elseif cmd == "add" then
            ok, err = self.memc:add(key, value, exptime, flags);
        elseif cmd == "replace" then
            ok, err = self.memc:replace(key, value, exptime, flags);
        elseif cmd == "append" then
            ok, err = self.memc:append(key, value, exptime, flags);
        elseif cmd == "prepend" then
            ok, err = self.memc:prepend(key, value, exptime, flags);
        else
            print("MemcDAO store unknown cmd :"..cmd);
            ok, err = nil, "store cmd is unknown";
        end
            if not ok then
               err = "Failed to store cmd:"..cmd.." "..err
            end
        print("MemcDAO store: {cmd="..cmd.."&key="..key.."&value="..value.."&exptime="..exptime.."&flags="..flags.."} OK");
            return true;
        end 
        print("MemcDAO memc is nil");
    return false,"memc is nil";
end

function MemcDAO:set(...)
    print("MemcDAO set");
    return MemcDAO:store(self,"set", ...)
end
function MemcDAO:add(...)
    return MemcDAO:store(self,"add", ...)
end
function MemcDAO:replace(...)
    return MemcDAO:store(self,"replace", ...)
end
function MemcDAO:append(...)
    return MemcDAO:store(self,"append", ...)
end
function MemcDAO:prepend(...)
    return MemcDAO:store(self,"prepend", ...)
end

function MemcDAO:delete(key)
    if self.memc then
            print("MemcDAO delete:"..key);
            local ok, err = self.memc:delete(key);
        if not ok then
               err = "Failed to delete key:"..key.." "..err
               return false,err;
            end
        print("MemcDAO delete key:"..key.." OK");
            return true;
        end
        print("MemcDAO memc is nil");
        return false,"memc is nil";
end

function MemcDAO:close()
    if self.memc then
            print("MemcDAO close...");
            local ok, err = self.memc:close();
        if not ok then
               err = "Failed to close: "..err
               return false,err;
            end
        print("MemcDAO closed OK");
            return true;
        end
        print("MemcDAO memc is nil");
        return true;
end