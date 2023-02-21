resource "random_uuid" "localTenantUUID" {
    for_each = toset(distinct([for tenant in local.iterations: tenant.aci_tenant_name]))
}

resource "random_uuid" "localApplicationProfileUUID" {
    for_each = toset(distinct([for application_profile in local.iterations: application_profile.aci_application_profile_name]))
}

resource "random_uuid" "localBridgeDomainUUID" {
    for_each = toset(distinct([for bridge_domain in local.iterations: bridge_domain.aci_bridge_domain_name]))
}

resource "random_uuid" "localApplicationEndpointGroupUUID" {
    for_each = toset(distinct([for app_epg in local.iterations: app_epg.aci_application_epg_name]))
}