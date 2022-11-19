

Active Directory setup steps:

1. Click on Windows start menu and then click on Server Manager
2. Click on "2 Add roles and features" and then click next until "Server Roles" and then select "Active Directory Domain Services" to install
3. Click on the exclamation point in the top right corner and then select "Promote this server to a domain controller"
4. On the Deployment Configuration, click on "Add a new forest".
5. In the Root Domain Name input box, input a root domain akin to something like home.viglms.org and then click Next
6. On the Domain Controller Options, create a Password and then click on Next.
7. In Additional Options, the wizard will generate a NetBios name. Then, click next until the wizard is finished. The EC2 instance will log you out to set the changes.