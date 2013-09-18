local accessip = ngx.var.remote_addr;

if not validDynamicRule("loginip-"..accessip) then
    serviceDeny();
end

