locals {
  iterations = csvdecode(file("./data/tenant-configurations.csv"))
  
  app_profs = {
      for a, b in {
          for iteration in local.iterations : iteration.aci_tenant_name => iteration.aci_application_profile_name...
      }
      : a => distinct(b)
  }  

  bridge_domains = {
      for a, b in {
          for iteration in local.iterations : iteration.aci_tenant_name => iteration.aci_bridge_domain_name...
      }
      : a => distinct(b)
  }
  
  app_prof_app_epgs = {
      for a, b in {
          for iteration in local.iterations : "${iteration.aci_tenant_name}.${iteration.aci_application_profile_name}" =>  iteration.aci_application_epg_name...
      }
      : a => distinct(b)
  } 

  bd_app_epgs = {
      for a, b in {
          for iteration in local.iterations : "${iteration.aci_tenant_name}.${iteration.aci_bridge_domain_name}" =>  "${iteration.aci_tenant_name}.${iteration.aci_application_profile_name}.${iteration.aci_application_epg_name}"...
      }
      : a => distinct(b)
  } 

}