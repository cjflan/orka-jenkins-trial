import json
import os
import requests
import time
from fabric import Connection

class OrkaJenkinsAgentConfigure:
    def __init__(self):
            self.token = None
            self.orka_address = 'http://10.221.188.100' 
            self.orka_license = os.environ['ORKA_LICENSE'] 
            self.orka_user = os.environ['ORKA_USER'] 
            self.orka_pass = os.environ['ORKA_PASS'] 
            self.core_count = 3
            self.vcpu_count = 3
            self.orka_base_image = '90GBigSurSSH.img'
            self.image_name = 'foo'
    
    def create_orka_user(self):
        url = f'{self.orka_address}/users'
        headers = {'Content-Type': 'application/json', 'orka-licensekey': f'{self.orka_license}'}
        payload = json.dumps({'email': f'{self.orka_user}', 'password': f'{self.orka_pass}'})
        requests.request('POST', url, headers=headers, data=payload)
    
    def get_token(self):
        url = f'{self.orka_address}/token'
        payload = json.dumps({'email': f'{self.orka_user}', 'password': f'{self.orka_pass}'})
        headers = {'Content-Type': 'application/json'}
        response = requests.request('POST', url, headers=headers, data=payload)
        response = json.loads(response._content.decode('utf-8'))
        self.token = response['token']

    def create_vm_config(self):
        url = f'{self.orka_address}/resources/vm/create'
        payload = json.dumps({
                    'orka_vm_name': f'{self.image_name}',
                    'orka_base_image': f'{self.orka_base_image}',
                    'orka_image': f'{self.image_name}',
                    'orka_cpu_core': self.core_count,
                    'vcpu_count': self.vcpu_count,
                    })
        headers = {'Content-Type': 'application/json', 'Authorization': f'Bearer {self.token}'}
        response = requests.request('POST', url, headers=headers, data=payload)
        response = json.loads(response._content.decode('utf-8'))
        self.vm_config = response

    def deploy_vm_config(self):
        url = f'{self.orka_address}/resources/vm/deploy'
        payload = json.dumps({'orka_vm_name': 'foo'})
        headers = {'Content-Type': 'application/json', 'Authorization': f'Bearer {self.token}'}
        response = requests.request('POST', url, headers=headers, data=payload)
        time.sleep(20)
        response = json.loads(response._content.decode('utf-8'))
        self.vm = response
        self.vm_id = self.vm['vm_id']
        self.vm_ip = self.vm['ip']
        self.vm_ssh_port = self.vm['ssh_port']

    def save_image(self):
        url = f'{self.orka_address}/resources/image/save'
        payload = json.dumps({"orka_vm_name": self.vm_id, "new_name": "jenkins-agent.img"})
        headers = {'Content-Type': 'application/json', 'Authorization': f"Bearer {self.token}"}
        response = requests.request("POST", url, headers=headers, data=payload)
    
    def purge_vm(self):
        url = f'{self.orka_address}/resources/vm/purge'
        payload = json.dumps({'orka_vm_name': self.image_name})
        headers = {'Content-Type': 'application/json', 'Authorization': f'Bearer {self.token}'}
        response = requests.request("DELETE", url, headers=headers, data=payload)

    def delete_token(self):
        url = f'{self.orka_address}/token'
        payload={}
        headers = {'Authorization': f'Bearer {self.token}'}
        requests.request('DELETE', url, headers=headers, data=payload)

    def run(self, cmd):
        c = Connection(
            host=f'{self.vm_ip}', 
            user='admin', 
            port=self.vm_ssh_port,
            connect_kwargs={'password': 'admin'}
            )
        c.run(cmd)
        c.close()

def main(qc):
    qc.create_orka_user()
    qc.get_token()

    qc.create_vm_config()
    print('Deploying VM.....')
    qc.deploy_vm_config()

    print('downloading java...')
    qc.run('curl -Lo ~/adoptopenjdk.tar.gz https://github.com/adoptium/temurin8-binaries/releases/download/jdk8u312-b07/OpenJDK8U-jdk_x64_mac_hotspot_8u312b07.tar.gz')
    qc.run('tar xzf adoptopenjdk.tar.gz')
    qc.run('mkdir ~/jdk')
    qc.run('cp -r ~/jdk8u312-b07/Contents/Home/* ~/jdk')
    qc.run('rm ~/adoptopenjdk.tar.gz')
    qc.run('rm -rf ~/jdk8u312-b07')
    time.sleep(30)

    print('saving image')
    qc.save_image() 
    
    qc.purge_vm()
    
    qc.delete_token()

if __name__ == '__main__':
	qc = OrkaJenkinsAgentConfigure()
	main(qc)