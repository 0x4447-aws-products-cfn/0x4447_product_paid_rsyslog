# 🛰 Rsyslog-Server

Collecting logs is useful for many things, but some time very expensive if you use manger Cloud solutions, like CloudWatch. It seams ease end convenient but once you start sending thousands of entires a day your AWS bill will inflate dramatically for such a simple thing. Of course there are use cases where the features of CloudWatch outlay the price, but in some cases you just want to see what the OS or your app is generating to debug issues. And or that you don't need anything fancy.

We preconfigured an AMI with rsyslog to act as a log collection server and be the centralized place where you can get in, check the logs of all the clients, and find out the problem.

The AMI price is affordable and the total cost fixed, no matter how many logs do you send.

# Overview

The Rsyslog is setup in a way where the logs have a retention period of 30 days, and the logs are organized in folders by  using the host name of the client server. All the logs are stored in the default folder path `/var/log`

Once the server is deployed, give your developer the ssh key to access, and let them debug.

# Pricing

You pay for two things:

- The EC2 Instance you select
- For suing our AMI

Check the official product page for more details.

# How to deploy

<a target="_blank" href="https://console.aws.amazon.com/cloudformation/home#/stacks/new?stackName=zer0x4447-rsyslog-server&templateURL=https://s3.amazonaws.com/0x4447-drive-cloudformation/rsyslog-server.json">
<img align="left" style="float: left; margin: 0 10px 0 0;" src="https://s3.amazonaws.com/cloudformation-examples/cloudformation-launch-stack.png"></a>

All you need to do to deploy this stack is click the button to the left and follow the instructions that CloudFormation provides in your AWS Dashboard. Alternatively you can download the CF file from [here](https://s3.amazonaws.com/0x4447-drive-cloudformation/rsyslog-server.json).

# What will deploy?

![rsyslog-server](https://raw.githubusercontent.com/0x4447/0x4447_product_rsyslog/assets/diagram.png)

The stack takes advantage of EC2.

- 1x EC2 Instance
- 1x Security Group
- 1x EBS

# Manual work

### Copy the SSL cert to your client server

All logs are sent over an encrypted connection thanks to an SSL certificate which is created each time you start a new instance from our AMI. The certificate is located in this folder: `/etc/ssl/ca-cert.pem`. You can use SCP to copy this cert to your client servers. To do so you need 3 steps:

1. Copy the cert to your local computer

```
scp RSYSLOG_SERVER:/etc/ssl/ca-cert.pem .
```

1. Upload the cert to the client server in the `tmp` folder

```
scp ca-cert.pem CLIENT:/tmp
```

1. Move the cert I the final location using `sudo` since SCP dose not support running commands using `sudo`, we use `ssh` for this.

```
ssh CLIENT sudo mv /tmp/ca-cert.pem /etc/ssl
```

### How to configure the Rsyslog Client

Once the cert is in place. We have a bash script that will configure the Rsyslog on your client servers automatically for you. Meaning after you run this script you should start seeing logs coming in to the `rsyslog-server`. To copy the bash script to your client server, we are going to use the same trick we did for the certificate, and use your computer as a proxy between the two instances.

1. Copy the script to your local computer

```
scp RSYSLOG_SERVER:/home/ec2-user/client-setup.sh .
```

1. Upload the script to the client server in the `tmp` folder

```
scp client-setup.sh CLIENT:/tmp
```

1. Once the file gets uploaded, we need to make it executable.

```
ssh CLIENT chmod +x /tmp/client-setup.sh
```

1. As the last step we have to log in to your client server and run the script

```
/tmp/client-setup.sh IP_OR_DNS_TO_THE_RSYSLOGSERVER
```

# How to work with this project

When you want to deploy the stack, the only file you should be interested in is the `CloudFormation.json` file. If you'd like to modify the stack, we recommend that you use the [Grapes framework](https://github.com/0x4447/0x4447-cli-node-grapes), which was designed to make it easier to work with the CloudFormation file. If you'd like to keep your sanity, never edit the main CF file 🤪.

# The End

If you enjoyed this project, please consider giving it a 🌟. And check out our [0x4447 GitHub account](https://github.com/0x4447), where you'll find additional resources you might find useful or interesting.

## Sponsor 🎊

This project is brought to you by 0x4447 LLC, a software company specializing in building custom solutions on top of AWS. Follow this link to learn more: https://0x4447.com. Alternatively, send an email to [hello@0x4447.email](mailto:hello@0x4447.email?Subject=Hello%20From%20Repo&Body=Hi%2C%0A%0AMy%20name%20is%20NAME%2C%20and%20I%27d%20like%20to%20get%20in%20touch%20with%20someone%20at%200x4447.%0A%0AI%27d%20like%20to%20discuss%20the%20following%20topics%3A%0A%0A-%20LIST_OF_TOPICS_TO_DISCUSS%0A%0ASome%20useful%20information%3A%0A%0A-%20My%20full%20name%20is%3A%20FIRST_NAME%20LAST_NAME%0A-%20My%20time%20zone%20is%3A%20TIME_ZONE%0A-%20My%20working%20hours%20are%20from%3A%20TIME%20till%20TIME%0A-%20My%20company%20name%20is%3A%20COMPANY%20NAME%0A-%20My%20company%20website%20is%3A%20https%3A%2F%2F%0A%0ABest%20regards.).
