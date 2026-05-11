# Stateless Inspection - Network Firewall Rule

resource "aws_networkfirewall_rule_group" "network_firewall_stateless_rule" {
  description = "Network Firewall Stateless Rule"
  capacity    = 100
  name        = "Network-Firewall-Stateless-Rule"
  type        = "STATELESS"
  rule_group {
    rules_source {
      stateless_rules_and_custom_actions {
        stateless_rule {
          priority = 100
          rule_definition {
            actions = ["aws:pass"]
            match_attributes {
              source {
                address_definition = "0.0.0.0/0"
              }
              source_port {
                from_port = 0
                to_port   = 65535
              }
              destination {
                address_definition = aws_vpc.main.cidr_block
              }
              destination_port {
                from_port = 22
                to_port   = 80
              }
              protocols = [6]
            }
          }
        }
        stateless_rule {
          priority = 200
          rule_definition {
            actions = ["aws:pass"]
            match_attributes {
              source {
                address_definition = aws_vpc.main.cidr_block
              }
              source_port {
                from_port = 22
                to_port   = 80
              }
              destination {
                address_definition = "0.0.0.0/0"
              }
              destination_port {
                from_port = 0
                to_port   = 65535
              }
              protocols = [6]
            }
          }
        }
        stateless_rule {
          priority = 300
          rule_definition {
            actions = ["aws:forward_to_sfe"]
            match_attributes {
              source {
                address_definition = aws_vpc.main.cidr_block
              }
              source_port {
                from_port = 0
                to_port   = 65535
              }
              destination {
                address_definition = "0.0.0.0/0"
              }
              destination_port {
                from_port = 22
                to_port   = 80
              }
              protocols = [6]
            }
          }
        }
        stateless_rule {
          priority = 400
          rule_definition {
            actions = ["aws:forward_to_sfe"]
            match_attributes {
              source {
                address_definition = "0.0.0.0/0"
              }
              source_port {
                from_port = 22
                to_port   = 80
              }
              destination {
                address_definition = aws_vpc.main.cidr_block
              }
              destination_port {
                from_port = 0
                to_port   = 65535
              }
              protocols = [6]
            }
          }
        }
      }
    }
  }

  tags = {
    Name = "Network-Firewall-Stateless-Rule"
  }
}
# Stateful Inspection for permitting packets from a source IP address
resource "aws_networkfirewall_rule_group" "network_firewall_stateful_rule" {
  capacity    = 50
  description = "Permits http traffic from source"
  name        = "Network-Firewall-Stateful-Rule"
  type        = "STATEFUL"
  rule_group {
    rules_source {
      rules_source_list {
        generated_rules_type = "ALLOWLIST"
        target_types         = ["TLS_SNI", "HTTP_HOST"]
        targets              = [".google.com", ".github.com"]
      }
    }
  }

  tags = {
    Name = "Network-Firewall-Stateful-Rule"
  }
}

resource "aws_networkfirewall_firewall_policy" "network_firewall_policy" {
  name = "Network-Firewall-Policy"

  firewall_policy {
    # stateless_default_actions = ["aws:forward_to_sfe"]
    stateless_default_actions          = ["aws:drop"]
    stateless_fragment_default_actions = ["aws:drop"]

    stateless_rule_group_reference {
      priority     = 1
      resource_arn = aws_networkfirewall_rule_group.network_firewall_stateless_rule.arn
    }
    stateful_rule_group_reference {
      resource_arn = aws_networkfirewall_rule_group.network_firewall_stateful_rule.arn
    }
  }

  tags = {
    Name = "Network-Firewall-Policy"
  }
}

resource "aws_networkfirewall_firewall" "network_firewall" {
  name                = "VPC-Network-Firewall"
  description         = "VPC Network Firewall"
  firewall_policy_arn = aws_networkfirewall_firewall_policy.network_firewall_policy.arn
  vpc_id              = aws_vpc.main.id

  subnet_mapping {
    subnet_id = aws_subnet.subnet4.id
  }
  tags = {
    Name = "VPC-Network-Firewall"
  }
}

locals {
  vpc_endpoints = flatten([
    for sync_state in toset(aws_networkfirewall_firewall.network_firewall.firewall_status[0].sync_states) :
    [for attachment in tolist(sync_state.attachment) :
      {
        endpoint_id       = attachment.endpoint_id
        subnet_id         = attachment.subnet_id
        availability_zone = sync_state.availability_zone
      }
    ]
  ])
}
