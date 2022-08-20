<!-- markdownlint-disable -->
## Inputs

| Name | Description | Default | Required |
|------|-------------|---------|----------|
| aws-region | AWS region | us-east-1 | false |
| base-role | Base role arn | N/A | true |
| cluster | Cluster name | N/A | true |
| cluster-role | Cluster role arn | N/A | true |
| debug | Debug mode | false | false |
| environment | Helmfile environment | preview | false |
| helmfile | Helmfile name | helmfile.yaml | false |
| helmfile-path | The path where lives the helmfile. | deploy | false |
| image | Docker image | N/A | true |
| image-tag | Docker image tag | N/A | true |
| namespace | Kubernetes namespace | N/A | true |
| operation | Operation with helmfiles. (valid options - `deploy`, `destroy`) | deploy | true |

## Outputs

| Name | Description |
|------|-------------|
| webapp-url | Web Application url |
<!-- markdownlint-restore -->
