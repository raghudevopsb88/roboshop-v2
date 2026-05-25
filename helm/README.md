# RoboShop Helm Charts

Application microservices for EKS. Images are placeholders (`dummy/roboshop-*`) until you push real images to ECR.

## Charts

| Chart        | Port | Notes                          |
|-------------|------|--------------------------------|
| frontend    | 80   | Nginx + static UI              |
| user        | 8001 | MongoDB                        |
| catalogue   | 8002 | MySQL                          |
| cart        | 8003 | Valkey                         |
| shipping    | 8004 | MySQL                          |
| payment     | 8005 | RabbitMQ                       |
| ratings     | 8006 | MySQL                          |
| orders      | 8007 | MongoDB + RabbitMQ             |
| notification| 8008 | RabbitMQ                       |

## Deploy with Helm (from bastion)

```bash
aws eks update-kubeconfig --name dev --region us-east-1

# Shared DB hostnames (from terraform output)
export MYSQL_HOST="mysql.dev.roboshop.internal"
export MONGODB_HOST="mongodb.dev.roboshop.internal"
export VALKEY_HOST="valkey.dev.roboshop.internal"
export RABBITMQ_HOST="rabbitmq.dev.roboshop.internal"

for chart in frontend user catalogue cart shipping payment ratings orders notification; do
  helm upgrade --install "$chart" "./charts/$chart" \
    --namespace roboshop --create-namespace \
    --set global.dbHosts.mysql="$MYSQL_HOST" \
    --set global.dbHosts.mongodb="$MONGODB_HOST" \
    --set global.dbHosts.valkey="$VALKEY_HOST" \
    --set global.dbHosts.rabbitmq="$RABBITMQ_HOST" \
    --set image.repository="dummy/roboshop-${chart}" \
    --set image.tag=latest
done
```

Or use Terraform (`module.eks`) which installs these charts automatically after the cluster is ready.

## Replace images

Update `image.repository` and `image.tag` in each chart `values.yaml` or pass `--set` when upgrading.
