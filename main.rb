require 'logger'
require 'eventmachine'

logger = Logger.new(STDOUT)

# タスクの定期実行用
EM.run do
  # 1秒ごとにタスクを実行する
  EM::PeriodicTimer.new(1) do
    logger.info("trigger")
  end
end
