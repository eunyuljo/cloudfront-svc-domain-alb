##  Terraform - Route 53 + ACM + ALB 을 통한 Domain 연결 테스트 - ALB 복구 시나리오

#### 문서 목적1
    CloudFront 에 대한 Origin ALB Endpoint가 아닌 서비스 도메인을 설정하는 방식에 대한 유효성 검증

![Image](https://github.com/user-attachments/assets/56481494-20d0-4b95-bf89-fb91e88d4753)

- Route 53을 통한 도메인 및 서브도메인 설정
- ALB 도메인과 CF 도메인을 구분하여, ALB가 변경되어도 해당 ALB 도메인만 매핑해주면 CF에서 해당 오리진 복구가 용이한지 테스트
 

#### 문서 목적2

![Image](https://github.com/user-attachments/assets/82860a36-8b7c-41e3-9a65-7c97d4862d08)

- CloudFront OAI 와 OAC 의 차이점을 비교하기 위해 테라폼 코드를 통해 구현
