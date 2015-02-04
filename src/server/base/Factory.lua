--[[

Copyright (c) 2011-2015 chukong-inc.com

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

]]

local ConnectFactory = class("ConnectFactory")

function ConnectFactory.createConnect(config, classNamePrefix)
    local classNameSuffix
    local rootPath
    if classNamePrefix == "Command" then
        classNameSuffix = "Line" 
        package.path = config.cmdRootPath .. "/?.lua;" .. package.path
    else 
        classNameSuffix = "Connect"
        package.path = config.appRootPath .. "/?.lua;" .. package.path
    end

    local tagretClass
    local className = classNamePrefix .. classNameSuffix
    local ok, _tagretClass = pcall(require, className)
    if ok then
        tagretClass = _tagretClass
    end
        
    if not tagretClass then
        tagretClass = require("server.base." .. className .. "Base")
    end

    return tagretClass:create(config)
end

return ConnectFactory