local PREFIX = "/lcims/work/renyb/tengine"
local RULE_PREFIX = PREFIX..'/'.."rules";
local verifyLoginUri="/style/default/index.html";
local LUA_PREFIX = PREFIX..'/'.."luas";
local memc={host="192.168.97.141",port=11211};

local insert =table.insert;
local ngx=ngx;
local capture=ngx.location.capture;
local HTTP_OK=ngx.HTTP_OK;
local print=print;

package.path = LUA_PREFIX.."/?.lua;"..package.path;
require "afc_dao";
require "afc_dao_memc";

function getStaticRules(ruleName)
    local file = io.open(RULE_PREFIX..'/'..ruleName,"r");
    local rules = {};
    for line in file:lines()
    do
        insert(rules,line);
    end
    file:close();
    return (table.concat(rules,"|"));
end

function getSharedStaticRules(ruleName)
    local sharedRules = ngx.shared.rules;
    if not (sharedRules == nil) then
        local rules = sharedRules:get(ruleName);
        if rules == nil then
            rules = getStaticRules(ruleName);
            sharedRules:set(ruleName,rules);
        end
        return rules;
    else
        return getStaticRules(ruleName);
    end
end

function getDynamicRule(ruleName)
    print("getDynamicRule ==>",ruleName);
    local dao = MemcDAO:new(memc);
    dao:setTimeout(10000);
    dao:connect();
    local rule = dao:get(ruleName);
    dao:close();
    return rule;
end

function validStaticRules(attr,ruleName)
    print("valid static Rules ==>",ruleName);
    local ruleReg = getSharedStaticRules(ruleName);
    if attr and ngx.re.match(attr,ruleReg,"isjo")  then
        return false;
    else
        return true;
    end
end

function validDynamicRule(attr)
    local result = getDynamicRule(attr);
    if result == "deny" then
        return false;
    else
        return true;
    end
end

function serviceDeny()
    ngx.header.content_type = "text/html";
    ngx.say("<h1>WARN!!! YOUR REQ IS DENY!!!</h1>");
    ngx.exit(HTTP_OK);
end

function redirectToVerifyPortal(requestArgs)
    print("===>redirectToVerifyPortal<=======");
    ngx.header.content_type = "text/html";
    ngx.exec(verifyLoginUri,requestArgs);
end

function getRequestParam(paramName)
    local method = ngx.var.request_method;
    if method == "GET" then
        return ngx.var["arg_"..paramName];
    elseif method == "POST" then
        return ngx.req.get_post_args()["arg_"..paramName];
    else
        return false;
    end
end
