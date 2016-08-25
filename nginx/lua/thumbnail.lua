-- lua通过请求的url，执行图片压缩命令，生成新的图片，并重定向至新url

-- nginx解析最后一级形如：ezkqoVe7ss2AMwCcAAAlMBncGCs752_600x600q90.jpg 的请求
-- if ($image_name ~ "([a-zA-Z0-9]+)_([0-9]+x[0-9]+)?(q[0-9]{1,2})?.([a-zA-Z0-9]+)") {
--     set $a  "$1"; --> zkqoVe7ss2AMwCcAAAlMBncGCs752
--     set $b  "$2"; --> 600x600
--     set $c  "$3"; --> q90
--     set $d  "$4"; --> jpg
-- }

local preName = ngx.var.a
local whParam = ngx.var.b
local qParams = ngx.var.c
local qParam = string.sub(qParams,2)
local suffix = ngx.var.d
local command = "gm convert " .. ngx.var.image_dir .. preName .. "." ..  suffix

if (whParam=="")
    then
    else
        command = command .. " -thumbnail " .. whParam
end

if (qParams=="")
    then
    else
        command = command .. " -quality " .. qParam
end

command = command .. " " .. ngx.var.file

os.execute("echo preName=" .. preName .. " > /log/debugMessage.txt")
os.execute("echo whParam=" .. whParam .. " > /log/debugMessage.txt")
os.execute("echo qParams=" .. qParams .. " > /log/debugMessage.txt")
os.execute("echo qParam=" .. qParam .. " > /log/debugMessage.txt")
os.execute("echo suffix=" .. suffix .. " > /log/debugMessage.txt")
os.execute("echo command=" .. command .. " > /log/debugMessage.txt")

os.execute(command)
ngx.redirect(ngx.var.uri)