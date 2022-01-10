import com.cloudbees.plugins.credentials.Credentials
import com.cloudbees.plugins.credentials.CredentialsScope
import com.cloudbees.plugins.credentials.domains.Domain
import com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl
import com.cloudbees.plugins.credentials.SystemCredentialsProvider
import hudson.model.AdministrativeMonitor
import hudson.model.Node.Mode
import hudson.model.TaskListener
import io.jenkins.plugins.orka.OrkaCloud
import io.jenkins.plugins.orka.AgentTemplate
import io.jenkins.plugins.orka.DefaultVerificationStrategy
import io.jenkins.plugins.orka.RunOnceCloudRetentionStrategy
import java.util.ArrayList
import java.util.Collections
import jenkins.model.Jenkins

String orkaEndpoint = System.getenv()['ORKA_ENDPOINT'] ?: "http://10.221.188.100";

String orkaUsername = System.getenv()['ORKA_USER'];
String orkaPassword = System.getenv()['ORKA_PASS'];
String sshUsername =  System.getenv()['SSH_USERNAME'] ?: "admin"
String sshPassword =  System.getenv()['SSH_PASSWORD'] ?: "admin"

String vmConfigName = System.getenv()['VM_CONFIG_NAME'] ?: "orka-jenkins"
String vmBaseImage = System.getenv()['VM_BASE_IMAGE'] ?: "jenkins-agent.img"
String vmCpuCountString = System.getenv()['VM_CPU_COUNT'] ?: 3
int vmCpuCount = Integer.parseInt(vmCpuCountString);
String agentLabel = System.getenv()['AGENT_LABEL'] ?: "orka"

String remoteFs = System.getenv()['REMOTE_FS_ROOT'] ?: "/Users/admin"

String sshUserCredentialsId = java.util.UUID.randomUUID().toString()
String orkaUserCredentialsId = java.util.UUID.randomUUID().toString()

Credentials sshCredentials = (Credentials) new UsernamePasswordCredentialsImpl(CredentialsScope.GLOBAL, sshUserCredentialsId, "VM SSH credentials", sshUsername, sshPassword)
SystemCredentialsProvider.getInstance().getStore().addCredentials(Domain.global(), sshCredentials)

Credentials orkaCredentials = (Credentials) new UsernamePasswordCredentialsImpl(CredentialsScope.GLOBAL, orkaUserCredentialsId, "Orka credentials", orkaUsername, orkaPassword)
SystemCredentialsProvider.getInstance().getStore().addCredentials(Domain.global(), orkaCredentials)

String vm = null
boolean createNewVMConfig = true
String namePrefix = null

AgentTemplate template = new AgentTemplate(sshUserCredentialsId, vm, createNewVMConfig, vmConfigName, 
    vmBaseImage, vmCpuCount, 1, remoteFs,  Mode.NORMAL, agentLabel, namePrefix,
    new RunOnceCloudRetentionStrategy(5), new DefaultVerificationStrategy(), Collections.emptyList());

ArrayList<AgentTemplate> templates = new ArrayList<AgentTemplate>()
templates.add(template)

/** 

OrkaCloud(String name, String credentialsId, String endpoint, String instanceCapSetting, int timeout,
            boolean useJenkinsProxySettings, List<? extends AddressMapper> mappings,
            List<? extends AgentTemplate> templates) 

**/

OrkaCloud cloud = new OrkaCloud("Orka Cloud", orkaUserCredentialsId, orkaEndpoint, null, 300, false, null, templates)

Jenkins.instance.clouds.add(cloud)

Jenkins.instance.administrativeMonitors.each { x-> 
    String name = x.getClass().name
    if (name.contains("SecurityIsOffMonitor") ||
        name.contains("SecurityIsOffMonitor") ||
        name.contains("URICheckEncodingMonitor") ||
        name.contains("UpdateCenter") ||
        name.contains("UpdateSiteWarningsMonitor") ||
        name.contains("RootUrlNotSetMonitor") ||
        name.contains("CSRFAdministrativeMonitor")) {
        x.disable(true)
    }
}

Jenkins.instance.save()