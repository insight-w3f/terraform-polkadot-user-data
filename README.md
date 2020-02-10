# terraform-polkadot-user-data

<p class="callout danger">WIP</p>

## Features

This module builds user data scripts for polkadot nodes.  Includes some sane defaults for prometheus node exporter and
consul config.

## Terraform versions

For Terraform v0.12.0+

## Usage

```
module "this" {
    source = "github.com/robc-io/terraform-polkadot-user-data"
    type = "sentry"
}
```

## Examples

- [simple](https://github.com/robc-io/terraform-polkadot-user-data/tree/master/examples/simple)

## Known issues
No issue is creating limit on this module.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Providers

| Name | Version |
|------|---------|
| aws | n/a |
| template | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| consul\_enabled | Enable consul service | `bool` | `false` | no |
| disable\_ipv6 | Disable ipv6 in grub | `bool` | `true` | no |
| driver\_type | The ebs volume driver - nitro or standard | `string` | `"nitro"` | no |
| enable\_hourly\_cron\_updates | n/a | `string` | `"false"` | no |
| keys\_update\_frequency | n/a | `string` | `""` | no |
| log\_config\_bucket | n/a | `string` | `""` | no |
| log\_config\_key | n/a | `string` | `""` | no |
| mount\_volumes | Boolean to mount volume | `bool` | `true` | no |
| node\_tags | The tag to put into the node exporter for consul to pick up the tag of the instance and associate the proper metrics | `string` | `"prep"` | no |
| prometheus\_enabled | Download and start node exporter | `bool` | `false` | no |
| s3\_bucket\_name | n/a | `string` | `""` | no |
| s3\_bucket\_uri | n/a | `string` | `""` | no |
| ssh\_user | n/a | `string` | `"ubuntu"` | no |
| type | Type of node - ie sentry / validator, - more to come | `string` | `"sentry"` | no |

## Outputs

| Name | Description |
|------|-------------|
| user\_data | n/a |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Authors

Module managed by [robc-io](github.com/robc-io)

## Credits

- [Anton Babenko](https://github.com/antonbabenko)

## License

Apache 2 Licensed. See LICENSE for full details.