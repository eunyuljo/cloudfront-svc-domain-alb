![Image](https://github.com/user-attachments/assets/8e0f82cc-dc95-4a94-a60a-c850a048f154)

# 🌐 Terraform - Route 53 + ACM + ALB 자동화 인프라

이 프로젝트는 **Terraform**을 사용해 다음을 자동화합니다:

- Route 53을 통한 도메인 및 서브도메인 설정
- ACM 인증서 생성 (DNS 검증)
- ALB 생성 및 재생성 시, 자동으로 DNS 레코드 업데이트

---

## 📁 주요 구성 파일

| 파일명              | 설명                                      |
|---------------------|-------------------------------------------|
| `main.tf`           | 리소스 선언 진입점                        |
| `route53_acm.tf`    | Route 53, ACM 리소스 정의                 |
| `alb.tf`            | Application Load Balancer 구성            |
| `outputs.tf`        | ALB의 DNS 이름 출력                       |
| `variables.tf`      | 입력 변수 선언                            |
| `terraform.tfvars`  | 도메인 및 서브도메인 값 정의              |
|---------------------|-------------------------------------------|
---

