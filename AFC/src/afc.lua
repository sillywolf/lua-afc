local ngx=ngx;
local req=ngx.req;
req.read_body();
local user_agent = ngx.var.http_user_agent;
local cookie = req.get_headers()["Cookie"];
local accessip = ngx.var.remote_addr;

if cookie == nil then
    cookie = "";
end
if user_agent == nil then
    user_agent = "";
end


if ngx.re.match(ngx.unescape_uri(cookie),"access=deny","isjo")then
    serviceDeny();
end


if not validStaticRules(user_agent,"user_agent") then
    print("static rule deny : ",user_agent);
    serviceDeny();
end

if not validDynamicRule("accessip-"..accessip) then
    print("Dynamic rule deny : ",accessip);
    serviceDeny();
end

