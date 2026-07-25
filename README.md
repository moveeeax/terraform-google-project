# terraform-google-project

Terraform module that manages a [Google Cloud](https://cloud.google.com/)
project (`google_project`). It creates a project under an organization or
folder, associates a billing account and enables a set of APIs.

## Usage

```hcl
module "project" {
  source = "github.com/moveeeax/terraform-google-project"

  project_id      = "my-app-prod-1234"
  name            = "My App Prod"
  org_id          = "123456789012"
  billing_account = "0123AB-4567CD-89EF01"

  activate_apis = [
    "compute.googleapis.com",
    "run.googleapis.com",
  ]

  default_service_account_action = "DEPRIVILEGE"
}
```

A runnable example lives in [`examples/basic`](examples/basic).

## Defaults worth knowing

* **`auto_create_network = false`.** The provider default is `true`, which gives
  every new project a `default` VPC preloaded with firewall rules that allow
  SSH, RDP and ICMP from `0.0.0.0/0`. This module opts out.
* **`deletion_policy = "PREVENT"`.** `terraform destroy` will refuse to remove
  the project. To actually tear one down, set `deletion_policy = "DELETE"` (or
  `"ABANDON"` to drop it from state and leave the project alive), apply that
  change, then destroy.
* **`disable_on_destroy = false` on every enabled API.** Dropping an entry from
  `activate_apis` removes the Terraform resource but leaves the API switched on,
  so unrelated workloads in the project keep running.
* **Default service accounts keep `roles/editor` unless you say otherwise.** GCP
  creates the Compute Engine and App Engine default service accounts with
  project Editor. Set `default_service_account_action = "DEPRIVILEGE"` to strip
  that grant, or `"DISABLE"` / `"DELETE"` to take the accounts out of service.

## Requirements

| Name      | Version  |
|-----------|----------|
| terraform | >= 1.5 (>= 1.7 to run the test suite) |
| google    | >= 5.41  |

`google_project.deletion_policy` landed in provider 5.41.0, which is why the
floor is not `5.0`.

## Inputs

| Name                             | Description                                                                                              | Type           | Default     | Required |
|----------------------------------|----------------------------------------------------------------------------------------------------------|----------------|-------------|:--------:|
| `project_id`                     | Globally unique id of the project to create.                                                             | `string`       | n/a         |   yes    |
| `name`                           | Human-readable display name of the project.                                                              | `string`       | n/a         |   yes    |
| `org_id`                         | Numeric organization id. Mutually exclusive with `folder_id`.                                            | `string`       | `null`      |    no    |
| `folder_id`                      | Numeric folder id. Mutually exclusive with `org_id`.                                                     | `string`       | `null`      |    no    |
| `billing_account`                | Billing account id in bare `XXXXXX-XXXXXX-XXXXXX` form, **not** `billingAccounts/...`.                   | `string`       | `null`      |    no    |
| `auto_create_network`            | Whether to create the default network.                                                                   | `bool`         | `false`     |    no    |
| `deletion_policy`                | `PREVENT`, `ABANDON` or `DELETE`.                                                                        | `string`       | `"PREVENT"` |    no    |
| `activate_apis`                  | APIs to enable, as full service names ending in `.googleapis.com`.                                       | `list(string)` | `[]`        |    no    |
| `default_service_account_action` | `DEPRIVILEGE`, `DISABLE` or `DELETE` for the default service accounts. `null` leaves them alone.         | `string`       | `null`      |    no    |
| `labels`                         | Labels applied to the project.                                                                           | `map(string)`  | `{}`        |    no    |

## Outputs

| Name           | Description                        |
|----------------|------------------------------------|
| `id`           | Identifier of the project.        |
| `project_id`   | Id of the project.                |
| `number`       | Numeric identifier of the project.|
| `enabled_apis` | APIs enabled on the project.      |

## Testing

The suite in [`tests/`](tests) runs against a mocked provider, so it needs
neither credentials nor network access:

```sh
terraform init -backend=false
terraform test
```

## License

[MIT](LICENSE)
