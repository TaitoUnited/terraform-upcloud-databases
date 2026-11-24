/**
 * Copyright 2026 Taito United
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

resource "upcloud_managed_database_postgresql" "postgres" {
  for_each = { for item in local.postgresqlClusters : item.name => item }

  name            = each.value.name
  title           = each.value.name
  zone            = each.value.zone
  plan_compute    = each.value.tier
  plan_node_count = each.value.highAvailabilityEnabled ? 2 : 1
  plan_backups    = "regular"

  plan_storage_gib = 20

  maintenance_window_dow  = each.value.maintenanceDay
  maintenance_window_time = "${each.value.maintenanceTime}:00"

  properties {
    version = each.value.version

    public_access = each.value.publicIpEnabled
    # TODO: authorizedNetworks

    backup_hour   = split(":", each.value.backupStartTime)[0]
    backup_minute = split(":", each.value.backupStartTime)[1]
  }

  network {
    uuid   = var.private_network_id
    name   = var.private_network_name
    family = "IPv4"
    type   = "private"
  }

  lifecycle {
    prevent_destroy = true
  }
}
