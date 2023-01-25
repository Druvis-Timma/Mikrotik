/system scheduler
add interval=1m name=telestarter on-event=":if ([:len [/system script job find script=telegram]] <1) do={\r\
    \n/system script run telegram\r\
    \n}" policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon start-time=startup
