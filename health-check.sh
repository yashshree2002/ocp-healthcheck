#!/bin/bash

clear

echo "========================================="
echo " OpenShift Cluster Health Check Analysis "
echo "========================================="
echo

echo "===== Cluster Version ====="
omc get clusterversion
echo
read -p "Press Enter to continue..."

echo
echo "===== Cluster Operators ====="
omc get co
echo
read -p "Press Enter to continue..."

echo
echo "===== Cluster Operator Upgradeable Status ====="
echo

printf "%-35s %-12s %-30s %s\n" "NAME" "UPGRADEABLE" "REASON" "MESSAGE"

for co in $(omc get co -o jsonpath='{.items[*].metadata.name}')
do
    status=$(omc get co "$co" -o jsonpath='{.status.conditions[?(@.type=="Upgradeable")].status}')
    reason=$(omc get co "$co" -o jsonpath='{.status.conditions[?(@.type=="Upgradeable")].reason}')
    message=$(omc get co "$co" -o jsonpath='{.status.conditions[?(@.type=="Upgradeable")].message}')

    printf "%-35s %-12s %-30s %s\n" \
        "$co" \
        "${status:-N/A}" \
        "${reason:-N/A}" \
        "${message:-N/A}"
done

echo
read -r -p "Press Enter to continue..."


echo
read -p "Press Enter to continue..."


echo
echo "===== Nodes ====="
omc get no
echo
read -p "Press Enter to continue..."

echo
echo "===== MachineConfigPools ====="
omc get mcp
echo
read -p "Press Enter to continue..."

echo
echo "===== Installed Operators ====="
omc get operators
echo
echo "Check the compatibility of the operators and upgrade the operators first, then upgrade the cluster:"
echo "https://access.redhat.com/labs/ocpouic/?upgrade_path" 
echo

echo
echo "===== Network Type ====="
omc get network -oyaml | grep -i networkType
echo

echo
echo "===== CGroup Configuration ====="
omc get nodes.config -oyaml | grep -i cgroup

echo "===CGroup Mode Check Information" 
echo 'To check current cgroup mode, run the following command:'
echo
echo 'for NODE in \$(oc get nodes -o name); do'
echo ' echo \"------ \${NODE} ------\"' 
echo ' oc debug \${NODE} -q -- chroot /host bash -c \"stat -c %T -f /sys/fs/cgroup\"' 
echo ' echo' 
echo 'done' 
echo

echo 'Alternative manual method:' 
echo 'oc debug node/<node-name>'
echo 'chroot /host' 
echo 'stat -fc %T /sys/fs/cgroup/' 
echo 

echo 'Interpretation:' 
echo 'cgroup2fs --> cgroup v2' 
echo 'tmpfs --> cgroup v1' 
echo

echo 'Reference Documentation:' 
echo '1. https://docs.redhat.com/en/documentation/openshift_container_platform/4.18/html/nodes/working-with-clusters#nodes-clusters-cgroups-2_nodes-cluster-cgroups-2' 
echo '2. https://access.redhat.com/solutions/7071862' 

echo
echo "===== Non-Running Pods ====="
omc get pods -A | grep -Ev "Running|Complete|Succeeded"
echo
read -p "Press Enter to continue..."

echo
echo "===== Node Resource Allocation ====="
for i in $(omc get nodes --no-headers | awk '{print $1}')
do
    echo "==== $i ===="
    omc describe node $i 2>/dev/null | grep -A10 Allocated
    echo
done
read -p "Press Enter to continue..."

echo
echo "===== Pod Disruption Budgets ====="
omc get pdb -A
echo
echo "# Usually, the allowed disruptions are set to 1 to allow nodes to be drained properly."
echo
read -p "Press Enter to continue..."

echo
echo "===== ETCD Health Check ====="
omc get etcd -o=jsonpath='{range .items[0].status.conditions[?(@.type=="EtcdMembersAvailable")]}{.message}{"\n"}{end}'
echo

echo "========================================="
echo " Health Check Analysis Completed "
echo "========================================="
