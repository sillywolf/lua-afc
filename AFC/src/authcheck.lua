local accessip = ngx.var.remote_addr;

if not validDynamicRule("accessip:"..accessip) then
    serviceDeny();
end

if not validDynamicRule("loginip:"..accessip) then
    serviceDeny();
end
