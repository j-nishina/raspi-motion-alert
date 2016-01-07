require 'logger'
require 'eventmachine'

logger = Logger.new(STDOUT)

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
