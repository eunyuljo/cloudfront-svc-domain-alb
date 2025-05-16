##  Terraform - Route 53 + ACM + ALB 을 통한 Domain 연결 테스트 - ALB 복구 시나리오

#### 문서 목적1
    CloudFront 에 대한 Origin ALB Endpoint가 아닌 서비스 도메인을 설정하는 방식에 대한 유효성 검증

![Image](https://github.com/user-attachments/assets/56481494-20d0-4b95-bf89-fb91e88d4753)

- Route 53을 통한 도메인 및 서브도메인 설정
- ALB 도메인과 CF 도메인을 구분하여, ALB가 변경되어도 해당 ALB 도메인만 매핑해주면 CF에서 해당 오리진 복구가 용이한지 테스트
 

#### 문서 목적2

![Image](https://github.com/user-attachments/assets/82860a36-8b7c-41e3-9a65-7c97d4862d08)

- CloudFront OAI 와 OAC 의 차이점을 비교하기 위해 테라폼 코드를 통해 구현

```
	주요 차이점
		1. OAI : 
		   개발 CloudFrontID 를 중심으로 접근 ( Identity 기반 )
		   특정 CloudFront ID에 직접 권한 부여 ( 덜 세분화된 보안 )
		   -> ID 기반 접근 제어
			   S3 버킷에서 특정 OAI ID에 권한을 부여하지만, 이 ID는 CloudFront 배포별로 구분하지 않으므로, 하나의 OAI로 여러 CF 배포에 재사용할 수 있다.
			   이 점에서 동일한 OAI를 사용하면 모든 CloudFront 배포를 사용할 수 있다는 의미이다.
		2. OAC : 
		   서비스 간 신뢰 관계를 중심으로 접근 ( Service Principal 기반 )
		   조건부 정책으로 특정 CloudFront 배포에만 권한 제한 ( 더 세분화된 보안 )
		   -> S3 버킷 정책에 ARN을 통한 접근 제어를 통해 SourceArn 을 기준으로 특정 CloudFront 배포만 허용이 가능하다는 점이 차이점이다.
```