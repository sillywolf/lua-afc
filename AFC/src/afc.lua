ngx.req.read_body()
local user_agent = ngx.var.http_user_agent;
local cookie = ngx.req.get_headers()["Cookie"];
local accessip = ngx.var.remote_addr;
local uri = ngx.unescape_uri(ngx.var.request_uri);
local username = getRequestParam("username");
local requestArgs = ngx.var.args;
local normalLoginUri="/login.jsp";


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

print("uri:"..uri.."/username:"..username.."/user_agent:"..user_agent.."/cookie:"..cookie.."/accessip:"..accessip);

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
    serviceDeny();
end

--校验用户是否属于多次认证失败的用户
--是，则重定向用户至带验证码的登录页面
if uri == normalLoginUri and not validDynamicRule("username:"..username) then
    print("redirect user loging");
    redirectToVerifyPortal(requestArgs);
end