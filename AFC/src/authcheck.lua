--校验认证请求，只允许正常用户通过
--使用在authServlet中
local accessip = ngx.var.remote_addr;

if not validDynamicRule("accessip:"..accessip) then
    serviceDeny();
end

if not validDynamicRule("loginip:"..accessip) then
    serviceDeny();
end
