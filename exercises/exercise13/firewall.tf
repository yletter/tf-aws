# Stateless Inspection - Network Firewall Rule

resource "aws_networkfirewall_rule_group" "NetworkFirewallStatelessRule" {
  description = "Stateless Rate Limiting Rule"
  capacity    = 100
  name        = "NetworkFirewallStatelessRule"
  type        = "STATELESS"
  rule_group {
    rules_source {
      stateless_rules_and_custom_actions {
        stateless_rule {
          priority = 1
          rule_definition {
            # actions = ["aws:pass"]
            actions = ["aws:forward_to_sfe"]
            match_attributes {
              source {
                address_definition = "10.0.0.0/16"
              }
              source_port {
                from_port = 80
                to_port   = 80
              }
              destination {
                address_definition = "0.0.0.0/0"
              }
              destination_port {
                from_port = 80
                to_port   = 80
              }
              protocols = [6]
              tcp_flag {
                flags = ["SYN"]
                masks = ["SYN", "ACK"]
              }
            }
          }
        }
      }
    }
  }

  tags = {
    Tag1 = "StatelessRules"
  }
}
# Stateful Inspection for permitting packets from a source IP address
resource "aws_networkfirewall_rule_group" "networkfirewallRG" {
  capacity    = 50
  description = "Permits http traffic from source"
  name        = "networkfirewallRG"
  type        = "STATEFUL"
  rule_group {
    rules_source {
      dynamic "stateful_rule" {
        for_each = local.ips
        content {
          action = "PASS"
          header {
            destination      = "ANY"
            destination_port = "ANY"
            protocol         = "HTTP"
            direction        = "ANY"
            source_port      = "ANY"
            source           = stateful_rule.value
          }
          rule_option {
            keyword  = "sid"
            settings = ["1"]
          }
        }
      }
    }
  }

  tags = {
    Name = "permit HTTP from source"
  }
}

locals {
  ips = ["10.0.0.0/16"]
}

resource "aws_networkfirewall_firewall_policy" "networkfirewallPolicy" {
  name = "networkfirewallPolicy"

  firewall_policy {
    stateless_default_actions = ["aws:forward_to_sfe"]
    # stateless_default_actions          = ["aws:pass"]
    stateless_fragment_default_actions = ["aws:drop"]

    stateless_rule_group_reference {
      priority     = 1
      resource_arn = aws_networkfirewall_rule_group.NetworkFirewallStatelessRule.arn
    }
    stateful_rule_group_reference {
      resource_arn = aws_networkfirewall_rule_group.networkfirewallRG.arn
    }
  }

  tags = {
    Name = "networkfirewallPolicy"
  }
}

resource "aws_networkfirewall_firewall" "networkfirewall2" {
  name                = "VPCnetworkfirewall"
  firewall_policy_arn = aws_networkfirewall_firewall_policy.networkfirewallPolicy.arn
  vpc_id              = aws_vpc.main.id

  subnet_mapping {
    subnet_id = aws_subnet.subnet4.id
  }
  tags = {
    Name = "networkfirewall2"
  }
}

locals {
  vpc_endpoints = flatten([
    for sync_state in toset(aws_networkfirewall_firewall.networkfirewall2.firewall_status[0].sync_states) :
    [for attachment in tolist(sync_state.attachment) :
      {
        endpoint_id       = attachment.endpoint_id
        subnet_id         = attachment.subnet_id
        availability_zone = sync_state.availability_zone
      }
    ]
  ])
}
