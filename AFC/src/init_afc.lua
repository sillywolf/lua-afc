--require "afc_dao";
--require "afc_dao_memc";
    

--流量清洗初始化脚本

--参数定义
--PREFIX = "D:\\projects\\lua-projects\\afc-for-portal";
PREFIX = "/lcims/work/renyb/tengine"
--PREFIX = ".";
RULE_PREFIX = PREFIX..'/'.."rules";
LOG_PREFIX = PREFIX..'/'.."logs";

--函数定义
--获取静态规则，来自配置文件
function getStaticRules(ruleName)
    local file = io.open(RULE_PREFIX..'/'..ruleName,"r");
    local rules = {};
    for line in file:lines() 
    do
        table.insert(rules,line);
    end
    file:close();
    return (table.concat(rules,"|"));
end
--从共享内存读取rules，提升效率
function getSharedStaticRules(ruleName) 
    local sharedRules = ngx.shared.rules;
    if not (sharedRules == nil) then
        print("use shared rules");
        local rules = sharedRules:get(ruleName);
        if rules == nil then
            print("shared "..ruleName.." is nil, need to load from file");
            rules = getStaticRules(ruleName);
            sharedRules:set(ruleName,rules);
            print("get "..ruleName.." from file and set to shared");
        end
        return rules;
    else
        return getStaticRules(ruleName);
    end
end
--获取动态规则，来自内存库
function getDynamicRule(ruleName)
    local rule = ngx.location.capture("/memc_rules?cmd=get&key="..ruleName).body;
    --[[
    --纯lua方式读取dao，已支持memc，可以扩展支持其他内存库
    local dao = MemcDAO:new({host="192.168.97.143",port=11211});
    dao:setTimeout(1000);
    dao:connect();
    local rule = dao:get(ruleName);
    dao:close();
    --]]
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
    --ngx.header["Set-Cookie"] = "access=deny";
    --ngx.exit(500);
    ngx.say("<h1>WARN!!! YOUR REQ IS DENY!!!</h1>");
    ngx.exit(200);
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