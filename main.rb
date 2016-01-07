require 'eventmachine'

# タスクの定期実行用
EM.run do
  # 1秒ごとにタスクを実行する
  EM::PeriodicTimer.new(1) do
    puts "[info] event trigger"
  end
end
