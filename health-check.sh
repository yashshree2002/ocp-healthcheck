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
echo "Check the compatibility of the operators and upgrade the operators first, then upgrade the cluster:" echo "https://access.redhat.com/labs/ocpouic/?upgrade_path" 
echo
read -p "Press Enter to continue..."

echo
echo "===== Network Type ====="
omc get network -oyaml | grep -i networkType
echo
read -p "Press Enter to continue..."

echo
echo "===== CGroup Configuration ====="
omc get nodes.config -oyaml | grep -i cgroup
echo

echo "CGroup Mode Check" \ "echo 'To check current cgroup mode:' && \ echo && \ echo 'Reference:' && \ echo 'https://docs.redhat.com/en/documentation/openshift_container_platform/4.18/html/nodes/working-with-clusters#nodes-clusters-cgroups-2_nodes-cluster-cgroups-2' && \ echo 'https://access.redhat.com/solutions/7071862' && \ echo && \ echo 'Checking cgroup mode on all nodes...' && \ echo && \ for NODE in \$(oc get nodes -o name); do \ echo '------' \$NODE '------'; \ oc debug \$NODE -q -- chroot /host bash -c 'stat -c %T -f /sys/fs/cgroup'; \ echo; \ done && \ echo 'If output is cgroup2fs --> cgroup v2' && \ echo 'If output is tmpfs --> cgroup v1'"

read -p "Press Enter to continue..."

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
