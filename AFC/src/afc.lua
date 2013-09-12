local req=ngx.req;
local user_agent = ngx.var.http_user_agent;
local cookie = req.get_headers()["Cookie"];
local accessip = ngx.var.remote_addr;
local unescape_uri=ngx.unescape_uri;
local uri = unescape_uri(ngx.var.request_uri);

req.read_body();
local username = getRequestParam("username");
local requestArgs = ngx.var.args;


if cookie == nil then
    cookie = "";
end
if user_agent == nil then
    user_agent = "";
end
if username == nil then
    username = "";
end


if ngx.re.match(unescape_uri(cookie),"access=deny","isjo")then
    serviceDeny();
end


if not validStaticRules(user_agent,"user_agent") then
    serviceDeny();
end

if not validDynamicRule("accessip:"..accessip) then
    serviceDeny();
end


if uri == "/" and not validDynamicRule("loginip:"..accessip) then
    redirectToVerifyPortal(requestArgs);
end
