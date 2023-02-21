resource "aci_tenant" "localTenant" {
    for_each = toset(distinct([for tenant in local.iterations: tenant.aci_tenant_name]))
    name = random_uuid.localTenantUUID[each.value].result
    name_alias = each.value
    
    depends_on = [
        random_uuid.localTenantUUID
    ]
}

resource "aci_application_profile" "localApplicationProfile" {
    for_each = {
        for i in flatten([
            for tenant, app_profs in local.app_profs:[
                for app_prof in app_profs: {
                    tenant   = tenant
                    app_prof = app_prof
                }
            ]
        ]):
        "${i.tenant}.${i.app_prof}" => {
            tenant_name = i.tenant
            app_prof_name = i.app_prof
        }
    }
    
    tenant_dn  = aci_tenant.localTenant[each.value.tenant_name].id
    name       = random_uuid.localApplicationProfileUUID[each.value.app_prof_name].result
    name_alias = each.value.app_prof_name
    
    depends_on = [
        random_uuid.localApplicationProfileUUID,
        aci_tenant.localTenant
    ]    
}

resource "aci_bridge_domain" "localBridgeDomain" {
    for_each = {
        for i in flatten([
            for tenant, bridge_domains in local.bridge_domains:[
                for bridge_domain in bridge_domains: {
                    tenant   = tenant
                    bridge_domain = bridge_domain
                }
            ]
        ]):
        "${i.tenant}.${i.bridge_domain}" => {
            tenant_name = i.tenant
            bridge_domain_name = i.bridge_domain
        }
    }
    
    tenant_dn  = aci_tenant.localTenant[each.value.tenant_name].id
    name       = random_uuid.localBridgeDomainUUID[each.value.bridge_domain_name].result
    name_alias = each.value.bridge_domain_name
    
    depends_on = [
        random_uuid.localBridgeDomainUUID,
        aci_tenant.localTenant
    ]    
}

resource "aci_application_epg" "localApplicationEndpointGroup" {
    for_each = {
        for i in flatten([
            for app_profile, app_prof_app_epgs in local.app_prof_app_epgs:[
                for app_prof_app_epg in app_prof_app_epgs: {
                    app_profile   = app_profile
                    app_prof_app_epg = app_prof_app_epg
                }
            ]
        ]):
        "${i.app_profile}.${i.app_prof_app_epg}" => {
            app_profile_name = i.app_profile
            app_epg_name = i.app_prof_app_epg
        }
    }
    
    application_profile_dn  = aci_application_profile.localApplicationProfile[each.value.app_profile_name].id
    name                    = random_uuid.localApplicationEndpointGroupUUID[each.value.app_epg_name].result
    name_alias              = each.value.app_epg_name
    
    depends_on = [
        random_uuid.localApplicationEndpointGroupUUID,
        aci_application_profile.localApplicationProfile
    ]    
}

resource "aci_rest" "localAssociation_ApplicationEndpointGroupBridgeDomain" {
    for_each = {
        for i in flatten([
            for bridge_domain, bd_app_epgs in local.bd_app_epgs:[
                for bd_app_epg in bd_app_epgs: {
                    bridge_domain   = bridge_domain
                    app_epg = bd_app_epg
                }
            ]
        ]):
        "${i.bridge_domain}.${i.app_epg}" => {
            bridge_domain_name = i.bridge_domain
            app_epg_name = i.app_epg
        }
    }

    path       = "api/node/mo/${aci_application_epg.localApplicationEndpointGroup[each.value.app_epg_name].id}/rsbd.json"
    payload = <<EOF
        {
          "fvRsBd": {
            "attributes": {
              "tnFvBDName": "${aci_bridge_domain.localBridgeDomain[each.value.bridge_domain_name].name}"
            },
            "children": []
          }
        }
      EOF
  
    depends_on = [
        aci_application_epg.localApplicationEndpointGroup,
        aci_bridge_domain.localBridgeDomain
    ]     
  
}