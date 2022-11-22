import paramiko,time

def execute(client, command):
    stdin,stdout,stderr = client.exec_command(command)
    if stdout.channel.recv_exit_status() == 1 : print('Command failed!')
    if stderr:
        for line in stderr: print(line)
    reply =""
    for line in stdout:
        reply+=line
    stdin.close()
    stdout.close()
    stderr.close()
    return reply

def main():
    ssh_client = paramiko.SSHClient()
    ssh_client.load_system_host_keys()
    ssh_client.connect(hostname='10.155.147.234')

    while True:
        interfaces_unparsed = execute(ssh_client, ':put [interface print as-value]')[:-1].strip('.id=').split('.id=')
        for interface in interfaces_unparsed:
            #print(interface)
            interface = interface[:-1].split(';')
            for attr in interface:
                if 'name=' in attr:
                    name = attr.split('=')[1]
                    get_data = execute(ssh_client,f':put [interface get {name}]')
                    if 'disabled=false' in get_data and 'running=false' in get_data:
                        execute(ssh_client,f'interface disable {name}')
                    else:
                        execute(ssh_client,f'interface enable {name}')
                    time.sleep(0.2)

    ssh_client.close()

if __name__ == '__main__':
    main()