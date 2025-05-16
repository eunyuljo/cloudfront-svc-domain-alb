# // 테스트 파일 생성을 위한 로컬 디렉토리
# resource "null_resource" "create_test_dir" {
#   provisioner "local-exec" {
#     command = "mkdir -p ./cf-test-files/oai-content ./cf-test-files/oac-content"
#   }

#   depends_on = [
#     aws_s3_bucket.content_bucket_oai,
#     aws_s3_bucket.content_bucket_oac
#   ]
# }


# // 간단한 HTML 테스트 파일 생성
# resource "local_file" "very_simple_test_html" {
#   filename = "./cf-test-files/index.html"
#   content  = <<-EOF
# <!DOCTYPE html>
# <html>
# <head>
#     <meta charset="UTF-8">
#     <title>CloudFront OAI/OAC 테스트</title>
#     <style>
#         body { font-family: Arial, sans-serif; margin: 20px; line-height: 1.5; }
#         .header { background-color: #2c3e50; color: white; padding: 20px; text-align: center; }
#         .container { max-width: 800px; margin: 0 auto; }
#         .test-box { margin: 20px 0; padding: 20px; border: 1px solid #ddd; border-radius: 5px; }
#         .success { color: green; font-weight: bold; }
#         .error { color: red; font-weight: bold; }
#         button { padding: 10px 15px; background-color: #3498db; color: white; border: none; 
#                 border-radius: 4px; cursor: pointer; }
#         button:hover { background-color: #2980b9; }
#     </style>
# </head>
# <body>
#     <div class="header">
#         <h1>CloudFront + S3 연동 테스트</h1>
#         <p>OAI와 OAC 방식 비교 테스트</p>
#     </div>
    
#     <div class="container">
#         <div class="test-box">
#             <h2>현재 접근 방식 확인</h2>
#             <p>이 페이지는 CloudFront를 통해 S3에서 제공되는 HTML 파일입니다.</p>
#             <p><strong>현재 접근 방식:</strong> <span id="access-method">확인 중...</span></p>
#             <p><strong>접속 시간:</strong> <span id="current-time">확인 중...</span></p>
#         </div>
        
#         <div class="test-box">
#             <h2>CloudFront 정상 작동 확인</h2>
#             <p>이 메시지가 보인다면 CloudFront가 S3 콘텐츠를 정상적으로 전달하고 있습니다.</p>
#             <p><strong>결과:</strong> <span class="success">성공 - CloudFront가 정상 작동합니다.</span></p>
#         </div>
        
#         <div class="test-box">
#             <h2>S3 직접 접근 테스트</h2>
#             <p>S3 버킷에 직접 접근 시 차단되는지 테스트합니다.</p>
#             <p><strong>테스트 URL:</strong> <span id="s3-url">설정 중...</span></p>
#             <button onclick="testS3Access()">S3 직접 접근 테스트</button>
#             <p id="s3-result">아직 테스트가 실행되지 않았습니다.</p>
#         </div>
#     </div>

#     <script>
#         // 페이지 로드 시 실행
#         document.addEventListener('DOMContentLoaded', function() {
#             // 접근 방식 확인
#             const currentUrl = window.location.href;
#             const accessMethod = document.getElementById('access-method');
            
#             if (currentUrl.includes('oai-content')) {
#                 accessMethod.textContent = 'OAI (Origin Access Identity)';
#                 accessMethod.className = 'success';
#             } else if (currentUrl.includes('oac-content')) {
#                 accessMethod.textContent = 'OAC (Origin Access Control)';
#                 accessMethod.className = 'success';
#             } else {
#                 accessMethod.textContent = '알 수 없음 (URL에 oai-content 또는 oac-content가 포함되어 있지 않음)';
#                 accessMethod.className = 'error';
#             }
            
#             // 현재 시간 표시
#             document.getElementById('current-time').textContent = new Date().toLocaleString();
            
#             // S3 URL 설정
#             const baseUrl = window.location.href.split('/').slice(0, -1).join('/');
#             let s3Domain;
#             if (baseUrl.includes('oai-content')) {
#                 s3Domain = "${aws_s3_bucket.content_bucket_oai.bucket}.s3.amazonaws.com/oai-content";
#             } else {
#                 s3Domain = "${aws_s3_bucket.content_bucket_oac.bucket}.s3.amazonaws.com/oac-content";
#             }
#             document.getElementById('s3-url').textContent = 'https://' + s3Domain + '/index.html';
#         });
        
