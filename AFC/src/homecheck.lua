local accessip = ngx.var.remote_addr;
local uriArgs=ngx.req.get_uri_args();

if  not validDynamicRule("loginip:"..accessip) then
    redirectToVerifyPortal(uriArgs);
end