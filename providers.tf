terraform {
  required_providers {
    aci = {
      source = "ciscodevnet/aci"
    }
  }
}

#configure provider with your cisco aci credentials.
provider "aci" {
  # cisco-aci user name
  username = var.CISCO_ACI_TERRAFORM_USERNAME
  # cisco-aci password
  password = var.CISCO_ACI_TERRAFORM_PASSWORD
  # cisco-aci url
  url      = var.CISCO_ACI_APIC_IP_ADDRESS
  insecure = true
}