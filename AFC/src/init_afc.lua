--流量清洗初始化脚本

--参数定义
--PREFIX = "D:\\projects\\lua-projects\\afc-for-portal";
local PREFIX = "/lcims/work/renyb/tengine"
--PREFIX = ".";
local RULE_PREFIX = PREFIX..'/'.."rules";
local LOG_PREFIX = PREFIX..'/'.."logs";

local verifyLoginUri="/style/default/index.jsp";

local io=io;
local insert =table.insert;
local ngx=ngx;
local capture=ngx.location.capture;
local HTTP_OK=ngx.HTTP_OK;

--函数定义
--获取静态规则，来自配置文件
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
--从共享内存读取rules，提升效率
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
--获取动态规则，来自内存库
function getDynamicRule(ruleName)
    local rule = capture("/memc_rules?cmd=get&key="..ruleName).body;
    return rule;
end

--验证静态规则
function validStaticRules(attr,ruleName)
    local ruleReg = getStaticRules(ruleName);
    if attr and ngx.re.match(attr,ruleReg,"isjo")  then
        return false;
    else
        return true;
    end
end

--验证动态规则
function validDynamicRule(attr)
    local result = getDynamicRule(attr);
    if result == "deny" then
        return false;
    else
        return true;
    end
end

--拒绝服务
function serviceDeny()
    ngx.header.content_type = "text/html";
    ngx.say("<h1>WARN!!! YOUR REQ IS DENY!!!</h1>");
    ngx.exit(HTTP_OK);
end


--重定向用户请求至带验证码的首页
function redirectToVerifyPortal(requestArgs)
    ngx.header.content_type = "text/html";
    ngx.say(capture(verifyLoginUri..'?'..requestArgs).body);
    ngx.exit(HTTP_OK);
end

function getCurrPath()
    local lfs = require "lfs";
    return (lfs.currentdir());
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