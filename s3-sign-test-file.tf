// 테스트 파일 생성을 위한 로컬 디렉토리
resource "null_resource" "create_test_dir" {
  provisioner "local-exec" {
    command = "mkdir -p ./cf-test-files/oai-content ./cf-test-files/oac-content"
  }

  depends_on = [
    aws_s3_bucket.content_bucket_oai,
    aws_s3_bucket.content_bucket_oac
  ]
}

// 서명 확인 HTML 테스트 파일 생성
resource "local_file" "signature_test_html" {
  filename = "./cf-test-files/signature-test.html"
  content  = <<-EOF
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>CloudFront 서명 검증 테스트</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; line-height: 1.5; }
        .header { background-color: #2c3e50; color: white; padding: 20px; text-align: center; }
        .container { max-width: 800px; margin: 0 auto; }
        .test-box { margin: 20px 0; padding: 20px; border: 1px solid #ddd; border-radius: 5px; }
        .info-box { background-color: #f8f9fa; padding: 15px; border-left: 4px solid #3498db; margin: 10px 0; }
        .code { font-family: monospace; background-color: #f5f5f5; padding: 10px; border-radius: 4px; overflow-x: auto; }
        .success { color: green; font-weight: bold; }
        .error { color: red; font-weight: bold; }
        .btn { padding: 10px 15px; background-color: #3498db; color: white; border: none; 
              border-radius: 4px; cursor: pointer; margin-right: 10px; margin-bottom: 10px; }
        .btn:hover { background-color: #2980b9; }
    </style>
</head>
<body>
    <div class="header">
        <h1>CloudFront 서명 검증 테스트</h1>
        <p>OAI와 OAC의 서명 차이점 확인</p>
    </div>
    
    <div class="container">
        <div class="test-box">
            <h2>CloudFront 서명 확인</h2>
            <p>CloudFront가 S3 오리진에 요청할 때 사용하는 서명을 확인합니다.</p>
            
            <div class="info-box">
                <strong>서명 사용 여부 확인 방법:</strong>
                <ol>
                    <li>CloudFront 배포 설정 확인(Signature Version)</li>
                    <li>S3 서버 액세스 로그 분석(로깅 활성화 필요)</li>
                    <li>AWS CLI를 통한 설정 검증</li>
                </ol>
            </div>
            
            <h3>1. CloudFront 배포 설정 확인</h3>
            <button class="btn" onclick="checkCloudFrontConfig()">CloudFront 설정 확인 명령어</button>
            <div id="cf-config-result" class="code"></div>
            
            <h3>2. OAI/OAC 설정 확인</h3>
            <button class="btn" onclick="checkOAIConfig()">OAI 설정 확인 명령어</button>
            <button class="btn" onclick="checkOACConfig()">OAC 설정 확인 명령어</button>
            <div id="oai-oac-result" class="code"></div>
            
            <h3>3. S3 서버 액세스 로그 확인</h3>
            <div class="info-box">
                <p>S3 서버 액세스 로그를 활성화하면 요청 헤더 및 서명 정보를 확인할 수 있습니다.</p>
                <p>SigV4 서명은 <code>Authorization</code> 헤더에 <code>AWS4-HMAC-SHA256</code> 알고리즘을 사용합니다.</p>
            </div>
            <button class="btn" onclick="showS3LoggingCommands()">S3 로깅 설정 명령어</button>
            <div id="s3-logging-result" class="code"></div>
            
            <h3>4. TCP 덤프를 통한 요청 분석</h3>
            <div class="info-box">
                <p>고급 테스트: 프록시 서버나 TCP 덤프를 통해 CloudFront가 S3에 보내는 요청 헤더를 분석할 수 있습니다.</p>
            </div>
            <button class="btn" onclick="showTcpdumpCommands()">TCP 덤프 명령어</button>
            <div id="tcpdump-result" class="code"></div>
        </div>
        
        <div class="test-box">
            <h2>OAI와 OAC 서명 차이점</h2>
            
            <table style="width: 100%; border-collapse: collapse; margin: 20px 0;">
                <tr style="background-color: #f2f2f2;">
                    <th style="border: 1px solid #ddd; padding: 8px; text-align: left;">특성</th>
                    <th style="border: 1px solid #ddd; padding: 8px; text-align: left;">OAI (Origin Access Identity)</th>
                    <th style="border: 1px solid #ddd; padding: 8px; text-align: left;">OAC (Origin Access Control)</th>
                </tr>
                <tr>
                    <td style="border: 1px solid #ddd; padding: 8px;">서명 버전</td>
                    <td style="border: 1px solid #ddd; padding: 8px;">서명 버전 2(SigV2) 또는 없음</td>
                    <td style="border: 1px solid #ddd; padding: 8px;">서명 버전 4(SigV4)</td>
                </tr>
                <tr>
                    <td style="border: 1px solid #ddd; padding: 8px;">서명 형식</td>
                    <td style="border: 1px solid #ddd; padding: 8px;">단순한 인증 헤더</td>
                    <td style="border: 1px solid #ddd; padding: 8px;">
                        Authorization: AWS4-HMAC-SHA256<br>
                        Credential=..., SignedHeaders=..., Signature=...
                    </td>
                </tr>
                <tr>
                    <td style="border: 1px solid #ddd; padding: 8px;">서명 동작</td>
                    <td style="border: 1px solid #ddd; padding: 8px;">항상 서명</td>
                    <td style="border: 1px solid #ddd; padding: 8px;">구성 가능(항상/절대 안 함/오리진이 요청할 때)</td>
                </tr>
                <tr>
                    <td style="border: 1px solid #ddd; padding: 8px;">CloudFront 설정</td>
                    <td style="border: 1px solid #ddd; padding: 8px;">s3_origin_config 블록 사용</td>
                    <td style="border: 1px solid #ddd; padding: 8px;">origin_access_control_id 속성 사용</td>
                </tr>
            </table>
            
            <div class="info-box">
                <p><strong>서명 차이의 영향:</strong></p>
                <ul>
                    <li>OAC(SigV4)는 더 강력한 보안과 무결성 검사 제공</li>
                    <li>SigV4는 요청 본문에 대한 해시 포함하여 데이터 변조 방지</li>
                    <li>SigV4는 더 많은 AWS 서비스와 리전 지원</li>
                    <li>SigV4는 IPv6 지원</li>
                </ul>
            </div>
        </div>
        
        <div class="test-box">
            <h2>검증 예시 코드</h2>
            <p>실제 테스트를 위한 AWS CLI 명령어:</p>
            
            <h3>OAI/OAC 설정 검증</h3>
            <div class="code">
# CloudFront 배포 설정 확인
aws cloudfront get-distribution-config --id ${aws_cloudfront_distribution.cf_elb_origin.id}

# OAI 설정 확인
aws cloudfront get-cloud-front-origin-access-identity --id ${aws_cloudfront_origin_access_identity.oai.id}

# OAC 설정 확인
aws cloudfront get-origin-access-control --id ${aws_cloudfront_origin_access_control.oac.id}
            </div>
            
            <h3>S3 버킷 정책 확인</h3>
            <div class="code">
# OAI를 사용하는 S3 버킷 정책
aws s3api get-bucket-policy --bucket ${aws_s3_bucket.content_bucket_oai.bucket} --output json

# OAC를 사용하는 S3 버킷 정책
aws s3api get-bucket-policy --bucket ${aws_s3_bucket.content_bucket_oac.bucket} --output json
            </div>
        </div>
    </div>

    <script>
        function checkCloudFrontConfig() {
            const resultElem = document.getElementById('cf-config-result');
            resultElem.innerHTML = `# CloudFront 배포 설정 확인\n` +
                `# 이 명령어는 배포 설정의 오리진 설정과 서명 관련 정보를 보여줍니다\n` +
                `aws cloudfront get-distribution-config --id ${aws_cloudfront_distribution.cf_elb_origin.id}`;
        }
        
        function checkOAIConfig() {
            const resultElem = document.getElementById('oai-oac-result');
            resultElem.innerHTML = `# OAI 설정 확인\n` +
                `# OAI는 서명 버전을 명시적으로 지정하지 않습니다\n` +
                `aws cloudfront get-cloud-front-origin-access-identity --id ${aws_cloudfront_origin_access_identity.oai.id}`;
        }
        
        function checkOACConfig() {
            const resultElem = document.getElementById('oai-oac-result');
            resultElem.innerHTML = `# OAC 설정 확인\n` +
                `# OAC는 서명 프로토콜(sigv4)과 서명 동작(always)을 명시적으로 지정합니다\n` +
                `aws cloudfront get-origin-access-control --id ${aws_cloudfront_origin_access_control.oac.id}`;
        }
        
        function showS3LoggingCommands() {
            const resultElem = document.getElementById('s3-logging-result');
            resultElem.innerHTML = `# S3 서버 액세스 로깅 활성화하기\n` +
                `# 1. 로그 저장용 버킷 생성\n` +
                `aws s3 mb s3://my-s3-logs-bucket\n\n` +
                `# 2. OAI 버킷 로깅 활성화\n` +
                `aws s3api put-bucket-logging --bucket ${aws_s3_bucket.content_bucket_oai.bucket} \\\n` +
                `    --bucket-logging-status '{\"LoggingEnabled\":{\"TargetBucket\":\"my-s3-logs-bucket\",\"TargetPrefix\":\"oai-logs/\"}}'\n\n` +
                `# 3. OAC 버킷 로깅 활성화\n` +
                `aws s3api put-bucket-logging --bucket ${aws_s3_bucket.content_bucket_oac.bucket} \\\n` +
                `    --bucket-logging-status '{\"LoggingEnabled\":{\"TargetBucket\":\"my-s3-logs-bucket\",\"TargetPrefix\":\"oac-logs/\"}}'\n\n` +
                `# 4. 로그 확인 (몇 분 기다려야 함)\n` +
                `aws s3 ls s3://my-s3-logs-bucket/oai-logs/ --recursive\n` +
                `aws s3 ls s3://my-s3-logs-bucket/oac-logs/ --recursive\n\n` +
                `# 5. 로그 다운로드 및 분석\n` +
                `aws s3 cp s3://my-s3-logs-bucket/oai-logs/ ./oai-logs/ --recursive\n` +
                `aws s3 cp s3://my-s3-logs-bucket/oac-logs/ ./oac-logs/ --recursive\n\n` +
                `# 로그 파일에서 SigV4 서명 검색 (OAC만 해당)\n` +
                `grep -i "AWS4-HMAC-SHA256" ./oac-logs/*`;
        }
        
        function showTcpdumpCommands() {
            const resultElem = document.getElementById('tcpdump-result');
            resultElem.innerHTML = `# 고급 테스트: HTTP 요청 캡처 (프록시 서버나 VPC 엔드포인트 필요)\n` +
                `# 주의: 이는 개념적 명령어로, 실제 환경에 맞게 조정 필요\n\n` +
                `# 1. tcpdump로 HTTP 트래픽 캡처\n` +
                `sudo tcpdump -i eth0 -s 0 -A 'tcp port 80 or tcp port 443' -w s3_traffic.pcap\n\n` +
                `# 2. 특정 서명 패턴 검색\n` +
                `strings s3_traffic.pcap | grep -A 20 "Authorization: AWS"\n` +
                `strings s3_traffic.pcap | grep -A 20 "Authorization: AWS4-HMAC-SHA256"\n\n` +
                `# 3. Wireshark로 분석\n` +
                `# s3_traffic.pcap 파일을 Wireshark로 열어 상세 분석`;
        }
    </script>
</body>
</html>
  EOF

  depends_on = [null_resource.create_test_dir]
}

// 파일을 적절한 경로에 복사
resource "null_resource" "copy_signature_test_html" {
  provisioner "local-exec" {
    command = <<-EOT
      cp ./cf-test-files/signature-test.html ./cf-test-files/oai-content/
      cp ./cf-test-files/signature-test.html ./cf-test-files/oac-content/
    EOT
  }

  depends_on = [local_file.signature_test_html]
}

// S3 버킷에 파일 업로드
resource "null_resource" "upload_signature_test_html" {
  provisioner "local-exec" {
    command = <<-EOT
      echo "=== 서명 테스트 파일 업로드 중... ==="
      
      # OAI 버킷에 업로드
      aws s3 cp ./cf-test-files/oai-content/signature-test.html s3://${aws_s3_bucket.content_bucket_oai.bucket}/oai-content/ --content-type "text/html; charset=utf-8"
      
      # OAC 버킷에 업로드
      aws s3 cp ./cf-test-files/oac-content/signature-test.html s3://${aws_s3_bucket.content_bucket_oac.bucket}/oac-content/ --content-type "text/html; charset=utf-8"
      
      echo "=== 서명 테스트 파일 업로드 완료 ==="
    EOT
  }

  depends_on = [
    null_resource.copy_signature_test_html,
    aws_s3_bucket_policy.oai_bucket_policy,
    aws_s3_bucket_policy.oac_bucket_policy,
    aws_cloudfront_distribution.cf_elb_origin
  ]
}

// 테스트 URL 정보 출력
resource "null_resource" "show_signature_test_urls" {
  provisioner "local-exec" {
    command = <<-EOT
      echo "=== CloudFront 서명 검증 테스트 URL ==="
      echo "OAI 서명 테스트: https://${aws_cloudfront_distribution.cf_elb_origin.domain_name}/oai-content/signature-test.html"
      echo "OAC 서명 테스트: https://${aws_cloudfront_distribution.cf_elb_origin.domain_name}/oac-content/signature-test.html"
      echo ""
      echo "테스트 방법:"
      echo "1. 브라우저에서 각 URL에 접속합니다."
      echo "2. 페이지에 제공된 AWS CLI 명령어를 사용하여 서명 설정을 확인합니다."
      echo "3. S3 액세스 로깅을 활성화하여 요청 헤더를 분석합니다."
      echo ""
      echo "직접 CloudFront 설정 확인하기:"
      echo "aws cloudfront get-distribution-config --id ${aws_cloudfront_distribution.cf_elb_origin.id}"
      echo ""
      echo "OAI 설정 확인하기:"
      echo "aws cloudfront get-cloud-front-origin-access-identity --id ${aws_cloudfront_origin_access_identity.oai.id}"
      echo ""
      echo "OAC 설정 확인하기:"
      echo "aws cloudfront get-origin-access-control --id ${aws_cloudfront_origin_access_control.oac.id}"
      echo ""
      echo "참고: CloudFront 배포가 완료되기까지 5-10분 정도 소요될 수 있습니다."
    EOT
  }

  depends_on = [null_resource.upload_signature_test_html]
}
