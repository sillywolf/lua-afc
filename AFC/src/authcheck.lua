--У����֤����ֻ���������û�ͨ��
--ʹ����authServlet��
local ngx=ngx;
local accessip = ngx.var.remote_addr;
local unescape_uri=ngx.unescape_uri;
local uri = unescape_uri(ngx.var.request_uri);
local username = getRequestParam("username");


if ngx.re.match(unescape_uri(cookie),"access=deny","isjo")then
    serviceDeny();
end

if not validDynamicRule("accessip:"..accessip) then
    serviceDeny();
end

if not validDynamicRule("loginip:"..accessip) then
    serviceDeny();
end
