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

function file_exists(path)
  local file = io.open(path, "rb")
  if file then file:close() end
  return file ~= nil
end

local originFileName = ngx.var.image_dir .. preName .. "." .. suffix

if (file_exists(originFileName))
    then

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

        os.execute("echo preName=" .. preName .. " > /opt/nginx/conf/lua/lualog.txt")
        os.execute("echo whParam=" .. whParam .. " > /opt/nginx/conf/lua/lualog.txt")
        os.execute("echo qParams=" .. qParams .. " > /opt/nginx/conf/lua/lualog.txt")
        os.execute("echo qParam=" .. qParam .. " > /opt/nginx/conf/lua/lualog.txt")
        os.execute("echo suffix=" .. suffix .. " > /opt/nginx/conf/lua/lualog.txt")
        os.execute("echo command=" .. command .. " > /opt/nginx/conf/lua/lualog.txt")

        local somefile = ngx.var.image_dir .. preName .. "." .. suffix
        os.execute("echo somefile=" .. somefile .. " > /opt/nginx/conf/lua/lualog.txt")



        os.execute(command)
        ngx.redirect(ngx.var.uri)
    else
        ngx.redirect("/404")
end