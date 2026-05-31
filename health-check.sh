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
