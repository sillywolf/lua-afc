local accessip = ngx.var.remote_addr;
local uriArgs=ngx.req.get_uri_args();

    print("home check ===============");
if  not validDynamicRule("loginip-"..accessip) then
    print("home check to redirect");
    redirectToVerifyPortal(uriArgs);
end
