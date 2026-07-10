Service Endpoints
The identity of a virtual network can be provided to the Azure service by
using service endpoints. Many services support virtual network access, and
with the service endpoint enabled, you can access these services in a secure
manner. The communication from your virtual network to the Azure service
is done via the Microsoft backbone network. For example, you can have a
virtual machine deployed to a virtual network, and you can also have a
storage account. On the storage account firewall, you need to allow the
communication from the virtual network that the VM belongs to. Using a
service endpoint, the VM will be able to communicate with the storage
service securely using its private IP address as the source IP address, as
shown in Figure 3.3.
FIGURE 3.3 Understanding service endpoints
Sometimes your virtual network address spaces might be overlapping, and
it's difficult to identify the traffic just based on the IP addresses. Chances
are that the traffic is originating from a virtual network that has the same
address space as of the virtual network that is supposed to access the
service. The service endpoint mitigates this issue by creating an identity for
your virtual network and sharing it with the Azure services. All you need to
do is to add a virtual network security rule, and your resources will stay
secured. This rule completely eliminates the public Internet access to the
resources where service endpoints are added and allows only traffic
originated from the virtual network. The key point here is that service
endpoints can be used for secure communications only from the Azure
virtual network; on-premises to Azure services is not supported.