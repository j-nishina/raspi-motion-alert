require 'logger'
require 'eventmachine'
require 'aws-sdk'
require 'open-uri'

# Logger初期化
@logger = Logger.new(STDOUT)

# AWSクライアントセットアップ
@s3 = Aws::S3::Client.new

@logger.debug(@s3.list_buckets)

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
    @logger.error("upload failed")
  end
end

# pinの値を取得して返す。
def get_pin_value()
  pin = File.open("/sys/class/gpio/gpio18/value")
  value = pin.read()[0].to_i
  pin.close
  value
end

def call_alert_api(file_path)
  file_name = File.basename(file_path)
  url = "https://qntg1nh5pj.execute-api.ap-northeast-1.amazonaws.com/prod/pythonFunction4/#{file_name}"
  @logger.info(url)
  res = open(url)
  @logger.info(res)
end

# ピンの立ち上がり立ち下がりのトリガー管理
class PinState
  attr :state
  attr :positive_trigger
  attr :negative_trigger
  
  def initialize()
    @state == false
    @positive_trigger = false
    @negative_trigger  = false
  end

  # pinの状態更新
  # stateが変わるとその方向のtriggerをtrueにする
  def update_pin_state(state)
    if state != @state then
      if state == 1 then
        puts("positive")
        @positive_trigger = true
      else
        puts("negative")
        @negative_trigger  = true
      end
      @state = state
      puts("new pin state #{@state}")
    end
  end

  def reset()
    @positive_trigger = false
    @negative_trigger  = false
  end
end

pin_state = PinState.new()

# タスクの定期実行用
EM.run do
  # 定期的にタスクを実行する
  EM::PeriodicTimer.new(5) do
    begin
      file_path = get_latest_image_path()
      @logger.info("file_path: #{file_path}")
      
      pin_value = get_pin_value()
      pin_state.update_pin_state(pin_value)
      @logger.debug("pin value: #{pin_value}")
      @logger.debug("pin state: #{pin_state.positive_trigger}")

      if pin_state.positive_trigger then
        upload_file_to_aws(file_path)
        call_alert_api(file_path)
        @logger.info("finished file upload")
        pin_state.reset()
      end
    rescue
      @logger.error("failed to detect")
    end
  end
end
