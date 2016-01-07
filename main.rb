require 'logger'
require 'eventmachine'
require 'aws-sdk'

# Logger初期化
logger = Logger.new(STDOUT)

# AWSクライアントセットアップ
@s3 = Aws::S3::Client.new

logger.debug(@s3.list_buckets)

# 最新の画像取得
def get_latest_image_path()
  file_path = Dir.glob("/tmp/motion/*.jpg").max_by {|f| File.mtime(f)}
end

# S3へのファイルアップロード
def upload_file_to_aws(file_path)
  file = File.open(file_path)
  file_name = File.basename(file_path)
  
  @s3.put_object(
    bucket: "biz-hackathon",
    body: file,
    key: file_name
  )
end

# タスクの定期実行用
EM.run do
  # 定期的にタスクを実行する
  EM::PeriodicTimer.new(30) do
    logger.info("trigger")
    
    file_path = get_latest_image_path()
    logger.info(file_path)
    
    upload_file_to_aws(file_path)
    logger.info("finished file upload")
  end
end
