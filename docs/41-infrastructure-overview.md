Setup AWS for Docker Cloud Deployment
=====================================

1. Connect AWS with Docker Cloud

2. Set-up a cluster using Docker Cloud
https://www.dropbox.com/s/q5emyco7ddg2i12/Screenshot%202016-05-18%2014.13.02.png?dl=0

3. Set-up a public "router" ec2 instance

This will receive requests from the interwebs and (using Docker Cloud's haproxy docker image) channel the traffic to the appropriate stack based on virtual host, port etc (configurable).

Assign an elastic ip to this router instance, then configure it as a bring-your-own-node from Docker Cloud.

Make sure to launch the router in the same vpc that docker cloud creates.

Make sure that your project's DNS entries are configured to point to this elastic ip. 

A t2.micro instance may be enough even for moderate workloads, since all this instance does is acting as a router. 

Example:
ubuntu/images/hvm-ssd/ubuntu-trusty-14.04-amd64-server-20150123 (ami-9a562df2)
t2.micro
20 GB SSD

Pro tip: Protect against accidental termination

Make sure that the security group has at least port 80/443 open to all IP addresses if you are hosting browser-based services.  

Also, open UDP and TCP ports that docker cloud needs, restricting access to the dc-vpc-default sec group.

To scale, launch more of the same type of instances and elastic ips, then configure round-robin DNS entries against the router instances. 

4. Set-up services, such as database(s) etc

Make sure to launch them in the same vpc that docker cloud creates.








2016-05-18 13:34, har inte så mkt, men lite screenshots från när jag satte upp senast:
#2015-10-16 17:10, skapar ju egen vpc för sq-prod så jag behövde lägga upp dessa subnets:
https://www.dropbox.com/s/xlai9sqrjneka5c/Screenshot%202015-10-16%2017.10.11.png?dl=0

#2015-10-16 17:11, och gateway
https://www.dropbox.com/s/mtxtye18keqnbfu/Screenshot%202015-10-16%2017.11.13.png?dl=0

#2015-10-16 17:11, men ändå:
Cannot create a publicly accessible DBInstance because customer VPC does not support DNS resolution and/or hostnames. (Service: AmazonRDS; Status Code: 400; Error Code: InvalidVPCNetworkStateFault; Request ID: cac49437-740f-11e5-9149-2fbe79724f9c)

#2015-10-16 17:12, fixade
https://www.dropbox.com/s/f3k26wimuaz28iy/Screenshot%202015-10-16%2017.12.04.png?dl=0
