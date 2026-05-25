service:
  type: LoadBalancer
  annotations:
    service.beta.kubernetes.io/aws-load-balancer-type: "nlb"
    service.beta.kubernetes.io/aws-load-balancer-ssl-cert: "${acm_certificate_arn}"
    service.beta.kubernetes.io/aws-load-balancer-ssl-ports: "443"
    service.beta.kubernetes.io/aws-load-balancer-backend-protocol: "http"

ports:
  web:
    port: 80
    exposedPort: 80
  websecure:
    port: 8000
    exposedPort: 443
    http:
      tls:
        enabled: false

logs:
  general:
    level: INFO

additionalArguments:
  - "--accesslog=true"
  - "--api.dashboard=true"
  - "--api.insecure=true"
  - "--entrypoints.web.forwardedHeaders.insecure=true"
  - "--entrypoints.websecure.forwardedHeaders.insecure=true"
  - "--entrypoints.web.http.redirections.entrypoint.to=:443"
  - "--entrypoints.web.http.redirections.entrypoint.scheme=https"
