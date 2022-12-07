from pysnmp.hlapi import *
import datetime

def get_data(router_ip, obj_set):
    errorIndication, errorStatus, errorIndex, varBinds = next(
        getCmd(SnmpEngine(),
        CommunityData('public', mpModel=0),
        UdpTransportTarget((router_ip, 161)),
        ContextData(),
        *obj_set
        )
    )
    return varBinds

def main():
    ip = "10.10.10.10"

    oid_dict = {    "Model":("SNMPv2-MIB::sysDescr.0", "1.3.6.1.2.1.1.1.0"), 
                    "Uptime":("SNMPv2-MIB::sysUpTime.0", "1.3.6.1.2.1.1.3.0"), 
                    "Interface count":("SNMPv2-SMI::mib-2.2.1.0", "1.3.6.1.2.1.2.1.0")}

    obj_types = set()
    for key in oid_dict:
        obj_types.add(ObjectType(ObjectIdentity(oid_dict[key][1])))
    results = get_data(ip,obj_types)

    for result in results:
        result = str(result)
        for k in oid_dict:
            if oid_dict[k][0] in result:
                result_value = result.split('= ')[1]
                if k == "Uptime": result_value = str(datetime.timedelta(seconds = float(result_value)/100))
                print(str(k) + " is " + result_value)
        
if __name__ == '__main__':
    main()