#         // S3 직접 접근 테스트
#         function testS3Access() {
#             const resultElem = document.getElementById('s3-result');
#             resultElem.textContent = '테스트 중...';
#             resultElem.className = '';
            
#             const s3Url = document.getElementById('s3-url').textContent;
            
#             // XMLHttpRequest 사용
#             const xhr = new XMLHttpRequest();
#             const timeoutId = setTimeout(function() {
#                 xhr.abort();
#                 resultElem.textContent = '시간 초과 - S3 직접 접근이 차단된 것으로 보입니다. (정상)';
#                 resultElem.className = 'success';
#             }, 5000);
            
#             xhr.onreadystatechange = function() {
#                 if (xhr.readyState === 4) {
#                     clearTimeout(timeoutId);
#                     if (xhr.status >= 200 && xhr.status < 300) {
#                         resultElem.textContent = '주의: S3에 직접 접근이 가능합니다. 보안 설정을 확인하세요.';
#                         resultElem.className = 'error';
#                     } else {
#                         resultElem.textContent = '접근 거부됨 (' + xhr.status + ') - S3 직접 접근이 차단되었습니다. (정상)';
#                         resultElem.className = 'success';
#                     }
#                 }
#             };
            
#             try {
#                 xhr.open('GET', s3Url, true);
#                 xhr.send();
#             } catch (error) {
#                 clearTimeout(timeoutId);
#                 resultElem.textContent = '오류 발생: ' + error.message + ' - S3 직접 접근이 차단된 것으로 보입니다. (정상)';
#                 resultElem.className = 'success';
#             }
#         }
#     </script>
# </body>
# </html>
#   EOF

#   depends_on = [null_resource.create_test_dir]
# }

# // 파일을 적절한 경로에 복사
# resource "null_resource" "copy_very_simple_html" {
#   provisioner "local-exec" {
#     command = <<-EOT
#       mkdir -p ./cf-test-files/oai-content
#       mkdir -p ./cf-test-files/oac-content
#       cp ./cf-test-files/index.html ./cf-test-files/oai-content/
#       cp ./cf-test-files/index.html ./cf-test-files/oac-content/
#     EOT
#   }

#   depends_on = [local_file.very_simple_test_html]
# }

# // S3 버킷에 파일 업로드
# resource "null_resource" "upload_very_simple_html" {
#   provisioner "local-exec" {
#     command = <<-EOT
#       echo "=== S3 버킷에 파일 업로드 중... ==="
      
#       # OAI 버킷에 업로드
#       echo "OAI 버킷에 업로드 중..."
#       aws s3 cp ./cf-test-files/oai-content/index.html s3://${aws_s3_bucket.content_bucket_oai.bucket}/oai-content/ --content-type "text/html; charset=utf-8"
      
#       # OAC 버킷에 업로드
#       echo "OAC 버킷에 업로드 중..."
#       aws s3 cp ./cf-test-files/oac-content/index.html s3://${aws_s3_bucket.content_bucket_oac.bucket}/oac-content/ --content-type "text/html; charset=utf-8"
      
#       echo "=== 업로드 완료 ==="
#     EOT
#   }

#   depends_on = [
#     null_resource.copy_very_simple_html,
#     aws_s3_bucket_policy.oai_bucket_policy,
#     aws_s3_bucket_policy.oac_bucket_policy,
#     aws_cloudfront_distribution.cf_elb_origin
#   ]
# }

# // CloudFront URL 정보 출력
# resource "null_resource" "show_test_urls" {
#   provisioner "local-exec" {
#     command = <<-EOT
#       echo "=== CloudFront 테스트 URL ==="
#       echo "CloudFront 도메인: ${aws_cloudfront_distribution.cf_elb_origin.domain_name}"
#       echo "OAI 테스트 URL: https://${aws_cloudfront_distribution.cf_elb_origin.domain_name}/oai-content/index.html"
#       echo "OAC 테스트 URL: https://${aws_cloudfront_distribution.cf_elb_origin.domain_name}/oac-content/index.html"
#       echo ""
#       echo "테스트 방법:"
#       echo "1. 위 URL로 접근하여 페이지가 정상적으로 로드되는지 확인"
#       echo "2. 'S3 직접 접근 테스트' 버튼을 클릭하여 S3 버킷 보안 설정 확인"
#       echo "3. IPv6 네트워크에서 동일한 테스트 수행하여 OAI와 OAC의 차이 확인"
#       echo ""
#       echo "참고: CloudFront 배포가 완료되기까지 5-10분 정도 소요될 수 있습니다."
#     EOT
#   }

#   depends_on = [null_resource.upload_very_simple_html]
# }
