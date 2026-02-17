**Tasks-6 

* Create Route 53 hosted zone
* Add domain DNS records
* Connect custom domain to ALB
* Create alias A record for ALB
* Add CNAME records for subdomains
* Request ACM SSL certificate
* Validate SSL certificate using DNS
* Configure HTTPS listener on ALB
* Redirect HTTP traffic to HTTPS
* Create target groups for ALB
* Attach target groups to ALB
* Set up ALB health checks
* Enable Route 53 health checks
* Enable ALB access logs
* Verify domain and HTTPS access
* Check DNS propagation

**step1: We want domain
*Purchase the domain from Godaddy
*From this Domain create the Route53 hosted zone.

**Step2 — Create Hosted Zone
*Open Route 53 console
*Click Hosted Zones
*Click Create hosted zone

Domain name	    poojari.store
Type	        Public Hosted Zone

**Step3 - Update Nameservers in Domain Registrar
After creation, Route 53 shows:
NS
ns-123.awsdns-xx.com
ns-456.awsdns-yy.net
ns-789.awsdns-zz.org
ns-000.awsdns-aa.co.uk
Copy these 4 nameservers.
Now:
Go to your domain provider (GoDaddy / Namecheap / etc)
Replace old nameservers with these 4 Route 53 nameservers
Without this, DNS will NEVER work

**Step4 - Add Records
Now go inside:
Hosted Zone → poojari.store → Create record

Record 1 — Root domain → ALB
Create:

SETTING	            VALUE
Record type     	A
Alias	            YES
Route traffic to	Alias to Application Load Balancer
Choose region	    us-west-2
Choose ALB	        select your ALB

This connects:

poojari.store → ALB

**Step5 - Request ACM SSL Certificate
Open ACM in AWS console, search for Certificate Manager
Request certificate
Choose:
Request a public certificate
Add domain name
Enter your domain:poojari.store
Validation method
Choose:
DNS validation   (recommended)

Validate using Route 53
After request, you’ll see:

Create DNS record in Route 53
Click:
Create records in Route 53
*Status becomes: Issued 

**Step6 - Now attach certificate to Load Balancer

Add HTTPS to ALB
EC2 → Load Balancers → your ALB
*Add listener:
Protocol: HTTPS
Port: 443
*Select:
Choose certificate → From ACM → select your cert
Forward to:

Target Group → EC2 instances

**Step7 — Redirect HTTP → HTTPS (recommended)

Add rule:
HTTP:80 → Redirect → HTTPS:443

So users automatically go secure.

**Step8 - Enable ALB Access Logs
Create S3 bucket
Go:
S3 → Create bucket
*Settings:

Bucket name: my-alb-logs-12345 (must be unique)
Region: same region as ALB
Block public access: ON
Create bucket.

*Add bucket permissions (IMPORTANT)
ALB needs permission to write logs.
Go:
Bucket → Permissions → Bucket policy
Paste this (replace values):{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AWSLogDeliveryWrite",
      "Effect": "Allow",
      "Principal": {
        "Service": "logdelivery.elasticloadbalancing.amazonaws.com"
      },
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::my-alb-logs-12345/AWSLogs/*"
    }
  ]
}
Change:

my-alb-logs-12345
to your bucket name

Enable logs on ALB

Go:
EC2 → Load Balancers → select your ALB

Then:
Attributes tab → Edit
Enable:
Access logs → ON
Fill:
S3 bucket → my-alb-logs-12345
Prefix → alb-logs (optional)
Save.
**Where logs appear?

After traffic starts:
S3 path:
s3://my-alb-logs-12345/alb-logs/AWSLogs/<account-id>/elasticloadbalancing/

Files look like:
2026-02-12-12-00-00.log.gz
Download and unzip.

**Verify domain and HTTPS access
Step A — Test domain

Open browser:

http://yourdomain.com

Should:
redirect to HTTPS automatically (if you added redirect rule)



**Check DNS Propagation

After creating Route53 records, DNS takes time to spread globally.
This is called:
DNS propagation
Usually:
2–5 minutes (Route53 fast)
sometimes up to 30 minutes

*Check nslookup (simple)
Windows (your system)
nslookup yourdomain.com
Output should show:

Name: yourdomain.com
Address: ALB-IP or ALB-DNS

**How do you monitor traffic to ALB?
I enable ALB access logs to send request logs to S3, which helps in debugging, monitoring, and analyzing traffic patterns.

**What is Route 53 health check?
Route 53 health checks monitor application endpoints and automatically route traffic only to healthy resources, enabling failover and high availability.

**What is an SSL certificate?
An SSL certificate is a digital certificate that enables HTTPS by encrypting communication between the client and server and verifying the identity of the website.