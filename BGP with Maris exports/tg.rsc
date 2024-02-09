# 2023-12-11 19:00:56 by RouterOS 7.14alpha21
# software id = MIFK-6HGD
#
# model = CCR2216-1G-12XS-2XQ
# serial number = HE508GS23FN
/interface ethernet
set [ find default-name=sfp28-1 ] l2mtu=9000
/disk
add slot=ram1 tmpfs-max-size=4000000000 type=tmpfs
add slot=ram3 tmpfs-max-size=11000000000 type=tmpfs
set sata1 type=hardware
set sata2 type=hardware
#error exporting "/figman/peer"
#error exporting "/figman/store"
/interface wireless security-profiles
set [ find default=yes ] supplicant-identity=MikroTik
/port
set 0 name=serial0
#error exporting "/figman/connect"
#error exporting "/figman/local"
#error exporting "/figman/provide"
#error exporting "/figman/remote"
/interface ethernet switch qos tx-manager queue
set 1 use-shared-buffers=no
set 2 use-shared-buffers=no
/ip address
add address=172.16.20.2/30 interface=sfp28-1 network=172.16.20.0
/ip dhcp-client
add interface=ether1
/ip route
add gateway=172.16.20.1
/system identity
set name=tg
/system note
set show-at-login=no
/system package update
set channel=development
/system routerboard settings
set enter-setup-on=delete-key
/tool sniffer
set filter-interface=sfp28-1
/tool traffic-generator packet-template
add ip-dst=1.0.0.1-9.9.9.9 ip-gateway=172.16.20.1 ip-protocol=udp ip-src=\
    10.1.2.100 name=pt0
add ip-dst=177.0.0.0/18 ip-gateway=172.16.20.1 ip-protocol=udp ip-src=\
    10.1.2.100 name=pt1
