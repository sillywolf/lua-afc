--校验认证请求，只允许正常用户通过
--使用在authServlet中
local ngx=ngx;
local accessip = ngx.var.remote_addr;
local uri = ngx.unescape_uri(ngx.var.request_uri);
local username = getRequestParam("username");
local print=print;

print("authcheck -> uri:",uri,"username",username,"/accessip:",accessip);

if ngx.re.match(ngx.unescape_uri(cookie),"access=deny","isjo")then
    print("cookie deny");
    serviceDeny();
end

if not validDynamicRule("accessip:"..accessip) then
    print("ip deny");
    serviceDeny();
end

if not validDynamicRule("loginip:"..accessip) then
    print("loginip deny");
    serviceDeny();
end
