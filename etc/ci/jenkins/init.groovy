import com.cloudbees.plugins.credentials.impl.*;
import com.cloudbees.plugins.credentials.*;
import com.cloudbees.plugins.credentials.domains.*;
import jenkins.model.*
import hudson.security.*

def instance = Jenkins.getInstance()
def realm = new HudsonPrivateSecurityRealm(false)
def strategy = new GlobalMatrixAuthorizationStrategy()


// Create a superuser with default credentials.
realm.createAccount('quantum', 'quantum')
strategy.add(Jenkins.ADMINISTER, "quantum")
instance.setSecurityRealm(realm)
instance.setAuthorizationStrategy(strategy)
instance.save()


// Add the Kubernetes API client certificate as a global
// Jenkins credential. This is used to run jobs in the
// Kubernetes cluster. Note that *inside* jobs, using the
// kubernetesDeploy() function, you need to use the Kubernetes
// config file (see below).
def store = SystemCredentialsProvider
  .getInstance()
  .getStore()
def ksm1 = new CertificateCredentialsImpl.FileOnMasterKeyStoreSource("/etc/pki/k8s-admin.p12")
Credentials ck1 = new CertificateCredentialsImpl(CredentialsScope.GLOBAL,
  "k8s.certificate", "Kubernetes client certificate", "quantum", ksm1)

store.addCredentials(Domain.global(), ck1)


// Configure the Kubernetes cluster with the given credentials.
import org.csanchez.jenkins.plugins.kubernetes.*


def k8s = new KubernetesCloud('cluster-local', null,
  'http://k8s.local.quantumframework.org:8001', 'cicd',
  'http://jenkins.local.quantumframework.org:8080/',
  '10', 0, 0, 5
)
k8s.setSkipTlsVerify(true)
k8s.setCredentialsId("k8s.certificate")

instance.clouds.replace(k8s)
instance.save()
