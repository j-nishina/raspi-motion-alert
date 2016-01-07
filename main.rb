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
  begin
    file = File.open(file_path)
    file_name = File.basename(file_path)
    
    @s3.put_object(
      bucket: "biz-hackathon",
      body: file,
      key: file_name
    )
  rescue
    logger.error("upload failed")
  end
end

# pinの値を取得して返す。
def get_pin_value()
  pin = File.open("/sys/class/gpio/gpio18/value")
  value = pin.read()[0].to_i
  pin.close
  value
end

# タスクの定期実行用
EM.run do
  # 定期的にタスクを実行する
  EM::PeriodicTimer.new(5) do
    file_path = get_latest_image_path()
    logger.info("file_path: #{file_path}")
    
    pin_value = get_pin_value()
    logger.debug("pin value: #{pin_value}")
    if pin_value == 1 then
      upload_file_to_aws(file_path)
      logger.info("finished file upload")
    end
  end
end
