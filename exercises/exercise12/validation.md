# AWS Gateway Load Balancer POC Validation & Cost

## Cost Estimate (us-east-1)
The infrastructure in this POC consists of the following billable components:
- **1x Gateway Load Balancer (GWLB):** ~$0.0125 / hour
- **1x GWLB Endpoint (GWLBE):** ~$0.01 / hour
- **2x t3.micro EC2 Instances (Linux):** 2 * ~$0.0104 = ~$0.0208 / hour
- **Data Processing (GWLB & GWLBE):** negligible for a few ping/curl tests.

**Total approximate cost:**
- **Per Hour:** ~$0.0433
- **Per Day (24 hrs):** ~$1.04
- **Per Month (730 hrs):** ~$31.61

*(Note: Data transfer out to the internet, NAT (if added later), or public IP charges may add a few cents depending on usage and AWS free tier status.)*

---

## Validation Steps

### 1. Deploy the Infrastructure
```bash
cd exercise12
terragrunt run-all apply
```
*(Wait for completion. It will output `app_instance_public_ip` and `security_instance_public_ip`)*

### 2. Verify Ingress Routing to the App Instance
The App Instance is running a simple Apache HTTP server on port 80. The internet gateway (IGW) route table intercepts traffic bound for the App subnet and sends it to the GWLB Endpoint.
1. Run a `curl` against the App EC2 public IP:
   ```bash
   curl http://<app_instance_public_ip>
   ```
2. You should see the response: `Successful request! This traffic reached the App Server behind the AWS Gateway Load Balancer.`

### 3. Verify GENEVE Traffic on the Security EC2 (Console/SSH Step)
The GWLB encapsulates the incoming traffic in GENEVE (UDP port 6081) and sends it to the Security EC2 instance.
1. Connect to the Security EC2 instance via SSH or AWS Systems Manager Session Manager (SSM).
   ```bash
   ssh -i <your-key>.pem ec2-user@<security_instance_public_ip>
   ```
2. Install and run `tcpdump` to listen for GENEVE traffic on port 6081:
   ```bash
   sudo tcpdump -n -i eth0 udp port 6081
   ```
3. In a separate terminal or browser, hit the App EC2 public IP again (`curl http://<app_instance_public_ip>`).
4. In the `tcpdump` output on the Security EC2, you will see the UDP port 6081 packets arriving from the GWLB. This confirms that traffic is successfully being routed through the GWLB before reaching the App instance.

### 4. Cleanup
To avoid ongoing charges:
```bash
terragrunt run-all destroy
```
