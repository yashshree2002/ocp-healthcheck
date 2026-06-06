[OPTION 1:]

curl -s https://raw.githubusercontent.com/yashshree2002/ocp-healthcheck/main/health-check.sh | bash

[OPTION 2]

wget https://raw.githubusercontent.com/yashshree2002/ocp-healthcheck/main/health-check.sh

chmod +x health-check.sh

./health-check.sh


[OPTION 3]

Create a small installer:

wget -O clustercheck https://raw.githubusercontent.com/yashshree2002/ocp-healthcheck/main/health-check.sh
chmod +x clustercheck
sudo mv clustercheck /usr/local/bin/
