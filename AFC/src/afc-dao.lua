
DAO = {}
DAO.__index = DAO;

function DAO:new(args)
    local self = {};
    setmetatable(self, DAO);
    print("DAO init...");
    self.args = args;
    return self;
--return nil,"you can't new base DAO class";
end

function DAO:setTimeout(timeout)
    print("DAO setTimeout:"..timeout);
end

function DAO:connect()
    print("DAO connect...");
end

function DAO:get(key)
    print("DAO get key:"..key);
end

function DAO:store(cmd, key, value, exptime, flags)
    if not exptime then
        exptime = 0;
    end
    if not flags then
        flags = 0;
    end
    print("DAO store: {cmd="..cmd.."&key="..key.."&value="..value.."&exptime="..exptime.."&flags="..flags.."}");
end

function DAO:set(...)
    return DAO:store("set", ...)
end
function DAO:add(...)
    return DAO:store("add", ...)
end
function DAO:replace(...)
    return DAO:store("replace", ...)
end
function DAO:append(...)
    return DAO:store("append", ...)
end
function DAO:prepend(...)
    return DAO:store("prepend", ...)
end

function DAO:delete(key)
    print("DAO delete:"..key);
end

function DAO:close()
    print("DAO closed");
end

