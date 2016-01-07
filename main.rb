require 'logger'
require 'eventmachine'
require 'aws-sdk'

# Logger初期化
logger = Logger.new(STDOUT)

# AWSクライアントセットアップ
s3 = Aws::S3::Client.new

logger.debug(s3.list_buckets)

# 最新の画像取得
def get_latest_image()
  file_path = Dir.glob("/tmp/motion/*.jpg").max_by {|f| File.mtime(f)}
end

# タスクの定期実行用
EM.run do
  # 10秒ごとにタスクを実行する
  EM::PeriodicTimer.new(10) do
    logger.info("trigger")
    logger.info(get_latest_image())
  end
end
