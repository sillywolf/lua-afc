local req=ngx.req;
local user_agent = ngx.var.http_user_agent;
local cookie = req.get_headers()["Cookie"];
local accessip = ngx.var.remote_addr;
local uri = ngx.unescape_uri(ngx.var.request_uri);

req.read_body();
local username = getRequestParam("username");
local requestArgs = ngx.var.args;
local print=print;


if cookie == nil then
    --print("cookie is nil");
    cookie = "";
end
if user_agent == nil then
    --print("ua is nil");
    user_agent = "";
end
if username == nil then
    --print("ua is nil");
    username = "";
end

print("afc -> uri:",uri,"/username:",username,"/user_agent:",user_agent,"/cookie:",cookie,"/accessip:",accessip);

if ngx.re.match(ngx.unescape_uri(cookie),"access=deny","isjo")then
    print("cookie deny");
    serviceDeny();
end


if not validStaticRules(user_agent,"user_agent") then
    print("ua deny");
    serviceDeny();
end

if not validDynamicRule("accessip:"..accessip) then
    print("ip deny");
    serviceDeny();
end


if uri == "/" and not validDynamicRule("loginip:"..accessip) then
    print("loginip deny");
    redirectToVerifyPortal(requestArgs);
end
